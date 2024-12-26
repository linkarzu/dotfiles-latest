#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/scripts/macos/mac/400-autoPushGithub.sh
# ~/github/dotfiles-latest/scripts/macos/mac/400-autoPushGithub.sh

# Repository path
REPO_PATH="$HOME/Library/Mobile Documents/com~apple~CloudDocs/github/skitty"

# Function to display macOS notifications
display_notification() {
  local message="$1"
  local title="$2"
  osascript -e "display notification \"$message\" with title \"$title\""
}

# Navigate to the repository
cd "$REPO_PATH" || {
  display_notification "Failed to navigate to $REPO_PATH" "Error"
  exit 1
}

# Check for changes or commits not pushed
UNCOMMITTED_CHANGES=$(git status --porcelain)
UNPUSHED_COMMITS=$(git rev-list --count origin/$(git rev-parse --abbrev-ref HEAD)..HEAD)

if [[ -n "$UNCOMMITTED_CHANGES" || "$UNPUSHED_COMMITS" -gt 0 ]]; then
  if [[ -n "$UNCOMMITTED_CHANGES" ]]; then
    # Stage all changes
    git add .

    # Commit with a timestamp message and computer name
    COMPUTER_NAME=$(scutil --get ComputerName)
    TIMESTAMP=$(date '+%y%m%d-%H%M%S')
    if git commit -m "$COMPUTER_NAME-$TIMESTAMP" 2>/tmp/git_error.log; then
      echo "Committed: $COMPUTER_NAME-$TIMESTAMP"
    else
      ERROR_MSG=$(</tmp/git_error.log)
      display_notification "Commit failed: $ERROR_MSG" "Git Commit Error"
      exit 1
    fi
  fi

  # Push changes
  if git push 2>/tmp/git_error.log; then
    display_notification "$COMPUTER_NAME-$TIMESTAMP" "Git Push Success"
  else
    ERROR_MSG=$(</tmp/git_error.log)
    display_notification "Push failed: $ERROR_MSG" "Git Push Error"
    exit 1
  fi
else
  echo "No changes to push."
fi

# Cleanup temporary error log
rm -f /tmp/git_error.log
