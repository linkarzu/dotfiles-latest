import assert from "node:assert/strict"
import { mkdtemp, rm } from "node:fs/promises"
import { tmpdir } from "node:os"
import { join } from "node:path"
import test from "node:test"

import { TelegramBridge } from "./bridge.mjs"

function jsonResponse(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  })
}

async function fixture(fetchImpl, now = () => 1000) {
  const directory = await mkdtemp(join(tmpdir(), "opencode-telegram-test-"))
  const bridge = new TelegramBridge({
    botToken: "123:test-token",
    allowedUserID: "42",
    chatID: "42",
    stateFile: join(directory, "state.json"),
    fetchImpl,
    now,
  })
  return { bridge, cleanup: () => rm(directory, { recursive: true, force: true }) }
}

function register(bridge, instanceID, port) {
  bridge.registerInstance({
    instanceID,
    serverURL: `http://127.0.0.1:${port}`,
    directory: "/project",
    kittySession: `kitty-${instanceID}`,
    kittyWindowID: port,
    sessions: [],
  })
}

test("waits four minutes and revalidates before notifying", async (context) => {
  let now = 10_000
  const calls = []
  const { bridge, cleanup } = await fixture(async (url, options) => {
    calls.push({ url: String(url), body: options?.body && JSON.parse(options.body) })
    if (String(url).includes("api.telegram.org")) {
      return jsonResponse({ ok: true, result: { message_id: 77 } })
    }
    return jsonResponse([{ id: "question-1", sessionID: "session-1" }])
  }, () => now)
  context.after(cleanup)
  register(bridge, "one", 5001)

  await bridge.processPluginEvent({
    instanceID: "one",
    event: {
      action: "attention",
      kind: "question",
      sessionID: "session-1",
      requestID: "question-1",
      details: { questions: [{ question: "Proceed?", options: [] }] },
    },
  })
  await bridge.flushDueAlerts()
  assert.equal(calls.length, 0)

  now += 4 * 60 * 1000
  register(bridge, "one", 5001)
  await bridge.flushDueAlerts()
  const validationCall = calls.find((call) => call.url.includes("127.0.0.1:5001/question"))
  const telegramCall = calls.find((call) => call.url.includes("api.telegram.org"))
  assert.ok(validationCall)
  assert.ok(telegramCall)
  assert.equal(telegramCall.body.chat_id, "42")
  assert.match(telegramCall.body.text, /Proceed\?/)
  assert.match(telegramCall.body.text, /Question requires an answer\n\nkitty-one/)
})

test("includes up to 3,500 characters from the completed response", async (context) => {
  const responseText = "x".repeat(3600)
  const { bridge, cleanup } = await fixture(async (url) => {
    if (String(url).includes("/message")) {
      return jsonResponse([{
        info: { role: "assistant" },
        parts: [{ type: "text", text: responseText }],
      }])
    }
    return jsonResponse({ title: "Long response" })
  })
  context.after(cleanup)
  register(bridge, "one", 5001)

  const presentation = await bridge.alertPresentation({
    instanceID: "one",
    sessionID: "session-1",
    kind: "done",
    details: {},
  })

  assert.ok(presentation.text.includes(`${"x".repeat(3497)}...`))
  assert.ok(presentation.text.length <= 3900)
})

test("local resolution cancels an unsent alert", async (context) => {
  let now = 1000
  const calls = []
  const { bridge, cleanup } = await fixture(async (url) => {
    calls.push(String(url))
    return jsonResponse({ ok: true, result: true })
  }, () => now)
  context.after(cleanup)
  register(bridge, "one", 5001)

  const base = { kind: "permission", sessionID: "session-1", requestID: "permission-1" }
  await bridge.processPluginEvent({
    instanceID: "one",
    event: { action: "attention", ...base, details: { permission: "bash", patterns: ["git status"] } },
  })
  await bridge.processPluginEvent({
    instanceID: "one",
    event: { action: "resolve", ...base, resolution: "Permission answered locally" },
  })
  now += 4 * 60 * 1000
  await bridge.flushDueAlerts()

  assert.deepEqual(calls, [])
})

test("routes replies to the exact registered OpenCode instance", async (context) => {
  const calls = []
  const { bridge, cleanup } = await fixture(async (url, options) => {
    calls.push({ url: String(url), body: options?.body && JSON.parse(options.body) })
    if (String(url).includes("api.telegram.org")) return jsonResponse({ ok: true, result: true })
    return new Response(null, { status: 204 })
  })
  context.after(cleanup)
  register(bridge, "one", 5001)
  register(bridge, "two", 5002)

  await bridge.processPluginEvent({
    instanceID: "two",
    event: {
      action: "attention",
      kind: "permission",
      sessionID: "session-2",
      requestID: "permission-2",
      details: { apiVersion: "v2", permission: "bash", patterns: ["npm test"] },
    },
  })
  const alert = Object.values(bridge.state.alerts)[0]
  alert.sentMessageID = 99
  alert.sentText = "Permission required"
  await bridge.answerPermission(alert, "always")

  assert.match(calls[0].url, /^http:\/\/127\.0\.0\.1:5002\/api\/session\/session-2\/permission\/permission-2\/reply/)
  assert.deepEqual(calls[0].body, { reply: "always" })
  assert.equal(calls.some((call) => call.url.includes(":5001")), false)
})

test("a later completion creates a fresh alert for the same session", async (context) => {
  let now = 1000
  const { bridge, cleanup } = await fixture(async () => jsonResponse({ ok: true, result: true }), () => now)
  context.after(cleanup)
  register(bridge, "one", 5001)

  const attention = { action: "attention", kind: "done", sessionID: "session-1" }
  await bridge.processPluginEvent({ instanceID: "one", event: attention })
  const first = Object.values(bridge.state.alerts)[0]
  first.sentMessageID = 10
  await bridge.processPluginEvent({
    instanceID: "one",
    event: { action: "resolve-session", kind: "done", sessionID: "session-1" },
  })

  now += 1000
  await bridge.processPluginEvent({ instanceID: "one", event: attention })
  const second = Object.values(bridge.state.alerts)[0]
  assert.notEqual(second.id, first.id)
  assert.equal(second.sentMessageID, undefined)
  assert.equal(second.dueAt, now + 4 * 60 * 1000)
})

test("revalidates v2 questions through the session API wrapper", async (context) => {
  let now = 1000
  const calls = []
  const { bridge, cleanup } = await fixture(async (url, options) => {
    calls.push({ url: String(url), body: options?.body && JSON.parse(options.body) })
    if (String(url).includes("/api/session/session-v2/question")) {
      return jsonResponse({ data: [{ id: "question-v2", sessionID: "session-v2" }] })
    }
    if (String(url).includes("api.telegram.org")) {
      return jsonResponse({ ok: true, result: { message_id: 88 } })
    }
    return jsonResponse({})
  }, () => now)
  context.after(cleanup)
  register(bridge, "one", 5001)
  await bridge.processPluginEvent({
    instanceID: "one",
    event: {
      action: "attention",
      kind: "question",
      sessionID: "session-v2",
      requestID: "question-v2",
      details: { apiVersion: "v2", questions: [{ question: "Choose", options: [] }] },
    },
  })

  now += 4 * 60 * 1000
  register(bridge, "one", 5001)
  await bridge.flushDueAlerts()

  assert.ok(calls.some((call) => call.url.includes("/api/session/session-v2/question")))
  assert.ok(calls.some((call) => call.url.includes("api.telegram.org")))
})

test("uses the deprecated session permission response contract", async (context) => {
  const calls = []
  const { bridge, cleanup } = await fixture(async (url, options) => {
    calls.push({ url: String(url), body: options?.body && JSON.parse(options.body) })
    if (String(url).includes("api.telegram.org")) return jsonResponse({ ok: true, result: true })
    return jsonResponse({ id: "session-old" })
  })
  context.after(cleanup)
  register(bridge, "one", 5001)
  await bridge.processPluginEvent({
    instanceID: "one",
    event: {
      action: "attention",
      kind: "permission",
      sessionID: "session-old",
      requestID: "permission-old",
      details: { apiVersion: "deprecated", permission: "bash", patterns: ["pwd"] },
    },
  })
  const alert = Object.values(bridge.state.alerts)[0]
  await bridge.answerPermission(alert, "once")

  assert.match(calls[0].url, /\/session\/session-old\/permissions\/permission-old/)
  assert.deepEqual(calls[0].body, { response: "once" })
})

test("restores pending attention and resolves it from heartbeat snapshots", async (context) => {
  let now = 1000
  const { bridge, cleanup } = await fixture(async () => jsonResponse({ ok: true, result: true }), () => now)
  context.after(cleanup)
  const attention = {
    action: "attention",
    kind: "done",
    sessionID: "session-1",
    details: {},
  }
  const registration = {
    instanceID: "one",
    serverURL: "http://127.0.0.1:5001",
    directory: "/project",
    attention: [attention],
  }
  bridge.registerInstance(registration)
  await bridge.reconcileRegistration(registration)
  const alert = Object.values(bridge.state.alerts)[0]
  const originalDueAt = alert.dueAt
  alert.sentMessageID = 42
  alert.sentText = "Original notification"

  now += 30_000
  bridge.registerInstance(registration)
  await bridge.reconcileRegistration(registration)
  let currentAlert = Object.values(bridge.state.alerts)[0]
  assert.equal(currentAlert.dueAt, originalDueAt)
  assert.equal(currentAlert.resolvedAt, undefined)
  assert.equal(currentAlert.sentText, "Original notification")

  const resolvedRegistration = { ...registration, attention: [] }
  bridge.registerInstance(resolvedRegistration)
  await bridge.reconcileRegistration(resolvedRegistration)
  currentAlert = Object.values(bridge.state.alerts)[0]
  assert.equal(currentAlert.resolution, "Resolved locally")
})

test("concurrent flushes send only one Telegram notification", async (context) => {
  let now = 1000
  let telegramSends = 0
  const { bridge, cleanup } = await fixture(async (url) => {
    await new Promise((resolve) => setTimeout(resolve, 5))
    if (String(url).includes("api.telegram.org")) {
      telegramSends++
      return jsonResponse({ ok: true, result: { message_id: 99 } })
    }
    if (String(url).includes("/question")) return jsonResponse([{ id: "question-1" }])
    return jsonResponse({})
  }, () => now)
  context.after(cleanup)
  register(bridge, "one", 5001)
  await bridge.processPluginEvent({
    instanceID: "one",
    event: {
      action: "attention",
      kind: "question",
      sessionID: "session-1",
      requestID: "question-1",
      details: { questions: [{ question: "Proceed?", options: [] }] },
    },
  })
  now += 4 * 60 * 1000
  register(bridge, "one", 5001)

  await Promise.all([bridge.flushDueAlerts(), bridge.flushDueAlerts()])
  assert.equal(telegramSends, 1)
})

test("local HTTP writes require the plugin secret", async (context) => {
  const { bridge, cleanup } = await fixture(async () => jsonResponse({}))
  bridge.port = 0
  await bridge.startLocalServer()
  context.after(async () => {
    await bridge.stop()
    await cleanup()
  })
  const port = bridge.server.address().port
  const registration = {
    instanceID: "one",
    serverURL: "http://127.0.0.1:5001",
    directory: "/project",
    attention: [],
  }

  const rejected = await fetch(`http://127.0.0.1:${port}/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(registration),
  })
  assert.equal(rejected.status, 403)

  const accepted = await fetch(`http://127.0.0.1:${port}/register`, {
    method: "POST",
    headers: {
      Authorization: "Bearer test-secret",
      "Content-Type": "application/json",
    },
    body: JSON.stringify(registration),
  })
  assert.equal(accepted.status, 200)
  assert.equal(bridge.instances.has("one"), true)
})

test("local HTTP client can toggle phone mode", async (context) => {
  const { bridge, cleanup } = await fixture(async () => jsonResponse({ ok: true, result: true }))
  bridge.port = 0
  await bridge.startLocalServer()
  context.after(async () => {
    await bridge.stop()
    await cleanup()
  })
  const port = bridge.server.address().port
  const toggle = () => fetch(`http://127.0.0.1:${port}/phone-mode/toggle`, {
    method: "POST",
    headers: {
      Authorization: "Bearer test-secret",
      "Content-Type": "application/json",
    },
    body: "{}",
  })

  const enabled = await toggle()
  assert.deepEqual(await enabled.json(), { ok: true, phoneMode: true })
  assert.equal(bridge.state.phoneMode, true)

  const disabled = await toggle()
  assert.deepEqual(await disabled.json(), { ok: true, phoneMode: false })
  assert.equal(bridge.state.phoneMode, false)
})

test("Telegram follow-ups preserve the session agent and model", async (context) => {
  const calls = []
  const { bridge, cleanup } = await fixture(async (url, options) => {
    calls.push({ url: String(url), body: options?.body && JSON.parse(options.body) })
    if (String(url).includes("/session/status")) return jsonResponse({})
    if (String(url).includes("/message")) {
      return jsonResponse([{
        info: {
          role: "user",
          agent: "plan",
          model: { providerID: "openai", modelID: "gpt-test" },
        },
        parts: [],
      }])
    }
    if (String(url).includes("/prompt_async")) return new Response(null, { status: 204 })
    return jsonResponse({ ok: true, result: true })
  })
  context.after(cleanup)
  register(bridge, "one", 5001)
  let phoneModeAtPrompt = false
  const opencodeRequest = bridge.opencodeRequest.bind(bridge)
  bridge.opencodeRequest = async (instance, path, options) => {
    if (path.includes("/prompt_async")) phoneModeAtPrompt = bridge.state.phoneMode
    return opencodeRequest(instance, path, options)
  }
  const alert = {
    id: "done-1",
    instanceID: "one",
    sessionID: "session-1",
    kind: "done",
    details: {},
  }

  await bridge.continueSession(alert, "Continue from Telegram")
  const prompt = calls.find((call) => call.url.includes("/prompt_async"))
  assert.deepEqual(prompt.body, {
    agent: "plan",
    model: { providerID: "openai", modelID: "gpt-test" },
    parts: [{ type: "text", text: "Continue from Telegram" }],
  })
  assert.equal(bridge.state.phoneMode, true)
  assert.equal(phoneModeAtPrompt, true)
})

test("Telegram build command overrides a session's plan agent", async (context) => {
  const calls = []
  const { bridge, cleanup } = await fixture(async (url, options) => {
    const target = String(url)
    calls.push({ url: target, body: options?.body && JSON.parse(options.body) })
    if (target.includes("api.telegram.org")) {
      return jsonResponse({ ok: true, result: { message_id: 90 } })
    }
    if (target.includes("/session/status")) return jsonResponse({})
    if (target.includes("/message")) {
      return jsonResponse([{
        info: { role: "user", agent: "plan" },
        parts: [],
      }])
    }
    if (target.includes("/prompt_async")) return new Response(null, { status: 204 })
    return jsonResponse({})
  })
  context.after(cleanup)
  register(bridge, "one", 5001)
  await bridge.processPluginEvent({
    instanceID: "one",
    event: { action: "attention", kind: "done", sessionID: "session-1" },
  })
  const alert = Object.values(bridge.state.alerts)[0]
  alert.sentMessageID = 77
  alert.sentText = "OpenCode is waiting"

  await bridge.handleMessage({
    from: { id: 42 },
    chat: { id: 42 },
    text: "/build Implement the plan",
    reply_to_message: { message_id: 77 },
  })

  const prompt = calls.find((call) => call.url.includes("/prompt_async"))
  assert.deepEqual(prompt.body, {
    agent: "build",
    parts: [{ type: "text", text: "Implement the plan" }],
  })
  assert.ok(calls.some((call) => call.body?.text === "Sent to OpenCode in build mode."))
})

test("Telegram replies enable global phone mode until the next local prompt", async (context) => {
  let now = 1000
  let messageID = 100
  const calls = []
  const { bridge, cleanup } = await fixture(async (url, options) => {
    const target = String(url)
    calls.push({ url: target, body: options?.body && JSON.parse(options.body) })
    if (target.includes("api.telegram.org")) {
      return jsonResponse({ ok: true, result: { message_id: messageID++ } })
    }
    if (target.includes("/session/status")) return jsonResponse({})
    if (target.includes("/message")) return jsonResponse([])
    if (target.includes("/prompt_async")) return new Response(null, { status: 204 })
    return jsonResponse({})
  }, () => now)
  context.after(cleanup)
  register(bridge, "one", 5001)
  register(bridge, "two", 5002)

  await bridge.processPluginEvent({
    instanceID: "one",
    event: { action: "attention", kind: "done", sessionID: "session-1" },
  })
  await bridge.processPluginEvent({
    instanceID: "two",
    event: { action: "attention", kind: "done", sessionID: "session-2" },
  })
  const first = Object.values(bridge.state.alerts).find((alert) => alert.sessionID === "session-1")
  const second = Object.values(bridge.state.alerts).find((alert) => alert.sessionID === "session-2")
  first.sentMessageID = 42
  first.sentText = "First completion"

  await bridge.continueSession(first, "Continue from Telegram")

  assert.equal(bridge.state.phoneMode, true)
  assert.ok(second.sentMessageID)
  assert.ok(calls.some((call) => call.body?.text?.includes("session-2")))

  now += 1000
  await bridge.processPluginEvent({
    instanceID: "one",
    event: { action: "local-prompt", sessionID: "session-1" },
  })
  await bridge.processPluginEvent({
    instanceID: "two",
    event: { action: "attention", kind: "done", sessionID: "session-3" },
  })
  const third = Object.values(bridge.state.alerts).find((alert) => alert.sessionID === "session-3")

  assert.equal(bridge.state.phoneMode, false)
  assert.equal(third.sentMessageID, undefined)
  assert.equal(third.dueAt, now + 4 * 60 * 1000)
})

test("restores phone mode after a bridge restart", async (context) => {
  const { bridge, cleanup } = await fixture(async () => jsonResponse({ ok: true, result: true }))
  context.after(cleanup)
  await bridge.activatePhoneMode()

  const restored = new TelegramBridge({
    botToken: "123:test-token",
    allowedUserID: "42",
    stateFile: bridge.stateFile,
    fetchImpl: async () => jsonResponse({ ok: true, result: true }),
  })
  await restored.loadState()

  assert.equal(restored.state.phoneMode, true)
})

test("local abort suppresses its error and follow-up completion", async (context) => {
  const calls = []
  const { bridge, cleanup } = await fixture(async (url) => {
    calls.push(String(url))
    return jsonResponse({ ok: true, result: true })
  })
  context.after(cleanup)
  register(bridge, "one", 5001)

  await bridge.processPluginEvent({
    instanceID: "one",
    event: { action: "attention", kind: "error", sessionID: "session-1", details: { message: "Aborted" } },
  })
  await bridge.processPluginEvent({
    instanceID: "one",
    event: { action: "attention", kind: "done", sessionID: "session-1" },
  })

  assert.deepEqual(calls, [])
  assert.equal(Object.values(bridge.state.alerts).length, 0)
  assert.ok(bridge.state.abortSuppressions["one:session-1"])

  const resumedRegistration = {
    instanceID: "one",
    serverURL: "http://127.0.0.1:5001",
    directory: "/project",
    attention: [],
    sessions: [{ id: "session-1", status: "busy" }],
  }
  bridge.registerInstance(resumedRegistration)
  await bridge.reconcileRegistration(resumedRegistration)
  assert.equal(bridge.state.abortSuppressions["one:session-1"], undefined)
})

test("abort rejects a pending question and suppresses expected follow-up alerts", async (context) => {
  const calls = []
  const { bridge, cleanup } = await fixture(async (url, options) => {
    calls.push({ url: String(url), body: options?.body && JSON.parse(options.body) })
    if (String(url).includes("api.telegram.org")) return jsonResponse({ ok: true, result: true })
    return new Response(null, { status: 204 })
  })
  context.after(cleanup)
  register(bridge, "one", 5001)
  await bridge.processPluginEvent({
    instanceID: "one",
    event: {
      action: "attention",
      kind: "question",
      sessionID: "session-1",
      requestID: "question-1",
      details: { apiVersion: "legacy", questions: [] },
    },
  })
  const alert = Object.values(bridge.state.alerts)[0]
  alert.sentMessageID = 42
  alert.sentText = "Pending question"

  await bridge.abortSession(alert)
  await bridge.processPluginEvent({
    instanceID: "one",
    event: { action: "attention", kind: "error", sessionID: "session-1", details: { message: "Aborted" } },
  })
  await bridge.processPluginEvent({
    instanceID: "one",
    event: { action: "attention", kind: "done", sessionID: "session-1" },
  })

  assert.ok(calls.some((call) => call.url.includes("/question/question-1/reject")))
  assert.ok(calls.some((call) => call.url.includes("/session/session-1/abort")))
  assert.equal(alert.resolution, "Aborted from Telegram")
  assert.equal(Object.values(bridge.state.alerts).some((item) => item.kind === "error"), false)
  assert.equal(Object.values(bridge.state.alerts).some((item) => item.kind === "done"), false)

  const resumedRegistration = {
    instanceID: "one",
    serverURL: "http://127.0.0.1:5001",
    directory: "/project",
    attention: [],
    sessions: [{ id: "session-1", status: "busy" }],
  }
  bridge.registerInstance(resumedRegistration)
  await bridge.reconcileRegistration(resumedRegistration)
  assert.equal(bridge.state.abortSuppressions["one:session-1"], undefined)
})
