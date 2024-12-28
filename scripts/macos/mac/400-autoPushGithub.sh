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
  echo "DEBUG: Sending notification with title='$title' and message='$message'"
  osascript -e "display notification \"$message\" with title \"$title\""
}

# Initialize success messages
SUCCESS_MESSAGES=""

# Loop through each repository
for REPO_PATH in "${REPO_LIST[@]}"; do
  # Navigate to the repository
  cd "$REPO_PATH" || {
    echo "DEBUG: Failed to navigate to $REPO_PATH"
    display_notification "Failed to navigate to $REPO_PATH" "Error"
    continue
  }

  # Pull the latest changes, otherwise you will get errors and won't be able to
  # push if modifying from multiple devices
  # Rebasing re-applies your local commits on top of the latest commits from
  # the remote branch, avoiding unnecessary merge commits
  # Check for unstaged changes and skip pull if found
  if [[ -n $(git status --porcelain) ]]; then
    echo "DEBUG: Unstaged changes detected in $REPO_PATH. Skipping pull."
  else
    # Pull the latest changes
    # if ! git pull --rebase >>/tmp/git_error.log 2>&1; then
    if ! git pull --rebase >/dev/null 2>>/tmp/git_error.log; then
      ERROR_MSG=$(</tmp/git_error.log)
      echo "DEBUG: Pull failed for $REPO_PATH with error: $ERROR_MSG"
      display_notification "Pull failed: $ERROR_MSG" "Git Pull Error"
      continue
    else
      echo "DEBUG: Pull completed successfully for $REPO_PATH"
    fi
  fi

  # Check if any files were modified within the last PUSH_INTERVAL seconds
  # -newermt stands for “newer than modification time.”
  # This will find Files Modified Within the Last X Seconds, and if ther are
  # RECENT_MODIFICATIONS will contain a non-empty list of file paths
  # Ignore the .git dir as commands like git pull may modify stuff and we'll skip updates
  RECENT_MODIFICATIONS=$(find . -type f -not -path './.git/*' -newermt "-${PUSH_INTERVAL} seconds" 2>/dev/null)
  echo "DEBUG: Recent modifications for $REPO_PATH: $RECENT_MODIFICATIONS"
  # If RECENT_MODIFICATIONS is not empty (-n), it skips pushing changes for this repository
  if [[ -n "$RECENT_MODIFICATIONS" ]]; then
    echo "DEBUG: Skipping push for $REPO_PATH due to recent modifications."
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
      if ! git commit -m "$COMPUTER_NAME-$TIMESTAMP" >>/tmp/git_error.log 2>&1; then
        ERROR_MSG=$(</tmp/git_error.log)
        echo "DEBUG: Displaying notification for commit failure"
        display_notification "Commit failed: $ERROR_MSG" "Git Commit Error"
        continue
      else
        echo "DEBUG: Commit successful for $REPO_PATH"
      fi
    fi

    # Push changes
    if git push >>/tmp/git_error.log 2>&1; then
      REPO_NAME=$(basename "$REPO_PATH")
      SUCCESS_MESSAGES+="\n$REPO_NAME $COMPUTER_NAME-$TIMESTAMP"
      echo "DEBUG: Push successful for $REPO_PATH"
    else
      ERROR_MSG=$(</tmp/git_error.log)
      echo "DEBUG: Displaying notification for push failure"
      display_notification "Push failed: $ERROR_MSG" "Git Push Error"
      continue
    fi
  else
    echo "DEBUG: No changes to push for $REPO_PATH."
  fi
  # Don't delete the file, It will be deleted when I restart the computer
  # rm -f /tmp/git_error.log
done

# Display all success messages in a single notification
echo "DEBUG: Final SUCCESS_MESSAGES: $SUCCESS_MESSAGES"
if [[ -n "$SUCCESS_MESSAGES" ]]; then
  echo "DEBUG: Displaying success notification"
  display_notification "Repositories updated:$SUCCESS_MESSAGES" "Git Push Success"
else
  echo "DEBUG: No repositories updated during this run."
fi
