# Custom Commands

Edit `hex.config.ts`, not `.hex-sdk`. Config and installed dependencies execute
with the user's normal permissions; use only trusted packages and avoid network,
filesystem, environment, or subprocess access unless the requested command
requires it. Run `bun run check` after editing.

Spoken commands and dictation controls require the Commands opt-in, which
defaults off; a config does not enable it. Mode transformations can run with
Commands off once selected. Bun must be installed separately, and the host
requires the exact Effect version in `.hex-sdk/package.json` even for
Promise-only configs.

`bun run check` validates TypeScript, not phrase overlaps. A running host watches
regular `.ts` and `.json` workspace files, excluding `node_modules`, `.git`, and
symlink targets. Check the Commands pane for runtime reload errors. If missing
config, Bun, or dependencies prevented host startup, restart HEX after repair.

Replace the native voice-dictation phrases declaratively when desired:

```ts
import { defineHexConfig } from "@hex/commands"

export default defineHexConfig({
  dictation: {
    start: ["begin note"],
    stop: ["finish note"],
    send: ["send note"],
    cancel: ["discard note"],
  },
  commands: {},
})
```

`start` is a streaming utterance prefix while HEX is listening. The other
controls are streaming suffixes only during an active voice capture. This block
replaces the native phrases exactly, not the capture lifecycle, and does not
define command handlers. Each list must be nonempty and unambiguous. If this
block is omitted, HEX uses its built-in protocol.

Register named finishing transformations when a dictation mode needs a
deterministic text rule:

```ts
import { defineHexConfig } from "@hex/commands"

export default defineHexConfig({
  transformations: {
    "trim-whitespace": {
      name: "Trim whitespace",
      description: "Remove leading and trailing whitespace",
      transform: (text) => text.trim(),
    },
  },
  commands: {},
})
```

Select the registered transformation in the mode's Transformations section.
Selected transformations run in displayed order after that mode's corrections
and optional AI rewrite for Paste and Send, not Voice Action or meetings.
Transformations may be async, receive the foreground context as their second
argument, and must return a string. If the transformation stage fails, HEX keeps
the text from before that stage, not partial transformation results.

Do not reuse `lowercase`, `spongebob-case`, or `no-trailing-punctuation` as
custom transformation IDs; these IDs execute native built-ins instead of a
registered TypeScript function.

Use a handler with the provided `hex` capabilities for ordinary commands:

```ts
import { defineHexConfig } from "@hex/commands"

export default defineHexConfig({
  commands: {
    slack: {
      phrases: ["open slack"],
      run: ({ hex }) => hex.openApplication("Slack"),
    },
  },
})
```

To navigate inside an app, use `openUrl` (lowercase `rl`) with its deep link.
`openApplication` takes an app name or path, not a URL. macOS must have an
installed handler for the URL scheme:

```ts
run: ({ hex }) => hex.openUrl("slack://channel?team=T_EXAMPLE&id=C_EXAMPLE")
```

URLs are passed unchanged, including their query and fragment. File URLs and
inline script/data URLs are unsupported; use `openPath` for filesystem paths.

Handlers may issue several calls. Await dependent capability calls to preserve
their order; unawaited calls can run concurrently even though HEX tracks them
until handler completion:

```ts
run: async ({ hex }) => {
  await hex.openApplication("Slack")
  await hex.press({ key: "k", modifiers: ["command"] })
}
```

End a phrase with one `{name}` placeholder to capture the rest of the spoken
words. The normalized remainder arrives as `captures.name`: ASCII letters are
lowercased, ASCII punctuation is trimmed from word boundaries, whitespace is
collapsed, and spoken digits zero through nine become `0` through `9`.
Capture phrases require `run` and at least one spoken word before the placeholder:

```ts
import { defineHexConfig } from "@hex/commands"

export default defineHexConfig({
  commands: {
    "search-amazon": {
      phrases: ["search amazon for {query}"],
      run: ({ hex, captures }) =>
        hex.openUrl(`https://www.amazon.com/s?k=${encodeURIComponent(captures.query ?? "")}`),
    },
  },
})
```

Saying "search amazon for wool socks" opens the Amazon search for
"wool socks". Captures require one or more words and are bounded to 24 words /
512 UTF-8 bytes. At equal context specificity, a capture phrase conflicts with
another phrase if one spoken sequence could match both. The bare prefix alone
does not match the capture. More-specific commands may specialize ordinary
commands, but never protected native phrases.

Use an explicit schema for typed, composable captures. Every alias must bind
the same names exactly once. `digit()` captures one spoken digit as a number
and may appear anywhere; `text()` captures normalized trailing words as a
string and must be last:

```ts
import { defineHexConfig, digit } from "@hex/commands"

export default defineHexConfig({
  commands: {
    "control-number": {
      phrases: ["control {number}"],
      captures: { number: digit({ min: 1, max: 3 }) },
      run: ({ hex, captures }) =>
        hex.press({ key: String(captures.number), modifiers: ["control"] }),
    },
  },
})
```

Import `text` and declare `query: text()` when explicit trailing text should
compose with digit captures. Schema-bearing commands always require `run`.

Use `choice()` for bounded one-word alternatives. An array returns the spoken
value itself; object keys are canonical values and each array contains spoken
aliases:

```ts
import { choice, defineHexConfig } from "@hex/commands"

export default defineHexConfig({
  commands: {
    move: {
      phrases: ["move {direction}"],
      captures: {
        direction: choice({
          left: ["left", "back"],
          right: ["right", "forward"],
        } as const),
      },
      run: ({ hex, captures }) => hex.press(captures.direction),
    },
  },
})
```

The handler sees `"left" | "right"`; saying "back" produces `"left"`.

Use `union()` to compose disjoint bounded one-token captures. Members may be
`letter()`, `digit()`, `choice()`, or nested unions; nested unions are flattened.
`text()` is rejected, as are members whose spoken alternatives overlap:

```ts
import { choice, digit, letter, union } from "@hex/commands"

const key = union(letter(), digit(), choice(["home", "end", "escape"] as const))
// captures.key is Letter | number | "home" | "end" | "escape"
```

Use `letter()` for a single keyboard letter. Literal letters, common spoken
names such as "bee", and one-word NATO names such as "bravo" all arrive as the
canonical lowercase `"a" | ... | "z"` union:

```ts
import { defineHexConfig, letter } from "@hex/commands"

export default defineHexConfig({
  commands: {
    "control-letter": {
      phrases: ["control {key}"],
      captures: { key: letter() },
      run: ({ hex, captures }) =>
        hex.press({ key: captures.key, modifiers: ["control"] }),
    },
  },
})
```

Effect handlers use the Effect entrypoint and may be values or functions:

```ts
import { Effect } from "effect"
import { defineHexConfig, Hex } from "@hex/commands/effect"

export default defineHexConfig({
  commands: {
    training: {
      phrases: ["open training"],
      run: Effect.gen(function* () {
        const hex = yield* Hex
        yield* hex.openUrl("https://example.com/training")
      }),
    },
    contextual: {
      phrases: ["show context"],
      run: ({ context }) => Effect.gen(function* () {
        const hex = yield* Hex
        yield* hex.typeText(context.browserHost ?? context.application ?? "unknown")
      }),
    },
  },
})
```
