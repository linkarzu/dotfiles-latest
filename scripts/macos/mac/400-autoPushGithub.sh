#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/scripts/macos/mac/400-autoPushGithub.sh
# ~/github/dotfiles-latest/scripts/macos/mac/400-autoPushGithub.sh

# This script will be executed automatically every X amount of seconds by the
# ~/Library/LaunchAgents/com.linkarzu.autoPushGithub.plist file
# This file above will automatically be created and loaded by my zshrc file, so
# no need to create it manually

# List of repositories to push to
REPO_LIST=(
  "$HOME/Library/Mobile Documents/com~apple~CloudDocs/github/skitty"
  "$HOME/github/obsidian_main"
)

# Define the push interval in seconds
# Make sure this matches the frequency of the launch agent
# NOTE: This does not cover the case in which the file is modified at min 1,
# launch agent executes at min 3, skips the update, so I have to wait other 3
# minutes (5 in total) for the next update, I don't care, that's fine
PUSH_INTERVAL=180

# Function to display macOS notifications
display_notification() {
  local message="$1"
  local title="$2"
  osascript -e "display notification \"$message\" with title \"$title\""
}

# Initialize success messages
SUCCESS_MESSAGES=""

# Loop through each repository
for REPO_PATH in "${REPO_LIST[@]}"; do
  # Navigate to the repository
  cd "$REPO_PATH" || {
    display_notification "Failed to navigate to $REPO_PATH" "Error"
    continue
  }

  # Check if any files were modified within the last PUSH_INTERVAL seconds
  # -newermt stands for “newer than modification time.”
  # This will find Files Modified Within the Last X Seconds, and if ther are
  # RECENT_MODIFICATIONS will contain a non-empty list of file paths
  RECENT_MODIFICATIONS=$(find . -type f -newermt "-${PUSH_INTERVAL} seconds" 2>/dev/null)
  # If RECENT_MODIFICATIONS is not empty (-n), it skips pushing changes for this repository
  if [[ -n "$RECENT_MODIFICATIONS" ]]; then
    echo "Skipping push for $REPO_PATH due to recent modifications."
    continue
  fi

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
        continue
      fi
    fi

    # Push changes
    if git push 2>/tmp/git_error.log; then
      REPO_NAME=$(basename "$REPO_PATH")
      SUCCESS_MESSAGES+="\n$REPO_NAME $COMPUTER_NAME-$TIMESTAMP"
    else
      ERROR_MSG=$(</tmp/git_error.log)
      display_notification "Push failed: $ERROR_MSG" "Git Push Error"
      continue
    fi
  else
    echo "No changes to push for $REPO_PATH."
  fi

  # Cleanup temporary error log
  rm -f /tmp/git_error.log
done

# Display all success messages in a single notification
if [[ -n "$SUCCESS_MESSAGES" ]]; then
  display_notification "Repositories updated:$SUCCESS_MESSAGES" "Git Push Success"
fi
