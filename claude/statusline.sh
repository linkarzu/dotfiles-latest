#!/usr/bin/env bash

# Claude Code status line, shows the session name set with /rename or --name,
# or the AI-generated title, so it stays visible at the bottom of the CLI.
# Registered as statusLine in ~/.claude/settings.json

jq -r '.session_name // "unnamed session"'
