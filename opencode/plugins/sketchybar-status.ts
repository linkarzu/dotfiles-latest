import type { Plugin } from "@opencode-ai/plugin"
import { readFile } from "node:fs/promises"

type AttentionReason = "done" | "error" | "permission" | "question"
type SessionState = {
  parentID?: string
  title?: string
  status: "busy" | "idle" | "retry"
  attention: Map<string, { reason: AttentionReason; generation: number }>
}
type RuntimeEvent = {
  type: string
  properties: Record<string, any>
}

const kittyBin = "/Applications/kitty.app/Contents/MacOS/kitty"
const sketchybarBin = "/opt/homebrew/bin/sketchybar"
const telegramBridgeURL = "http://127.0.0.1:47653"
const focusAcknowledgementDelayMs = 2_000
const phoneModeSystem = [
  "The user is reading this response in Telegram on a narrow phone screen.",
  "Keep the final response at or below 3,500 characters whenever practical.",
  "Use phone-friendly plain text with short section labels, hyphen bullets, or numbered steps.",
  "Do not use Markdown tables, multi-column layouts, or complex formatting; convert tabular information into labeled bullets.",
  "Use simple code blocks only when they are essential.",
].join(" ")
const proxyRoutes = [
  ["GET", /^\/attention-context$/],
  ["GET", /^\/question$/],
  ["GET", /^\/permission$/],
  ["GET", /^\/api\/session\/[^/]+\/(question|permission)$/],
  ["GET", /^\/session\/status$/],
  ["GET", /^\/session\/[^/]+$/],
  ["GET", /^\/session\/[^/]+\/message$/],
  ["POST", /^\/telegram-selection$/],
  ["POST", /^\/permission\/[^/]+\/reply$/],
  ["POST", /^\/question\/[^/]+\/reply$/],
  ["POST", /^\/question\/[^/]+\/reject$/],
  ["POST", /^\/session\/[^/]+\/permissions\/[^/]+$/],
  ["POST", /^\/api\/session\/[^/]+\/(permission|question)\/[^/]+\/reply$/],
  ["POST", /^\/api\/session\/[^/]+\/question\/[^/]+\/reject$/],
  ["POST", /^\/session\/[^/]+\/(prompt_async|abort)$/],
] as const
const trackedEvents = new Set([
  "session.created",
  "session.updated",
  "session.deleted",
  "session.status",
  "session.error",
  "permission.asked",
  "permission.v2.asked",
  "permission.updated",
  "permission.replied",
  "permission.v2.replied",
  "question.asked",
  "question.v2.asked",
  "question.replied",
  "question.rejected",
  "question.v2.replied",
  "question.v2.rejected",
])

export const SketchybarStatusPlugin: Plugin = async ({ client, directory, $ }) => {
  const kittyPID = process.env.KITTY_PID
  const windowID = process.env.KITTY_WINDOW_ID
  if (!kittyPID || !windowID || !$) return {}

  const socket = `unix:/tmp/kitty-${kittyPID}`
  const instanceID = `${kittyPID}:${windowID}`
  const initialAcknowledgement = `${instanceID}:0`
  const sessions = new Map<string, SessionState>()
  const bridgeAttention = new Map<string, Record<string, any>>()
  const bridgeSecret = await readFile(`${process.env.HOME}/.config/opencode-telegram-bridge/plugin-secret`, "utf8")
    .then((value) => value.trim())
    .catch(() => "")
  let lastPublished = ""
  let generation = 0
  let focusedAttentionSince = 0
  let queue = Promise.resolve()
  let bridgeQueue = Promise.resolve()
  let publishQueue = Promise.resolve()
  let proxyServer: any
  let proxyURL = ""
  let activeSessionID: string | undefined
  const telegramPromptSessions = new Set<string>()

  async function postBridge(path: string, body: unknown) {
    if (!bridgeSecret) return false
    const response = await fetch(`${telegramBridgeURL}${path}`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${bridgeSecret}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(1500),
    }).catch(() => undefined)
    return response?.ok ?? false
  }

  async function phoneModeEnabled() {
    if (!bridgeSecret) return false
    const response = await fetch(`${telegramBridgeURL}/health`, {
      signal: AbortSignal.timeout(500),
    }).catch(() => undefined)
    if (!response?.ok) return false
    const health = await response.json().catch(() => undefined) as { phoneMode?: boolean } | undefined
    return health?.phoneMode === true
  }

  function bridgeEventKey(event: Record<string, any>) {
    return `${event.sessionID}:${event.kind}:${event.requestID ?? event.sessionID}`
  }

  function rootSessionID(sessionID: string) {
    const seen = new Set<string>()
    let current = sessionID
    while (!seen.has(current)) {
      seen.add(current)
      const parentID = sessions.get(current)?.parentID
      if (!parentID) return current
      current = parentID
    }
    return current
  }

  function sessionIsActive(sessionID: string) {
    if (activeSessionID === undefined) return true
    if (!activeSessionID) return false
    return rootSessionID(activeSessionID) === rootSessionID(sessionID)
  }

  function applySessionSelection(sessionID: string) {
    activeSessionID = sessionID
    let changed = false
    for (const [sessionID, current] of sessions) {
      if (sessionIsActive(sessionID)) continue
      if (current.attention.size) changed = true
      current.attention.clear()
    }
    for (const [key, pending] of bridgeAttention) {
      if (!sessionIsActive(pending.sessionID)) bridgeAttention.delete(key)
    }
    return changed
  }

  function trackBridgeEvent(event: Record<string, any>) {
    if (event.action === "attention") {
      bridgeAttention.set(bridgeEventKey(event), event)
      return
    }
    if (event.action === "resolve") {
      bridgeAttention.delete(bridgeEventKey(event))
      return
    }
    if (event.action === "resolve-session") {
      const kinds = new Set(event.kinds ?? ["done", "error", "permission", "question"])
      for (const [key, pending] of bridgeAttention) {
        if (pending.sessionID === event.sessionID && kinds.has(pending.kind)) bridgeAttention.delete(key)
      }
      return
    }
    if (event.action === "local-prompt") {
      for (const [key, pending] of bridgeAttention) {
        if (pending.sessionID === event.sessionID && (pending.kind === "done" || pending.kind === "error")) {
          bridgeAttention.delete(key)
        }
      }
    }
  }

  async function proxyRequest(request: Request) {
    const url = new URL(request.url)
    const allowed = proxyRoutes.some(([method, pattern]) => request.method === method && pattern.test(url.pathname))
    if (
      !allowed ||
      request.headers.has("Origin") ||
      request.headers.get("Authorization") !== `Bearer ${bridgeSecret}`
    ) {
      return Response.json({ error: "Forbidden" }, { status: 403 })
    }

    if (request.method === "GET" && url.pathname === "/attention-context") {
      const windowState = await kittyWindowState()
      const idleResponse = await $`/usr/sbin/ioreg -c IOHIDSystem -d 1 -r`.quiet().nothrow()
      const idleMatch = idleResponse.exitCode === 0
        ? idleResponse.text().match(/"HIDIdleTime"\s*=\s*(\d+)/)
        : undefined
      let idleMilliseconds: number | undefined
      if (idleMatch) {
        try {
          idleMilliseconds = Number(BigInt(idleMatch[1]) / 1_000_000n)
        } catch {
          idleMilliseconds = undefined
        }
      }
      return Response.json({
        available: windowState !== undefined && idleMilliseconds !== undefined,
        focused: windowState?.focused === true,
        idleMilliseconds: idleMilliseconds ?? null,
      })
    }

    const apiClient = (client as any)._client
    const method = request.method.toLowerCase() as "get" | "post"
    const body = request.method === "POST" ? await request.json().catch(() => undefined) : undefined
    if (request.method === "POST" && url.pathname === "/telegram-selection") {
      if (applySessionSelection(String(body?.sessionID ?? ""))) await publish()
      return Response.json({ ok: true })
    }
    const promptMatch = request.method === "POST" && url.pathname.match(/^\/session\/([^/]+)\/prompt_async$/)
    const telegramPromptSessionID = promptMatch ? decodeURIComponent(promptMatch[1]) : undefined
    if (telegramPromptSessionID) telegramPromptSessions.add(telegramPromptSessionID)
    let result: any
    try {
      result = await apiClient[method]({
        url: url.pathname,
        query: Object.fromEntries(url.searchParams),
        body,
      })
    } finally {
      if (telegramPromptSessionID) telegramPromptSessions.delete(telegramPromptSessionID)
    }
    const status = result.response?.status ?? (result.error ? 500 : 200)
    if (telegramPromptSessionID && status < 400) {
      const current = sessions.get(telegramPromptSessionID)
      current?.attention.delete("done")
      current?.attention.delete("error")
      sendBridgeEvent({
        action: "resolve-session",
        sessionID: telegramPromptSessionID,
        kinds: ["done", "error"],
        resolution: "Continued from Telegram",
      })
    }
    if (status === 204) return new Response(null, { status })
    return Response.json(result.error ?? result.data ?? {}, { status })
  }

  function session(sessionID: string) {
    let current = sessions.get(sessionID)
    if (!current) {
      current = { status: "idle", attention: new Map() }
      sessions.set(sessionID, current)
    }
    return current
  }

  async function loadSession(sessionID: string) {
    const current = session(sessionID)
    if (current.parentID !== undefined) return current

    const response = await client.session.get({ path: { id: sessionID } }).catch(() => undefined)
    if (response?.data) {
      current.parentID = response.data.parentID ?? ""
      current.title = response.data.title
    }
    return current
  }

  function removeRequest(sessionID: string, requestID: string) {
    const current = sessions.get(sessionID)
    current?.attention.delete(`permission:${requestID}`)
    current?.attention.delete(`question:${requestID}`)
  }

  function addAttention(current: SessionState, key: string, reason: AttentionReason) {
    generation++
    focusedAttentionSince = 0
    current.attention.set(key, { reason, generation })
  }

  function aggregate() {
    let busy = 0
    let waiting = 0
    const reasons = new Set<AttentionReason>()

    for (const current of sessions.values()) {
      if (current.status === "busy" || current.status === "retry") busy++
      if (current.attention.size === 0) continue
      waiting++
      for (const attention of current.attention.values()) reasons.add(attention.reason)
    }

    const reason: AttentionReason | "none" = reasons.has("error")
      ? "error"
      : reasons.has("permission")
        ? "permission"
        : reasons.has("question")
          ? "question"
          : reasons.has("done")
            ? "done"
            : "none"

    return { busy, waiting, reason }
  }

  async function kittyWindowState() {
    const response = await $`${kittyBin} @ --to ${socket} ls --match id:${windowID}`.quiet().nothrow()
    if (response.exitCode !== 0) return undefined

    try {
      const tree = response.json() as Array<{
        is_focused?: boolean
        tabs?: Array<{
          is_focused?: boolean
          windows?: Array<{
            is_focused?: boolean
            session_name?: string
            user_vars?: Record<string, string>
          }>
        }>
      }>
      const osWindow = tree[0]
      const tab = osWindow?.tabs?.[0]
      const window = tab?.windows?.[0]
      return {
        acknowledgement: window?.user_vars?.opencode_ack ?? "",
        focused: Boolean(osWindow?.is_focused && tab?.is_focused && window?.is_focused),
        sessionName: window?.session_name ?? "",
      }
    } catch {
      return undefined
    }
  }

  async function registerBridge() {
    if (!proxyURL) return
    const windowState = await kittyWindowState()
    await postBridge("/register", {
      instanceID,
      serverURL: proxyURL,
      directory,
      kittySession: windowState?.sessionName ?? "",
      kittyWindowID: windowID,
      sessions: [...sessions].map(([id, current]) => ({
        id,
        parentID: current.parentID || undefined,
        title: current.title,
        status: current.status,
      })),
      attention: [...bridgeAttention.values()],
    })
  }

  function scheduleBridgeRegistration() {
    bridgeQueue = bridgeQueue.then(registerBridge).catch(() => undefined)
  }

  function queueBridgeEvent(event: Record<string, unknown>) {
    trackBridgeEvent(event)
    const pending = bridgeQueue
      .then(async () => {
        await registerBridge()
        await postBridge("/event", { instanceID, event })
      })
      .catch(() => undefined)
    bridgeQueue = pending
    return pending
  }

  function sendBridgeEvent(event: Record<string, unknown>) {
    void queueBridgeEvent(event)
  }

  function acknowledgeThrough(acknowledgedGeneration: number) {
    let changed = false
    let bridgeChanged = false
    for (const [sessionID, current] of sessions) {
      for (const [key, attention] of current.attention) {
        if (attention.generation > acknowledgedGeneration) continue
        current.attention.delete(key)
        if (attention.reason === "done") {
          bridgeAttention.delete(`${sessionID}:${attention.reason}:${sessionID}`)
          bridgeChanged = true
        }
        changed = true
      }
    }
    if (bridgeChanged) scheduleBridgeRegistration()
    return changed
  }

  async function applyAcknowledgement() {
    const state = await kittyWindowState()
    let changed = false

    if (state?.acknowledgement.startsWith(`${instanceID}:`)) {
      const acknowledgedGeneration = Number(state.acknowledgement.slice(instanceID.length + 1))
      if (Number.isFinite(acknowledgedGeneration)) changed = acknowledgeThrough(acknowledgedGeneration)
    }

    if (aggregate().waiting === 0) {
      focusedAttentionSince = 0
      return changed
    }
    if (!state?.focused) {
      focusedAttentionSince = 0
      return changed
    }

    const now = Date.now()
    if (focusedAttentionSince === 0) {
      focusedAttentionSince = now
      return changed
    }
    if (now - focusedAttentionSince < focusAcknowledgementDelayMs) return changed

    const acknowledgedGeneration = generation
    const acknowledgement = `${instanceID}:${acknowledgedGeneration}`
    const result = await $`${kittyBin} @ --to ${socket} set-user-vars --match id:${windowID} opencode_ack=${acknowledgement}`
      .quiet()
      .nothrow()
    if (result.exitCode !== 0) return changed

    focusedAttentionSince = 0
    return acknowledgeThrough(acknowledgedGeneration) || changed
  }

  async function publishNow(force = false) {
    const state = aggregate()
    const serialized = `${state.busy}:${state.waiting}:${state.reason}:${generation}`
    if (!force && serialized === lastPublished) return

    const result = await $`${kittyBin} @ --to ${socket} set-user-vars --match id:${windowID} opencode_busy=${String(state.busy)} opencode_waiting=${String(state.waiting)} opencode_reason=${state.reason} opencode_instance=${instanceID} opencode_generation=${String(generation)}`
      .quiet()
      .nothrow()
    if (result.exitCode !== 0) return

    lastPublished = serialized
    await $`${sketchybarBin} --trigger opencode_update`.quiet().nothrow()
  }

  function publish(force = false) {
    const pending = publishQueue.then(() => publishNow(force))
    publishQueue = pending.catch(() => undefined)
    return pending
  }

  async function handle(input: RuntimeEvent) {
    const properties = input.properties ?? {}

    switch (input.type) {
      case "session.created":
      case "session.updated": {
        const info = properties.info
        if (!info?.id) return false
        const current = session(info.id)
        current.parentID = info.parentID ?? ""
        current.title = info.title
        return false
      }
      case "session.deleted": {
        if (properties.info?.id) {
          await sendBridgeEvent({
            action: "resolve-session",
            sessionID: properties.info.id,
            resolution: "Session deleted locally",
          })
          sessions.delete(properties.info.id)
        }
        break
      }
      case "session.status": {
        const sessionID = properties.sessionID
        const status = properties.status?.type
        if (!sessionID || !["busy", "idle", "retry"].includes(status)) return false

        const current = session(sessionID)
        const wasActive = current.status === "busy" || current.status === "retry"
        current.status = status

        if (status === "busy" || status === "retry") {
          current.attention.delete("done")
          await sendBridgeEvent({
            action: "resolve-session",
            sessionID,
            kinds: ["done"],
            resolution: "Session resumed locally",
          })
          break
        }

        if (wasActive) {
          await loadSession(sessionID)
          if (!sessionIsActive(sessionID)) break
          const windowState = await kittyWindowState()
          const pendingRequest = [...bridgeAttention.values()].some((event) => (
            event.sessionID === sessionID && (event.kind === "permission" || event.kind === "question")
          ))
          const pendingError = bridgeAttention.has(`${sessionID}:error:${sessionID}`)
          if (!current.parentID && !pendingRequest && !pendingError && !windowState?.focused) {
            addAttention(current, "done", "done")
          }
          if (!current.parentID && !pendingRequest && !pendingError) {
            await sendBridgeEvent({ action: "attention", kind: "done", sessionID })
          }
        }
        break
      }
      case "session.error": {
        const sessionID = properties.sessionID
        if (sessionID && sessionIsActive(sessionID)) {
          addAttention(session(sessionID), "error", "error")
          await sendBridgeEvent({
            action: "attention",
            kind: "error",
            sessionID,
            details: {
              message: properties.error?.data?.message ?? properties.error?.message ?? properties.error?.name,
            },
          })
        }
        break
      }
      case "permission.asked":
      case "permission.v2.asked":
      case "permission.updated": {
        const sessionID = properties.sessionID
        const requestID = properties.id
        if (sessionID && requestID && sessionIsActive(sessionID)) {
          addAttention(session(sessionID), `permission:${requestID}`, "permission")
          await sendBridgeEvent({
            action: "attention",
            kind: "permission",
            sessionID,
            requestID,
            details: {
              apiVersion: input.type === "permission.updated"
                ? "deprecated"
                : input.type.includes(".v2.")
                  ? "v2"
                  : "legacy",
              permission: properties.permission ?? properties.action ?? properties.type,
              patterns: properties.patterns ?? properties.resources ?? (
                Array.isArray(properties.pattern) ? properties.pattern : [properties.pattern].filter(Boolean)
              ),
            },
          })
        }
        break
      }
      case "permission.replied":
      case "permission.v2.replied": {
        if (properties.sessionID && properties.requestID) {
          removeRequest(properties.sessionID, properties.requestID)
          await sendBridgeEvent({
            action: "resolve",
            kind: "permission",
            sessionID: properties.sessionID,
            requestID: properties.requestID,
            resolution: "Permission answered locally",
          })
        }
        if (properties.sessionID && properties.permissionID) {
          removeRequest(properties.sessionID, properties.permissionID)
          await sendBridgeEvent({
            action: "resolve",
            kind: "permission",
            sessionID: properties.sessionID,
            requestID: properties.permissionID,
            resolution: "Permission answered locally",
          })
        }
        break
      }
      case "question.asked":
      case "question.v2.asked": {
        const sessionID = properties.sessionID
        const requestID = properties.id
        if (sessionID && requestID && sessionIsActive(sessionID)) {
          addAttention(session(sessionID), `question:${requestID}`, "question")
          await sendBridgeEvent({
            action: "attention",
            kind: "question",
            sessionID,
            requestID,
            details: {
              apiVersion: input.type.includes(".v2.") ? "v2" : "legacy",
              questions: properties.questions ?? [],
            },
          })
        }
        break
      }
      case "question.replied":
      case "question.rejected":
      case "question.v2.replied":
      case "question.v2.rejected": {
        if (properties.sessionID && properties.requestID) {
          removeRequest(properties.sessionID, properties.requestID)
          await sendBridgeEvent({
            action: "resolve",
            kind: "question",
            sessionID: properties.sessionID,
            requestID: properties.requestID,
            resolution: "Question answered locally",
          })
        }
        break
      }
      default:
        return false
    }

    return true
  }

  await $`${kittyBin} @ --to ${socket} set-user-vars --match id:${windowID} opencode_ack=${initialAcknowledgement}`
    .quiet()
    .nothrow()
  const bun = (globalThis as any).Bun
  if (bridgeSecret && bun?.serve) {
    try {
      proxyServer = bun.serve({ hostname: "127.0.0.1", port: 0, fetch: proxyRequest })
      proxyURL = `http://127.0.0.1:${proxyServer.port}`
    } catch {
      proxyServer = undefined
    }
  }
  await publish(true)
  await registerBridge()

  const retryTimer = setInterval(() => {
    const state = aggregate()
    const serialized = `${state.busy}:${state.waiting}:${state.reason}:${generation}`
    if (state.waiting === 0 && serialized === lastPublished) return
    queue = queue
      .then(async () => {
        const acknowledged = await applyAcknowledgement()
        if (acknowledged) await publish()
      })
      .catch(() => undefined)
  }, 1000)

  const bridgeHeartbeatTimer = setInterval(() => {
    scheduleBridgeRegistration()
  }, 10_000)

  return {
    "chat.message": async ({ sessionID }) => {
      if (telegramPromptSessions.has(sessionID)) return
      if ((await loadSession(sessionID)).parentID) return
      await queueBridgeEvent({ action: "local-prompt", sessionID })
    },
    "experimental.chat.system.transform": async ({ sessionID }, output) => {
      if (!sessionID || !(await phoneModeEnabled())) return
      if ((await loadSession(sessionID)).parentID) return
      output.system.push(phoneModeSystem)
    },
    event: async ({ event }) => {
      const runtimeEvent = event as RuntimeEvent
      if (!trackedEvents.has(runtimeEvent.type)) return

      queue = queue
        .then(async () => {
          const metadataOnly = runtimeEvent.type === "session.created" || runtimeEvent.type === "session.updated"
          const acknowledged = metadataOnly ? false : await applyAcknowledgement()
          const changed = await handle(runtimeEvent)
          if (acknowledged || changed) await publish()
        })
        .catch(() => undefined)
      await queue
    },
    dispose: async () => {
      clearInterval(retryTimer)
      clearInterval(bridgeHeartbeatTimer)
      await queue
      await bridgeQueue
      await publishQueue
      await postBridge("/unregister", { instanceID })
      proxyServer?.stop(true)
      await $`${kittyBin} @ --to ${socket} set-user-vars --match id:${windowID} opencode_busy opencode_waiting opencode_reason opencode_ack opencode_instance opencode_generation`
        .quiet()
        .nothrow()
      await $`${sketchybarBin} --trigger opencode_update`.quiet().nothrow()
    },
  }
}
