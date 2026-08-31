# OpenCode Telegram bridge

This bridge keeps each Kitty OpenCode process independent while allowing one
private Telegram bot to report and answer pending questions, permissions,
errors, and completed sessions.

Notifications for questions, permissions, and completion are sent only after
they remain unresolved for four minutes. Unexpected errors are sent
immediately. Intentional aborts from OpenCode or Telegram are suppressed. The
bot accepts messages only from the configured numeric Telegram user ID.

When a delayed notification becomes due, it remains queued while its exact
Kitty window is focused and macOS has received keyboard or mouse input within
the last 90 seconds. The bridge checks again every five seconds. Switching
away or becoming inactive makes the notification eligible again, while
answering locally resolves it without sending. Error notifications are never
withheld by local activity.

Replying to any OpenCode notification from Telegram enables global phone mode.
While phone mode is active, existing and new unresolved notifications from all
OpenCode processes are sent immediately. The next prompt submitted locally in
any OpenCode session disables phone mode and restores the four-minute delay.
Telegram-injected prompts and background subagent prompts do not disable it.
Right-clicking the OpenCode SketchyBar item also toggles phone mode; left-click
opens the session popup.
Phone-mode responses are instructed to stay within 3,500 characters and use
plain-text headings, bullets, and numbered steps instead of tables or complex
layouts. Completion notifications include up to 3,500 characters of the latest
assistant response.

## Setup

Run the guided configuration:

```sh
~/github/dotfiles-latest/opencode/telegram/setup.sh --configure
```

The script walks through creating a bot with the verified `@BotFather`, checks
the token with Telegram, and discovers your numeric user ID from the `/start`
message sent directly to the new bot. It stores credentials outside this
repository at `~/.config/opencode-telegram-bridge/credentials.json` with file
mode `0600` in a directory with mode `0700`. It also generates a separate
owner-readable local secret used to authenticate OpenCode plugin requests to
the loopback bridge; the plugin never reads the Telegram bot token.

Install and start the per-user macOS LaunchAgent:

```sh
~/github/dotfiles-latest/opencode/telegram/setup.sh --install
```

Restart existing OpenCode processes after installing the bridge so the updated
plugin is loaded. New processes register automatically.

Check or remove the service with:

```sh
~/github/dotfiles-latest/opencode/telegram/setup.sh --status
~/github/dotfiles-latest/opencode/telegram/setup.sh --uninstall
```

The unresolved-attention delay defaults to four minutes. For temporary testing,
change it and restart the bridge with:

```sh
~/github/dotfiles-latest/opencode/telegram/setup.sh --set-delay 30
~/github/dotfiles-latest/opencode/telegram/setup.sh --install
```

Uninstalling preserves credentials. Bot and bridge logs are under
`~/.config/opencode-telegram-bridge/`.

## Telegram usage

- Tap `Once`, `Always`, or `Reject` on a permission alert.
- Tap an option or reply directly to a question alert.
- Reply directly to a completion or error alert to continue that session.
- Reply with `/build PROMPT` to continue that session in build mode.
- Reply with `/plan PROMPT` to continue that session in plan mode.
- Ordinary follow-up replies preserve the most recently selected mode.
- Reply with `/abort` to stop the associated session.
- Send `/sessions` or `/status` to see currently registered processes.
- `/sessions` and `/status` also show whether global phone mode is active.

Telegram bot chats are not end-to-end encrypted. Notifications intentionally
contain only bounded session, question, permission, command/path, error, and
completion summaries rather than full source, diffs, or tool output.
