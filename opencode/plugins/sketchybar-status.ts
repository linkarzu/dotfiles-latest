import type { Plugin } from "@opencode-ai/plugin"

type AttentionReason = "done" | "error" | "permission" | "question"
type SessionState = {
  parentID?: string
  status: "busy" | "idle" | "retry"
  attention: Map<string, { reason: AttentionReason; generation: number }>
}
type RuntimeEvent = {
  type: string
  properties: Record<string, any>
}

const kittyBin = "/Applications/kitty.app/Contents/MacOS/kitty"
const sketchybarBin = "/opt/homebrew/bin/sketchybar"
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

export const SketchybarStatusPlugin: Plugin = async ({ client, $ }) => {
  const kittyPID = process.env.KITTY_PID
  const windowID = process.env.KITTY_WINDOW_ID
  if (!kittyPID || !windowID || !$) return {}

  const socket = `unix:/tmp/kitty-${kittyPID}`
  const instanceID = String(process.pid)
  const initialAcknowledgement = `${instanceID}:0`
  const sessions = new Map<string, SessionState>()
  let lastPublished = ""
  let generation = 0
  let queue = Promise.resolve()

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
    if (response?.data?.parentID) current.parentID = response.data.parentID
    return current
  }

  function removeRequest(sessionID: string, requestID: string) {
    const current = sessions.get(sessionID)
    current?.attention.delete(`permission:${requestID}`)
    current?.attention.delete(`question:${requestID}`)
  }

  function addAttention(current: SessionState, key: string, reason: AttentionReason) {
    generation++
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
          windows?: Array<{ is_focused?: boolean; user_vars?: Record<string, string> }>
        }>
      }>
      const osWindow = tree[0]
      const tab = osWindow?.tabs?.[0]
      const window = tab?.windows?.[0]
      return {
        acknowledgement: window?.user_vars?.opencode_ack ?? "",
        focused: Boolean(osWindow?.is_focused && tab?.is_focused && window?.is_focused),
      }
    } catch {
      return undefined
    }
  }

  async function applyAcknowledgement() {
    const state = await kittyWindowState()
    if (!state?.acknowledgement.startsWith(`${instanceID}:`)) return false

    const acknowledgedGeneration = Number(state.acknowledgement.slice(instanceID.length + 1))
    if (!Number.isFinite(acknowledgedGeneration)) return false

    let changed = false
    for (const current of sessions.values()) {
      for (const [key, attention] of current.attention) {
        if (attention.generation > acknowledgedGeneration) continue
        current.attention.delete(key)
        changed = true
      }
    }
    return changed
  }

  async function publish(force = false) {
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

  async function handle(input: RuntimeEvent) {
    const properties = input.properties ?? {}

    switch (input.type) {
      case "session.created":
      case "session.updated": {
        const info = properties.info
        if (!info?.id) return false
        const current = session(info.id)
        current.parentID = info.parentID ?? ""
        return false
      }
      case "session.deleted": {
        if (properties.info?.id) sessions.delete(properties.info.id)
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
          current.attention.delete("error")
          break
        }

        if (wasActive) {
          for (const key of current.attention.keys()) {
            if (key.startsWith("permission:") || key.startsWith("question:")) current.attention.delete(key)
          }
          await loadSession(sessionID)
          const windowState = await kittyWindowState()
          if (!current.parentID && !windowState?.focused) addAttention(current, "done", "done")
        }
        break
      }
      case "session.error": {
        const sessionID = properties.sessionID
        if (sessionID) addAttention(session(sessionID), "error", "error")
        break
      }
      case "permission.asked":
      case "permission.v2.asked":
      case "permission.updated": {
        const sessionID = properties.sessionID
        const requestID = properties.id
        if (sessionID && requestID) {
          addAttention(session(sessionID), `permission:${requestID}`, "permission")
        }
        break
      }
      case "permission.replied":
      case "permission.v2.replied": {
        if (properties.sessionID && properties.requestID) {
          removeRequest(properties.sessionID, properties.requestID)
        }
        if (properties.sessionID && properties.permissionID) {
          removeRequest(properties.sessionID, properties.permissionID)
        }
        break
      }
      case "question.asked":
      case "question.v2.asked": {
        const sessionID = properties.sessionID
        const requestID = properties.id
        if (sessionID && requestID) {
          addAttention(session(sessionID), `question:${requestID}`, "question")
        }
        break
      }
      case "question.replied":
      case "question.rejected":
      case "question.v2.replied":
      case "question.v2.rejected": {
        if (properties.sessionID && properties.requestID) {
          removeRequest(properties.sessionID, properties.requestID)
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
  await publish(true)

  const retryTimer = setInterval(() => {
    const state = aggregate()
    const serialized = `${state.busy}:${state.waiting}:${state.reason}:${generation}`
    if (state.waiting === 0 && serialized === lastPublished) return
    queue = queue
      .then(async () => {
        await applyAcknowledgement()
        await publish(state.waiting > 0)
      })
      .catch(() => undefined)
  }, 1000)

  return {
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
      await queue
      await $`${kittyBin} @ --to ${socket} set-user-vars --match id:${windowID} opencode_busy opencode_waiting opencode_reason opencode_ack opencode_instance opencode_generation`
        .quiet()
        .nothrow()
      await $`${sketchybarBin} --trigger opencode_update`.quiet().nothrow()
    },
  }
}
