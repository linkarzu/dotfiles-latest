import { execFile } from "node:child_process"
import { homedir } from "node:os"
import { promisify } from "node:util"

import { choice, defineHexConfig } from "@hex/commands"

const run = promisify(execFile)
const miscScripts = `${homedir()}/github/dotfiles-latest/scripts/macos/mac/misc`

// Commands said with the regular dictation shortcut. The "dictated-commands"
// transformation runs the first pattern that matches the whole dictation
// (lowercased, punctuation removed) and returns empty text, so HEX pastes
// nothing. Anything else is pasted unchanged.
const dictatedCommands: {
  pattern: RegExp
  run: (match: RegExpMatchArray) => Promise<unknown>
}[] = []

// Builds "<before> <name>" and "<name> <after>" commands, e.g. "turn on
// virgin mode" and "virgin mode activated". Each word maps to "on" or "off".
const addToggle = (
  names: string[],
  before: Record<string, "on" | "off">,
  after: Record<string, "on" | "off">,
  toggle: (state: "on" | "off") => Promise<unknown>,
) => {
  const alternatives = (words: string[]) => words.join("|")
  const name = `(?:${alternatives(names)})`
  dictatedCommands.push({
    pattern: new RegExp(
      `^(?:(${alternatives(Object.keys(before))}) ${name}|${name} (${alternatives(Object.keys(after))}))$`,
    ),
    run: (match) => toggle((match[1] ? before[match[1]] : after[match[2] ?? ""]) ?? "off"),
  })
}

// "virgin" is sometimes heard as "version", "off" as "of", and
// "deactivate" as "de-activate"
addToggle(
  ["virgin mode", "version mode"],
  {
    "activate": "on",
    "turn on": "on",
    "enable": "on",
    "start": "on",
    "deactivate": "off",
    "de activate": "off",
    "turn off": "off",
    "turn of": "off",
    "disable": "off",
    "stop": "off",
  },
  {
    "on": "on",
    "activated": "on",
    "off": "off",
    "of": "off",
    "deactivated": "off",
    "de activated": "off",
  },
  (state) => run(`${miscScripts}/570-virginMode.sh`, [state]),
)

const normalizeSpoken = (text: string) =>
  text
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s]/gu, " ")
    .replace(/\s+/g, " ")
    .trim()

export default defineHexConfig({
  // Transformations appear as optional final steps in every dictation mode.
  transformations: {
    "dictated-commands": {
      name: "Dictated commands",
      description: "Run a command instead of pasting when the dictation is one",
      transform: async (text) => {
        const spoken = normalizeSpoken(text)
        for (const command of dictatedCommands) {
          const match = spoken.match(command.pattern)
          if (match) {
            await command.run(match)
            return ""
          }
        }
        return text
      },
    },
  },
  // Uncomment this block to replace HEX's native voice-dictation protocol.
  // dictation: {
  //   start: ["begin note"],
  //   stop: ["finish note"],
  //   send: ["send note"],
  //   cancel: ["discard note"],
  // },
  commands: {
    // "virgin mode on" -> kitty lightning cursor trail
    // "virgin mode off" -> kitty blaze cursor trail
    "virgin-mode": {
      phrases: ["virgin mode {state}"],
      // "off" is usually heard as "of"
      captures: { state: choice({ on: ["on"], off: ["off", "of"] } as const) },
      group: "Modes",
      description: "Toggle virgin mode (kitty cursor shader)",
      run: async ({ captures }) => {
        await run(`${miscScripts}/570-virginMode.sh`, [captures.state])
      },
    },
  },
})
