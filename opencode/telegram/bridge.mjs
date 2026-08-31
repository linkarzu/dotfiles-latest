#!/opt/homebrew/bin/node

import { createServer } from "node:http"
import { lstat, mkdir, readFile, rename, writeFile } from "node:fs/promises"
import { dirname } from "node:path"
import { randomBytes, timingSafeEqual } from "node:crypto"
import { pathToFileURL } from "node:url"

const LOOPBACK_HOST = "127.0.0.1"
const DEFAULT_PORT = 47653
const DEFAULT_DELAY_MS = 4 * 60 * 1000
const RECENT_LOCAL_ACTIVITY_MS = 90 * 1000
const INSTANCE_STALE_MS = 60 * 1000
const TELEGRAM_TEXT_LIMIT = 3900
const COMPLETION_SUMMARY_LIMIT = 3500
const RESOLVED_RETENTION_MS = 24 * 60 * 60 * 1000

function sleep(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds))
}

function truncate(value, limit) {
  const text = String(value ?? "").trim()
  if (text.length <= limit) return text
  return `${text.slice(0, Math.max(0, limit - 3))}...`
}

function alertKey(instanceID, event) {
  const request = event.requestID || event.sessionID
  return `${instanceID}:${event.kind}:${request}`
}

function isLoopbackAddress(address) {
  return address === "127.0.0.1" || address === "::1" || address === "::ffff:127.0.0.1"
}

function isLoopbackURL(value) {
  try {
    const url = new URL(value)
    return url.protocol === "http:" && ["127.0.0.1", "localhost", "::1", "[::1]"].includes(url.hostname)
  } catch {
    return false
  }
}

function defaultState() {
  return { updateOffset: 0, alerts: {}, abortSuppressions: {}, phoneMode: false }
}

export class TelegramBridge {
  constructor(options) {
    this.botToken = options.botToken
    this.localSecret = options.localSecret ?? "test-secret"
    this.allowedUserID = String(options.allowedUserID)
    this.chatID = String(options.chatID ?? options.allowedUserID)
    this.stateFile = options.stateFile
    this.port = options.port ?? DEFAULT_PORT
    this.attentionDelayMs = options.attentionDelayMs ?? DEFAULT_DELAY_MS
    this.fetch = options.fetchImpl ?? globalThis.fetch
    this.now = options.now ?? (() => Date.now())
    this.instances = new Map()
    this.state = defaultState()
    this.running = false
    this.server = undefined
    this.tickTimer = undefined
    this.runtimeQueue = Promise.resolve()
    this.flushPromise = undefined
  }

  async loadState() {
    try {
      const parsed = JSON.parse(await readFile(this.stateFile, "utf8"))
      if (parsed && typeof parsed === "object") {
        this.state = {
          updateOffset: Number(parsed.updateOffset) || 0,
          alerts: parsed.alerts && typeof parsed.alerts === "object" ? parsed.alerts : {},
          abortSuppressions: parsed.abortSuppressions && typeof parsed.abortSuppressions === "object"
            ? parsed.abortSuppressions
            : {},
          phoneMode: parsed.phoneMode === true,
        }
      }
    } catch (error) {
      if (error?.code !== "ENOENT") throw error
    }
  }

  async saveState() {
    const cutoff = this.now() - RESOLVED_RETENTION_MS
    for (const [key, alert] of Object.entries(this.state.alerts)) {
      if (alert.resolvedAt && alert.resolvedAt < cutoff) delete this.state.alerts[key]
    }
    await mkdir(dirname(this.stateFile), { recursive: true, mode: 0o700 })
    const temporary = `${this.stateFile}.${process.pid}.${randomBytes(4).toString("hex")}.tmp`
    await writeFile(temporary, `${JSON.stringify(this.state, null, 2)}\n`, { mode: 0o600 })
    await rename(temporary, this.stateFile)
  }

  enqueue(task) {
    const result = this.runtimeQueue.then(task, task)
    this.runtimeQueue = result.catch(() => undefined)
    return result
  }

  async start() {
    await this.loadState()
    this.running = true
    await this.startLocalServer()

    await this.telegram("setMyCommands", {
      commands: [
        { command: "status", description: "Show registered OpenCode instances" },
        { command: "sessions", description: "List live OpenCode sessions" },
        { command: "build", description: "Continue a replied session in build mode" },
        { command: "plan", description: "Continue a replied session in plan mode" },
        { command: "abort", description: "Abort the session in a replied notification" },
      ],
    }).catch((error) => console.error("Telegram command setup failed", error.message))

    this.tickTimer = setInterval(() => {
      void this.enqueue(() => this.flushDueAlerts()).catch((error) => console.error("alert flush failed", error.message))
    }, 5000)
    void this.pollTelegram()
    await this.enqueue(() => this.flushDueAlerts()).catch((error) => console.error("initial alert flush failed", error.message))
  }

  async startLocalServer() {
    this.server = createServer((request, response) => {
      void this.handleLocalRequest(request, response)
    })
    await new Promise((resolve, reject) => {
      this.server.once("error", reject)
      this.server.listen(this.port, LOOPBACK_HOST, resolve)
    })
  }

  async stop() {
    this.running = false
    if (this.tickTimer) clearInterval(this.tickTimer)
    if (this.server) await new Promise((resolve) => this.server.close(resolve))
    await this.runtimeQueue
    await this.saveState()
  }

  async readJSONBody(request) {
    let body = ""
    for await (const chunk of request) {
      body += chunk
      if (body.length > 256 * 1024) throw new Error("Request body is too large")
    }
    return body ? JSON.parse(body) : {}
  }

  sendLocalResponse(response, status, body) {
    response.writeHead(status, { "Content-Type": "application/json" })
    response.end(`${JSON.stringify(body)}\n`)
  }

  async handleLocalRequest(request, response) {
    try {
      if (!isLoopbackAddress(request.socket.remoteAddress)) {
        this.sendLocalResponse(response, 403, { error: "Loopback clients only" })
        return
      }

      if (request.method === "GET" && request.url === "/health") {
        this.sendLocalResponse(response, 200, {
          ok: true,
          instances: this.instances.size,
          attentionDelaySeconds: this.attentionDelayMs / 1000,
          phoneMode: this.state.phoneMode,
        })
        return
      }
      if (request.method !== "POST") {
        this.sendLocalResponse(response, 404, { error: "Not found" })
        return
      }

      if (request.headers.origin || !String(request.headers["content-type"] ?? "").startsWith("application/json")) {
        this.sendLocalResponse(response, 403, { error: "JSON service clients only" })
        return
      }
      const provided = String(request.headers.authorization ?? "").replace(/^Bearer /, "")
      const expectedBuffer = Buffer.from(this.localSecret)
      const providedBuffer = Buffer.from(provided)
      if (providedBuffer.length !== expectedBuffer.length || !timingSafeEqual(providedBuffer, expectedBuffer)) {
        this.sendLocalResponse(response, 403, { error: "Invalid bridge credentials" })
        return
      }

      const payload = await this.readJSONBody(request)
      let responseBody = { ok: true }
      await this.enqueue(async () => {
        if (request.url === "/register") {
          this.registerInstance(payload)
          await this.reconcileRegistration(payload)
        } else if (request.url === "/event") {
          await this.processPluginEvent(payload)
        } else if (request.url === "/unregister") {
          await this.unregisterInstance(payload.instanceID)
        } else if (request.url === "/phone-mode/toggle") {
          responseBody = { ok: true, phoneMode: await this.togglePhoneMode() }
        } else {
          throw new Error("Not found")
        }
      })
      this.sendLocalResponse(response, 200, responseBody)
    } catch (error) {
      console.error("local request failed", error)
      this.sendLocalResponse(response, 400, { error: error.message })
    }
  }

  registerInstance(payload) {
    const instanceID = String(payload.instanceID ?? "")
    if (!instanceID || !isLoopbackURL(payload.serverURL) || !payload.directory) {
      throw new Error("Invalid OpenCode registration")
    }
    this.instances.set(instanceID, {
      instanceID,
      serverURL: payload.serverURL,
      directory: payload.directory,
      kittySession: String(payload.kittySession ?? ""),
      kittyWindowID: String(payload.kittyWindowID ?? ""),
      sessions: Array.isArray(payload.sessions) ? payload.sessions : [],
      attention: Array.isArray(payload.attention) ? payload.attention : [],
      lastSeen: this.now(),
    })
  }

  async reconcileRegistration(payload) {
    if (!Array.isArray(payload.attention)) return
    const instanceID = String(payload.instanceID)
    const pendingKeys = new Set()
    for (const session of payload.sessions ?? []) {
      if (["busy", "retry"].includes(session?.status)) {
        delete this.state.abortSuppressions[`${instanceID}:${session.id}`]
      }
    }
    for (const event of payload.attention) {
      if (event?.action !== "attention" || !event.kind || !event.sessionID) continue
      pendingKeys.add(alertKey(instanceID, event))
      await this.processPluginEvent({ instanceID, event })
    }
    for (const alert of Object.values(this.state.alerts)) {
      if (alert.instanceID !== instanceID || alert.resolvedAt || pendingKeys.has(alert.key)) continue
      await this.resolveAlert(alert, "Resolved locally")
    }
    await this.saveState()
  }

  async unregisterInstance(instanceID) {
    instanceID = String(instanceID ?? "")
    this.instances.delete(instanceID)
    for (const key of Object.keys(this.state.abortSuppressions)) {
      if (key.startsWith(`${instanceID}:`)) delete this.state.abortSuppressions[key]
    }
    for (const alert of Object.values(this.state.alerts)) {
      if (alert.instanceID !== instanceID || alert.resolvedAt) continue
      await this.resolveAlert(alert, "OpenCode closed locally")
    }
    await this.saveState()
  }

  async processPluginEvent(payload) {
    const instanceID = String(payload.instanceID ?? "")
    const event = payload.event
    const instance = this.instances.get(instanceID)
    if (!instance || !event?.action || !event.sessionID) throw new Error("Unknown OpenCode instance or event")
    if (!["attention", "resolve", "resolve-session", "local-prompt"].includes(event.action)) {
      throw new Error("Invalid event action")
    }
    if (event.kind && !["done", "error", "permission", "question"].includes(event.kind)) {
      throw new Error("Invalid attention kind")
    }
    if (event.action === "attention" && !["done", "error", "permission", "question"].includes(event.kind)) {
      throw new Error("Attention kind is required")
    }
    instance.lastSeen = this.now()

    const suppressionKey = `${instanceID}:${event.sessionID}`
    if (
      event.action === "attention" &&
      event.kind === "error" &&
      String(event.details?.message ?? "").trim().toLowerCase() === "aborted"
    ) {
      this.state.abortSuppressions[suppressionKey] = this.now()
      await this.saveState()
      return
    }
    if (
      event.action === "attention" &&
      ["error", "done"].includes(event.kind) &&
      this.state.abortSuppressions[suppressionKey]
    ) {
      return
    }
    if (event.action === "resolve-session" && event.resolution === "Session resumed locally") {
      delete this.state.abortSuppressions[suppressionKey]
    }

    let immediate = false
    if (event.action === "attention") {
      const key = alertKey(instanceID, event)
      const existing = this.state.alerts[key]?.resolvedAt ? undefined : this.state.alerts[key]
      immediate = event.kind === "error" || this.state.phoneMode
      this.state.alerts[key] = {
        id: existing?.id ?? randomBytes(6).toString("hex"),
        key,
        instanceID,
        kind: event.kind,
        sessionID: event.sessionID,
        requestID: event.requestID ?? "",
        details: event.details ?? {},
        createdAt: existing?.createdAt ?? this.now(),
        dueAt: immediate ? this.now() : (existing?.dueAt ?? this.now() + this.attentionDelayMs),
        sentMessageID: existing?.sentMessageID,
        sentText: existing?.sentText,
        resolvedAt: undefined,
        resolution: undefined,
      }
    } else if (event.action === "resolve") {
      const alert = this.state.alerts[alertKey(instanceID, event)]
      if (alert && !alert.resolvedAt) await this.resolveAlert(alert, event.resolution ?? "Resolved locally")
    } else if (event.action === "resolve-session") {
      const kinds = new Set(event.kinds ?? ["done", "error", "question", "permission"])
      for (const alert of Object.values(this.state.alerts)) {
        if (alert.instanceID !== instanceID || alert.sessionID !== event.sessionID || alert.resolvedAt) continue
        if (kinds.has(alert.kind)) await this.resolveAlert(alert, event.resolution ?? "Resolved locally")
      }
    } else if (event.action === "local-prompt") {
      this.deactivatePhoneMode()
    }
    await this.saveState()
    if (immediate) await this.flushDueAlerts()
  }

  async activatePhoneMode() {
    this.state.phoneMode = true
    for (const alert of Object.values(this.state.alerts)) {
      if (!alert.resolvedAt && !alert.sentMessageID) alert.dueAt = this.now()
    }
    await this.saveState()
    await this.flushDueAlerts().catch((error) => console.error("phone mode alert flush failed", error.message))
  }

  deactivatePhoneMode() {
    if (!this.state.phoneMode) return
    this.state.phoneMode = false
    const dueAt = this.now() + this.attentionDelayMs
    for (const alert of Object.values(this.state.alerts)) {
      if (!alert.resolvedAt && !alert.sentMessageID) alert.dueAt = dueAt
    }
  }

  async togglePhoneMode() {
    if (this.state.phoneMode) {
      this.deactivatePhoneMode()
      await this.saveState()
    } else {
      await this.activatePhoneMode()
    }
    return this.state.phoneMode
  }

  instanceForAlert(alert) {
    return this.instances.get(alert.instanceID)
  }

  async opencodeRequest(instance, path, options = {}) {
    const url = new URL(path, instance.serverURL)
    const method = String(options.method ?? "GET").toUpperCase()
    const apiV2 = url.pathname.startsWith("/api/")
    if (method === "GET" || method === "HEAD") {
      url.searchParams.set("directory", instance.directory)
      if (apiV2) url.searchParams.set("location[directory]", instance.directory)
    }
    const response = await this.fetch(url, {
      ...options,
      headers: {
        Authorization: `Bearer ${this.localSecret}`,
        "Content-Type": "application/json",
        ...(method === "GET" || method === "HEAD"
          ? {}
          : { "x-opencode-directory": encodeURIComponent(instance.directory) }),
        ...(options.headers ?? {}),
      },
      signal: AbortSignal.timeout(5000),
    })
    if (!response.ok) throw new Error(`OpenCode returned HTTP ${response.status}`)
    if (response.status === 204) return undefined
    return response.json()
  }

  async validateAlert(alert) {
    const instance = this.instanceForAlert(alert)
    if (!instance) return null
    const age = this.now() - instance.lastSeen
    if (age > INSTANCE_STALE_MS) return null

    try {
      if (alert.kind === "question") {
        const pendingResponse = alert.details?.apiVersion === "v2"
          ? await this.opencodeRequest(instance, `/api/session/${encodeURIComponent(alert.sessionID)}/question`)
          : await this.opencodeRequest(instance, "/question")
        const pending = alert.details?.apiVersion === "v2" ? pendingResponse?.data : pendingResponse
        return Array.isArray(pending) && pending.some((item) => item.id === alert.requestID)
      }
      if (alert.kind === "permission") {
        if (alert.details?.apiVersion === "deprecated") {
          return instance.attention.some((event) => alertKey(instance.instanceID, event) === alert.key)
        }
        const pendingResponse = alert.details?.apiVersion === "v2"
          ? await this.opencodeRequest(instance, `/api/session/${encodeURIComponent(alert.sessionID)}/permission`)
          : await this.opencodeRequest(instance, "/permission")
        const pending = alert.details?.apiVersion === "v2" ? pendingResponse?.data : pendingResponse
        return Array.isArray(pending) && pending.some((item) => item.id === alert.requestID)
      }
      if (alert.kind === "done") {
        const statuses = await this.opencodeRequest(instance, "/session/status")
        return !statuses?.[alert.sessionID] || statuses[alert.sessionID].type === "idle"
      }
      return true
    } catch (error) {
      console.error("attention validation failed", alert.key, error.message)
      return null
    }
  }

  async shouldWithholdForLocalActivity(alert) {
    if (alert.kind === "error") return false
    const instance = this.instanceForAlert(alert)
    if (!instance) return false

    try {
      const context = await this.opencodeRequest(instance, "/attention-context")
      const idleMilliseconds = Number(context?.idleMilliseconds)
      return context?.available === true &&
        context.focused === true &&
        Number.isFinite(idleMilliseconds) &&
        idleMilliseconds >= 0 &&
        idleMilliseconds <= RECENT_LOCAL_ACTIVITY_MS
    } catch {
      return false
    }
  }

  async sessionInfo(alert) {
    const instance = this.instanceForAlert(alert)
    if (!instance) return { title: alert.sessionID, summary: "" }
    let title = alert.sessionID
    let summary = ""
    try {
      const session = await this.opencodeRequest(instance, `/session/${encodeURIComponent(alert.sessionID)}`)
      title = session?.title || title
      if (alert.kind === "done") {
        const messages = await this.opencodeRequest(
          instance,
          `/session/${encodeURIComponent(alert.sessionID)}/message?limit=20`,
        )
        const assistant = Array.isArray(messages)
          ? [...messages].reverse().find((item) => item?.info?.role === "assistant")
          : undefined
        summary = truncate(
          assistant?.parts
            ?.filter((part) => part.type === "text")
            .map((part) => part.text)
            .join(" "),
          COMPLETION_SUMMARY_LIMIT,
        )
      }
    } catch (error) {
      console.error("session details unavailable", alert.key, error.message)
    }
    return { title, summary }
  }

  async alertPresentation(alert) {
    const instance = this.instanceForAlert(alert)
    const { title, summary } = await this.sessionInfo(alert)
    const prefix = instance?.kittySession ? `${instance.kittySession} | ${title}` : title
    const details = alert.details ?? {}
    let text = ""
    let inline_keyboard = []

    if (alert.kind === "permission") {
      const target = truncate((details.patterns ?? []).join(", "), 350)
      text = `Permission required\n\n${prefix}\n${details.permission ?? "tool"}${target ? `: ${target}` : ""}`
      inline_keyboard = [[
        { text: "Once", callback_data: `p:${alert.id}:once` },
        { text: "Always", callback_data: `p:${alert.id}:always` },
        { text: "Reject", callback_data: `p:${alert.id}:reject` },
      ]]
    } else if (alert.kind === "question") {
      const questions = Array.isArray(details.questions) ? details.questions : []
      text = `Question requires an answer\n\n${prefix}`
      for (const [index, question] of questions.entries()) {
        text += `\n\n${index + 1}. ${truncate(question.question, 500)}`
        if (question.options?.length) text += `\n${question.options.map((option) => `- ${option.label}`).join("\n")}`
      }
      text += "\n\nReply to this message to provide a custom answer."
      if (questions.length === 1 && !questions[0].multiple && questions[0].options?.length <= 8) {
        inline_keyboard = questions[0].options.map((option, index) => [
          { text: truncate(option.label, 40), callback_data: `q:${alert.id}:${index}` },
        ])
      }
    } else if (alert.kind === "error") {
      text = `OpenCode error\n\n${prefix}\n${truncate(details.message ?? "Session failed", 500)}`
    } else {
      text = `OpenCode is waiting for your next prompt\n\n${prefix}`
      if (summary) text += `\n\n${summary}`
      text += "\n\nReply to this message to continue the same session."
    }

    return { text: truncate(text, TELEGRAM_TEXT_LIMIT), reply_markup: { inline_keyboard } }
  }

  async flushDueAlerts() {
    if (this.flushPromise) return this.flushPromise
    this.flushPromise = this.flushDueAlertsInternal().finally(() => {
      this.flushPromise = undefined
    })
    return this.flushPromise
  }

  async flushDueAlertsInternal() {
    for (const alert of Object.values(this.state.alerts)) {
      if (alert.resolvedAt || alert.sentMessageID || alert.dueAt > this.now()) continue
      if (await this.shouldWithholdForLocalActivity(alert)) continue
      const valid = await this.validateAlert(alert)
      if (valid === false) {
        await this.resolveAlert(alert, "Resolved before Telegram notification")
        continue
      }
      if (valid === null) continue
      if (alert.resolvedAt || alert.sentMessageID) continue

      const presentation = await this.alertPresentation(alert)
      if (alert.resolvedAt || alert.sentMessageID) continue
      const message = await this.telegram("sendMessage", {
        chat_id: this.chatID,
        text: presentation.text,
        reply_markup: presentation.reply_markup,
      })
      alert.sentMessageID = message.message_id
      alert.sentText = presentation.text
      await this.saveState()
    }
  }

  async resolveAlert(alert, resolution) {
    alert.resolvedAt = this.now()
    alert.resolution = resolution
    if (alert.sentMessageID) {
      const text = truncate(`${alert.sentText ?? "OpenCode attention"}\n\n${resolution}`, TELEGRAM_TEXT_LIMIT)
      await this.telegram("editMessageText", {
        chat_id: this.chatID,
        message_id: alert.sentMessageID,
        text,
        reply_markup: { inline_keyboard: [] },
      }).catch((error) => console.error("could not update resolved Telegram alert", error.message))
    }
  }

  findAlertByID(id) {
    return Object.values(this.state.alerts).find((alert) => alert.id === id)
  }

  findAlertByMessageID(messageID) {
    return Object.values(this.state.alerts).find((alert) => alert.sentMessageID === messageID)
  }

  async answerPermission(alert, reply, activatePhoneMode = true) {
    const instance = this.actionableInstance(alert)
    let path
    let body = { reply }
    if (alert.details?.apiVersion === "v2") {
      path = `/api/session/${encodeURIComponent(alert.sessionID)}/permission/${encodeURIComponent(alert.requestID)}/reply`
    } else if (alert.details?.apiVersion === "deprecated") {
      path = `/session/${encodeURIComponent(alert.sessionID)}/permissions/${encodeURIComponent(alert.requestID)}`
      body = { response: reply }
    } else {
      path = `/permission/${encodeURIComponent(alert.requestID)}/reply`
    }
    if (activatePhoneMode) await this.activatePhoneMode()
    await this.opencodeRequest(instance, path, {
      method: "POST",
      body: JSON.stringify(body),
    })
    await this.resolveAlert(alert, `Answered from Telegram: ${reply}`)
    await this.saveState()
  }

  async answerQuestion(alert, answers) {
    const instance = this.actionableInstance(alert)
    const path = alert.details?.apiVersion === "v2"
      ? `/api/session/${encodeURIComponent(alert.sessionID)}/question/${encodeURIComponent(alert.requestID)}/reply`
      : `/question/${encodeURIComponent(alert.requestID)}/reply`
    await this.activatePhoneMode()
    await this.opencodeRequest(instance, path, {
      method: "POST",
      body: JSON.stringify({ answers }),
    })
    await this.resolveAlert(alert, "Answered from Telegram")
    await this.saveState()
  }

  async continueSession(alert, text, agentOverride) {
    const instance = this.actionableInstance(alert)
    const statuses = await this.opencodeRequest(instance, "/session/status")
    if (["busy", "retry"].includes(statuses?.[alert.sessionID]?.type)) {
      throw new Error("That OpenCode session is currently active")
    }
    const messages = await this.opencodeRequest(
      instance,
      `/session/${encodeURIComponent(alert.sessionID)}/message?limit=20`,
    )
    const latestUser = Array.isArray(messages)
      ? [...messages].reverse().find((item) => item?.info?.role === "user")?.info
      : undefined
    const body = { parts: [{ type: "text", text }] }
    if (agentOverride) body.agent = agentOverride
    else if (latestUser?.agent) body.agent = latestUser.agent
    if (latestUser?.model?.providerID && latestUser?.model?.modelID) {
      body.model = {
        providerID: latestUser.model.providerID,
        modelID: latestUser.model.modelID,
      }
    }
    await this.activatePhoneMode()
    await this.opencodeRequest(instance, `/session/${encodeURIComponent(alert.sessionID)}/prompt_async`, {
      method: "POST",
      body: JSON.stringify(body),
    })
    await this.resolveAlert(alert, "Continued from Telegram")
    await this.saveState()
  }

  async abortSession(alert) {
    const instance = this.actionableInstance(alert)
    const suppressionKey = `${alert.instanceID}:${alert.sessionID}`
    if (alert.kind === "question") {
      const path = alert.details?.apiVersion === "v2"
        ? `/api/session/${encodeURIComponent(alert.sessionID)}/question/${encodeURIComponent(alert.requestID)}/reject`
        : `/question/${encodeURIComponent(alert.requestID)}/reject`
      await this.opencodeRequest(instance, path, { method: "POST" })
    } else if (alert.kind === "permission") {
      await this.answerPermission(alert, "reject", false)
    }
    this.state.abortSuppressions[suppressionKey] = this.now()
    await this.saveState()
    try {
      await this.opencodeRequest(instance, `/session/${encodeURIComponent(alert.sessionID)}/abort`, { method: "POST" })
    } catch (error) {
      delete this.state.abortSuppressions[suppressionKey]
      await this.saveState()
      throw error
    }
    if (!alert.resolvedAt) await this.resolveAlert(alert, "Aborted from Telegram")
    await this.saveState()
  }

  actionableInstance(alert) {
    const instance = this.instanceForAlert(alert)
    if (!instance || this.now() - instance.lastSeen > INSTANCE_STALE_MS) {
      throw new Error("OpenCode instance is no longer registered")
    }
    return instance
  }

  async handleCallback(query) {
    const callbackChatID = query.message?.chat?.id
    if (String(query.from?.id) !== this.allowedUserID || String(callbackChatID) !== this.chatID) {
      await this.telegram("answerCallbackQuery", {
        callback_query_id: query.id,
        text: "Unauthorized",
        show_alert: true,
      })
      return
    }
    const [type, alertID, value] = String(query.data ?? "").split(":")
    const alert = this.findAlertByID(alertID)
    let acknowledged = false
    try {
      if (!alert || alert.resolvedAt) throw new Error("This request is no longer pending")
      await this.telegram("answerCallbackQuery", {
        callback_query_id: query.id,
        text: "Sending to OpenCode...",
      })
      acknowledged = true
      if (type === "p") {
        if (!["once", "always", "reject"].includes(value)) throw new Error("Unknown permission response")
        await this.answerPermission(alert, value)
      } else if (type === "q") {
        const question = alert.details?.questions?.[0]
        const option = question?.options?.[Number(value)]
        if (!option) throw new Error("Question option is no longer available")
        await this.answerQuestion(alert, [[option.label]])
      } else {
        throw new Error("Unknown action")
      }
    } catch (error) {
      if (!acknowledged) {
        await this.telegram("answerCallbackQuery", {
          callback_query_id: query.id,
          text: truncate(error.message, 180),
          show_alert: true,
        })
      }
      await this.telegram("sendMessage", { chat_id: this.chatID, text: `Could not respond: ${error.message}` })
    }
  }

  async handleMessage(message) {
    if (String(message.from?.id) !== this.allowedUserID || String(message.chat?.id) !== this.chatID) return
    const text = String(message.text ?? "").trim()
    if (!text) return

    if (text === "/start") {
      await this.telegram("sendMessage", { chat_id: this.chatID, text: "OpenCode Telegram bridge is connected." })
      return
    }
    if (text === "/status" || text === "/sessions") {
      const lines = [`OpenCode instances: ${this.instances.size}`, `Phone mode: ${this.state.phoneMode ? "on" : "off"}`]
      for (const instance of this.instances.values()) {
        const roots = instance.sessions.filter((session) => !session.parentID)
        if (!roots.length) lines.push(`- ${instance.kittySession || instance.directory}`)
        for (const session of roots) {
          lines.push(`- ${instance.kittySession || instance.directory} | ${session.title || session.id} (${session.status})`)
        }
      }
      await this.telegram("sendMessage", { chat_id: this.chatID, text: truncate(lines.join("\n"), TELEGRAM_TEXT_LIMIT) })
      return
    }

    const repliedMessageID = message.reply_to_message?.message_id
    const alert = repliedMessageID ? this.findAlertByMessageID(repliedMessageID) : undefined
    const agentCommand = text.match(/^\/(build|plan)(?:@\w+)?(?:\s+([\s\S]*))?$/i)
    const agentOverride = agentCommand?.[1]?.toLowerCase()
    const agentPrompt = agentCommand?.[2]?.trim()
    if (text === "/abort") {
      if (!alert) {
        await this.telegram("sendMessage", { chat_id: this.chatID, text: "Reply to an OpenCode notification with /abort." })
        return
      }
      try {
        await this.abortSession(alert)
        await this.telegram("sendMessage", { chat_id: this.chatID, text: "Abort sent to OpenCode." })
      } catch (error) {
        await this.telegram("sendMessage", { chat_id: this.chatID, text: `Abort failed: ${error.message}` })
      }
      return
    }
    if (!alert || alert.resolvedAt) {
      await this.telegram("sendMessage", {
        chat_id: this.chatID,
        text: "Reply directly to a pending OpenCode notification so I know which session should receive it.",
      })
      return
    }

    try {
      if (agentCommand && ["question", "permission"].includes(alert.kind)) {
        throw new Error("Use mode commands only when replying to a completion or error notification")
      }
      if (alert.kind === "question") {
        const questions = alert.details?.questions ?? []
        const lines = text.split("\n").map((line) => line.trim()).filter(Boolean)
        if (questions.length > 1 && lines.length !== questions.length) {
          throw new Error(`Reply with ${questions.length} non-empty lines, one answer per question`)
        }
        await this.answerQuestion(alert, questions.length > 1 ? lines.map((line) => [line]) : [[text]])
      } else if (alert.kind === "permission") {
        throw new Error("Use the Once, Always, or Reject buttons")
      } else {
        if (agentCommand && !agentPrompt) throw new Error(`Use /${agentOverride} followed by a prompt`)
        await this.continueSession(alert, agentPrompt ?? text, agentOverride)
      }
      const confirmation = agentOverride ? `Sent to OpenCode in ${agentOverride} mode.` : "Sent to OpenCode."
      await this.telegram("sendMessage", { chat_id: this.chatID, text: confirmation })
    } catch (error) {
      await this.telegram("sendMessage", { chat_id: this.chatID, text: `Could not respond: ${error.message}` })
    }
  }

  async handleTelegramUpdate(update) {
    if (update.callback_query) await this.handleCallback(update.callback_query)
    if (update.message) await this.handleMessage(update.message)
  }

  async pollTelegram() {
    while (this.running) {
      try {
        const updates = await this.telegram("getUpdates", {
          offset: this.state.updateOffset,
          timeout: 25,
          allowed_updates: ["message", "callback_query"],
        }, 35000)
        for (const update of updates) {
          await this.enqueue(async () => {
            this.state.updateOffset = Math.max(this.state.updateOffset, update.update_id + 1)
            await this.handleTelegramUpdate(update)
          })
        }
        if (updates.length) await this.enqueue(() => this.saveState())
      } catch (error) {
        if (this.running) console.error("Telegram polling failed", error.message)
        await sleep(2000)
      }
    }
  }

  async telegram(method, body, timeout = 10000) {
    const response = await this.fetch(`https://api.telegram.org/bot${this.botToken}/${method}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(timeout),
    })
    const result = await response.json()
    if (!response.ok || !result.ok) throw new Error(result.description || `Telegram returned HTTP ${response.status}`)
    return result.result
  }
}

async function loadPrivateFile(path) {
  const metadata = await lstat(path)
  if (!metadata.isFile() || metadata.isSymbolicLink()) throw new Error(`Configuration must be a regular file: ${path}`)
  if (metadata.uid !== process.getuid()) throw new Error(`Configuration is not owned by the current user: ${path}`)
  if ((metadata.mode & 0o777) !== 0o600) throw new Error(`Configuration permissions must be 0600: ${path}`)
  return readFile(path, "utf8")
}

async function loadCredentials(path, secretPath) {
  const credentials = JSON.parse(await loadPrivateFile(path))
  const localSecret = (await loadPrivateFile(secretPath)).trim()
  const botToken = String(credentials.bot_token ?? "")
  const allowedUserID = String(credentials.allowed_user_id ?? "")
  const chatID = String(credentials.chat_id ?? allowedUserID)
  const attentionDelaySeconds = credentials.attention_delay_seconds ?? DEFAULT_DELAY_MS / 1000
  if (!/^\d+:[A-Za-z0-9_-]+$/.test(botToken)) throw new Error("Invalid bot_token in credentials file")
  if (!/^\d+$/.test(allowedUserID) || !/^-?\d+$/.test(chatID)) throw new Error("Invalid Telegram user or chat ID")
  if (!/^[a-f0-9]{64}$/.test(localSecret)) throw new Error("Invalid local bridge secret")
  if (!Number.isInteger(attentionDelaySeconds) || attentionDelaySeconds < 5 || attentionDelaySeconds > 3600) {
    throw new Error("attention_delay_seconds must be an integer between 5 and 3600")
  }
  return {
    botToken,
    allowedUserID,
    chatID,
    localSecret,
    attentionDelayMs: attentionDelaySeconds * 1000,
  }
}

export async function main() {
  const configDirectory = `${process.env.HOME}/.config/opencode-telegram-bridge`
  const credentials = await loadCredentials(
    `${configDirectory}/credentials.json`,
    `${configDirectory}/plugin-secret`,
  )
  const bridge = new TelegramBridge({
    ...credentials,
    stateFile: `${configDirectory}/state.json`,
  })
  const shutdown = async () => {
    await bridge.stop()
    process.exit(0)
  }
  process.on("SIGINT", shutdown)
  process.on("SIGTERM", shutdown)
  await bridge.start()
  console.log(`OpenCode Telegram bridge listening on http://${LOOPBACK_HOST}:${DEFAULT_PORT}`)
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((error) => {
    console.error(error)
    process.exit(1)
  })
}
