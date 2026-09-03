/** @jsxImportSource @opentui/solid */
import type { TuiPlugin, TuiPluginModule } from "@opencode-ai/plugin/tui"
import { readFile } from "node:fs/promises"

const telegramBridgeURL = "http://127.0.0.1:47653"

const tui: TuiPlugin = async (api) => {
  const kittyPID = process.env.KITTY_PID
  const windowID = process.env.KITTY_WINDOW_ID
  const instanceID = kittyPID && windowID ? `${kittyPID}:${windowID}` : ""
  const bridgeSecret = await readFile(`${process.env.HOME}/.config/opencode-telegram-bridge/plugin-secret`, "utf8")
    .then((value) => value.trim())
    .catch(() => "")
  let activeSessionID: string | undefined
  const pendingSelections: string[] = []
  let publishing = false

  async function publishSelection() {
    if (!instanceID || !bridgeSecret || publishing) return
    publishing = true
    try {
      while (pendingSelections.length) {
        const selected = pendingSelections.shift()!
        const response = await fetch(`${telegramBridgeURL}/event`, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${bridgeSecret}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            instanceID,
            event: { action: "select-session", sessionID: selected },
          }),
          signal: AbortSignal.timeout(1500),
        }).catch(() => undefined)
        if (!response?.ok) {
          pendingSelections.unshift(selected)
          break
        }
      }
    } finally {
      publishing = false
    }
  }

  const selectionTimer = setInterval(() => {
    if (activeSessionID !== undefined && pendingSelections.length === 0) pendingSelections.push(activeSessionID)
    void publishSelection()
  }, 5_000)
  api.lifecycle.onDispose(() => clearInterval(selectionTimer))

  api.slots.register({
    slots: {
      app_bottom(ctx) {
        const route = api.route.current
        const selected = route.name === "session" ? route.params.sessionID : ""
        if (selected !== activeSessionID) {
          activeSessionID = selected
          pendingSelections.push(selected)
          void publishSelection()
        }
        if (route.name !== "session") return null

        const session = api.state.session.get(route.params.sessionID)
        const title = session?.title?.trim() || route.params.sessionID

        return (
          <box width="100%" flexShrink={0} paddingLeft={2} paddingRight={2}>
            <text fg={ctx.theme.current.textMuted}>
              Session: <span style={{ fg: ctx.theme.current.text }}>{title}</span>
            </text>
          </box>
        )
      },
    },
  })
}

export default {
  id: "session-title-footer",
  tui,
} satisfies TuiPluginModule & { id: string }
