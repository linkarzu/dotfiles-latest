import type { Plugin } from "@opencode/plugin/tui"
import { execFile } from "node:child_process"

// Publishes this kitty window's opencode state as opencode_* user vars and triggers
// opencode_update, which the sketchybar opencode item and
// kitty/scripts/kitty-opencode-sessions.sh read. Since opencode 2 every window
// talks to one background server, so this runs in the terminal client instead,
// where KITTY_WINDOW_ID is this window's, and only counts sessions this window
// has opened. The Telegram bridge parts of the opencode 1 plugin aren't ported,
// the bridge is disabled, see git history to bring them back.

type AttentionReason = "done" | "error" | "permission" | "question"
type Attention = { reason: AttentionReason; generation: number }

const kittyBin = "/Applications/kitty.app/Contents/MacOS/kitty"
const sketchybarBin = "/opt/homebrew/bin/sketchybar"
const focusAcknowledgementDelayMs = 2_000
const permissionAttentionDelayMs = 2_000

function run(file: string, args: string[]) {
  return new Promise<{ ok: boolean; stdout: string }>((resolve) => {
    execFile(file, args, { timeout: 5_000 }, (error, stdout) => resolve({ ok: !error, stdout: String(stdout) }))
  })
}

async function setup(context: Plugin.Context) {
  const kittyPID = process.env.KITTY_PID
  const windowID = process.env.KITTY_WINDOW_ID
  if (!kittyPID || !windowID) return

  const socket = `unix:/tmp/kitty-${kittyPID}`
  const instanceID = `${kittyPID}:${windowID}`
  // The server sends events for the sessions of every window, these are the roots
  // of the ones opened here, from the route and the open tabs.
  const ownRoots = new Set<string>()
  const parents = new Map<string, string>()
  const busy = new Set<string>()
  const attention = new Map<string, Map<string, Attention>>()
  const pendingPermissions = new Map<string, ReturnType<typeof setTimeout>>()
  let generation = 0
  let focusedAttentionSince = 0
  let lastPublished = ""
  let queue = Promise.resolve()

  function kitty(...args: string[]) {
    return run(kittyBin, ["@", "--to", socket, ...args])
  }

  function parentOf(sessionID: string) {
    return parents.get(sessionID) ?? context.data.session.get(sessionID)?.parentID
  }

  function rootOf(sessionID: string) {
    const seen = new Set<string>()
    let current = sessionID
    while (!seen.has(current)) {
      seen.add(current)
      const parentID = parentOf(current)
      if (!parentID) return current
      current = parentID
    }
    return current
  }

  function trackOwnSessions() {
    const route = context.ui.router.current()
    if (route.type === "session") ownRoots.add(rootOf(route.sessionID))
    if (context.ui.tabs.enabled()) {
      for (const tab of context.ui.tabs.list()) ownRoots.add(rootOf(tab.sessionID))
    }
  }

  function isOwn(sessionID: string) {
    trackOwnSessions()
    return ownRoots.has(rootOf(sessionID))
  }

  function addAttention(sessionID: string, key: string, reason: AttentionReason) {
    generation++
    focusedAttentionSince = 0
    let current = attention.get(sessionID)
    if (!current) attention.set(sessionID, (current = new Map()))
    current.set(key, { reason, generation })
  }

  function removeAttention(sessionID: string, key: string) {
    return attention.get(sessionID)?.delete(key) ?? false
  }

  function aggregate() {
    trackOwnSessions()
    let busyCount = 0
    let waiting = 0
    const reasons = new Set<AttentionReason>()
    for (const sessionID of busy) if (ownRoots.has(rootOf(sessionID))) busyCount++
    for (const [sessionID, current] of attention) {
      if (current.size === 0 || !ownRoots.has(rootOf(sessionID))) continue
      waiting++
      for (const item of current.values()) reasons.add(item.reason)
    }
    const order: AttentionReason[] = ["error", "permission", "question", "done"]
    const reason = order.find((item) => reasons.has(item)) ?? "none"
    return { busy: busyCount, waiting, reason }
  }

  async function windowState() {
    const response = await kitty("ls", "--match", `id:${windowID}`)
    if (!response.ok) return undefined
    try {
      const osWindow = JSON.parse(response.stdout)[0]
      const tab = osWindow?.tabs?.[0]
      const window = tab?.windows?.[0]
      return {
        acknowledgement: String(window?.user_vars?.opencode_ack ?? ""),
        focused: Boolean(osWindow?.is_focused && tab?.is_focused && window?.is_focused),
      }
    } catch {
      return undefined
    }
  }

  function acknowledgeThrough(acknowledged: number) {
    let changed = false
    for (const current of attention.values()) {
      for (const [key, item] of current) {
        if (item.generation > acknowledged) continue
        current.delete(key)
        changed = true
      }
    }
    return changed
  }

  // The session picker acknowledges by setting opencode_ack, and focusing the
  // window for 2 seconds acknowledges everything up to now.
  async function applyAcknowledgement() {
    const state = await windowState()
    let changed = false
    if (state?.acknowledgement.startsWith(`${instanceID}:`)) {
      const acknowledged = Number(state.acknowledgement.slice(instanceID.length + 1))
      if (Number.isFinite(acknowledged)) changed = acknowledgeThrough(acknowledged)
    }
    if (aggregate().waiting === 0 || !state?.focused) {
      focusedAttentionSince = 0
      return changed
    }
    const now = Date.now()
    if (focusedAttentionSince === 0) focusedAttentionSince = now
    if (now - focusedAttentionSince < focusAcknowledgementDelayMs) return changed

    const acknowledged = generation
    const result = await kitty("set-user-vars", "--match", `id:${windowID}`, `opencode_ack=${instanceID}:${acknowledged}`)
    if (!result.ok) return changed
    focusedAttentionSince = 0
    return acknowledgeThrough(acknowledged) || changed
  }

  async function publish(force = false) {
    const state = aggregate()
    const serialized = `${state.busy}:${state.waiting}:${state.reason}:${generation}`
    if (!force && serialized === lastPublished) return
    const result = await kitty(
      "set-user-vars",
      "--match",
      `id:${windowID}`,
      `opencode_busy=${state.busy}`,
      `opencode_waiting=${state.waiting}`,
      `opencode_reason=${state.reason}`,
      `opencode_instance=${instanceID}`,
      `opencode_generation=${generation}`,
    )
    if (!result.ok) return
    lastPublished = serialized
    await run(sketchybarBin, ["--trigger", "opencode_update"])
  }

  function enqueue(work: () => Promise<boolean> | boolean) {
    queue = queue
      .then(async () => {
        const acknowledged = await applyAcknowledgement()
        if ((await work()) || acknowledged) await publish()
      })
      .catch(() => undefined)
  }

  // Permissions answered within 2 seconds, like auto approved ones, don't ask for attention.
  function cancelPermission(sessionID: string, requestID: string) {
    const key = `${sessionID}:${requestID}`
    clearTimeout(pendingPermissions.get(key))
    pendingPermissions.delete(key)
  }

  const stops = [
    context.data.on("session.created", (event) => {
      if (event.data.parentID) parents.set(event.data.sessionID, event.data.parentID)
    }),
    context.data.on("session.deleted", (event) =>
      enqueue(() => {
        const { sessionID } = event.data
        busy.delete(sessionID)
        parents.delete(sessionID)
        return attention.delete(sessionID)
      }),
    ),
    context.data.on("session.execution.started", (event) =>
      enqueue(() => {
        busy.add(event.data.sessionID)
        removeAttention(event.data.sessionID, "done")
        return true
      }),
    ),
    context.data.on("session.execution.interrupted", (event) => enqueue(() => busy.delete(event.data.sessionID))),
    context.data.on("session.execution.succeeded", (event) =>
      enqueue(async () => {
        const { sessionID } = event.data
        busy.delete(sessionID)
        if (parentOf(sessionID) || !isOwn(sessionID)) return true
        const waitingOnRequest = [...(attention.get(sessionID)?.keys() ?? [])].some((key) => key !== "done")
        if (waitingOnRequest || (await windowState())?.focused) return true
        addAttention(sessionID, "done", "done")
        return true
      }),
    ),
    context.data.on("session.execution.failed", (event) =>
      enqueue(() => {
        busy.delete(event.data.sessionID)
        if (!isOwn(event.data.sessionID)) return true
        addAttention(event.data.sessionID, "error", "error")
        return true
      }),
    ),
    context.data.on("permission.asked", (event) => {
      const { sessionID, id } = event.data
      const key = `${sessionID}:${id}`
      if (!isOwn(sessionID) || pendingPermissions.has(key)) return
      pendingPermissions.set(
        key,
        setTimeout(() => {
          pendingPermissions.delete(key)
          enqueue(() => {
            addAttention(sessionID, `permission:${id}`, "permission")
            return true
          })
        }, permissionAttentionDelayMs),
      )
    }),
    context.data.on("permission.replied", (event) => {
      const { sessionID, requestID } = event.data
      cancelPermission(sessionID, requestID)
      enqueue(() => removeAttention(sessionID, `permission:${requestID}`))
    }),
    context.data.on("form.created", (event) =>
      enqueue(() => {
        const { sessionID, id } = event.data.form
        if (!isOwn(sessionID)) return false
        addAttention(sessionID, `question:${id}`, "question")
        return true
      }),
    ),
    context.data.on("form.replied", (event) =>
      enqueue(() => removeAttention(event.data.sessionID, `question:${event.data.id}`)),
    ),
    context.data.on("form.cancelled", (event) =>
      enqueue(() => removeAttention(event.data.sessionID, `question:${event.data.id}`)),
    ),
  ]

  await kitty("set-user-vars", "--match", `id:${windowID}`, `opencode_ack=${instanceID}:0`)
  await publish(true)

  // Picks up acknowledgements and newly opened sessions, nothing to do while
  // nothing waits and nothing changed.
  const timer = setInterval(() => {
    const state = aggregate()
    if (state.waiting === 0 && `${state.busy}:0:none:${generation}` === lastPublished) return
    enqueue(() => true)
  }, 1_000)

  return async () => {
    clearInterval(timer)
    for (const stop of stops) stop()
    for (const pending of pendingPermissions.values()) clearTimeout(pending)
    await queue
    await kitty(
      "set-user-vars",
      "--match",
      `id:${windowID}`,
      "opencode_busy",
      "opencode_waiting",
      "opencode_reason",
      "opencode_ack",
      "opencode_instance",
      "opencode_generation",
    )
    await run(sketchybarBin, ["--trigger", "opencode_update"])
  }
}

export default { id: "sketchybar-status", setup } satisfies Plugin.Definition
