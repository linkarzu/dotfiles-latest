/** @jsxImportSource @opentui/solid */
import type { TuiPlugin, TuiPluginModule } from "@opencode-ai/plugin/tui"

const tui: TuiPlugin = async (api) => {
  api.slots.register({
    slots: {
      app_bottom(ctx) {
        const route = api.route.current
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
