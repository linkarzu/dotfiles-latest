#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/scripts/macos/mac/400-autoPushGithub.sh
# ~/github/dotfiles-latest/scripts/macos/mac/400-autoPushGithub.sh

# This script will be executed automatically every X amount of seconds by the
# ~/Library/LaunchAgents/com.linkarzu.autoPushGithub.plist file
# This file above will automatically be created and loaded by my zshrc file, so
# no need to create it manually

# If I don't add this, the script won't find nvim or jq or any other apps in
# the /opt/homebrew/bin dir
# So it won't run: nvim --server /tmp/skitty-neobean-socket --remote-send
export PATH="/opt/homebrew/bin:$PATH"

# Parse command line arguments
# This allows me to directly call the script without having to wait the PUSH_INTERVAL:
# NOTE: Call the script with
# ./400-autoPushGithub.sh --nowait
NOWAIT=false
while [[ "$#" -gt 0 ]]; do
  case $1 in
  --nowait) NOWAIT=true ;;
  *)
    echo "Unknown parameter: $1"
    exit 1
    ;;
  esac
  shift
done

# Configure logging
LOG_DIR="$HOME/.logs/git_autopush"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/autopush_$(date '+%Y%m').log"

log_message() {
  local level="$1"
  local repo="$2"
  local message="$3"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] [$level] [$repo] $message" | tee -a "$LOG_FILE"
}

# List of repositories to push to
#
# NOTE: Don't keep the repos below in google drive, iCloud orsimilar, as you'll be
# receiving some weird notifications about
# fatal: mmap failed: Resource deadlock avoided
REPO_LIST=(
  "$HOME/github/skitty"
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
  local repo="$3"
  log_message "NOTIFY" "$repo" "Notification: $title - $message"
  osascript -e "display notification \"$message\" with title \"$title\""
}

# Function to update lualine in skitty-notes after a push (neovim)
refresh_neovim_skitty() {
  local repo_name="$1"
  # Only proceed for skitty repository
  if [[ "$repo_name" == "skitty" ]]; then
    if [[ -S "/tmp/skitty-neobean-socket" ]]; then
      log_message "INFO" "$repo_name" "Triggering Neovim refresh"
      nvim --server /tmp/skitty-neobean-socket --remote-send ':silent w<CR>' ||
        log_message "WARN" "$repo_name" "Failed to send refresh command to Neovim"
    else
      log_message "INFO" "$repo_name" "Skitty Neovim socket not found - skipping refresh"
    fi
  fi
}

# Initialize success messages
SUCCESS_MESSAGES=""

# Loop through each repository
for REPO_PATH in "${REPO_LIST[@]}"; do
  REPO_NAME=$(basename "$REPO_PATH")
  ERROR_LOG="$LOG_DIR/${REPO_NAME}_error.log"

  # Navigate to the repository
  cd "$REPO_PATH" || {
    log_message "ERROR" "$REPO_NAME" "Failed to navigate to $REPO_PATH"
    display_notification "Failed to navigate to directory" "Error" "$REPO_NAME"
    continue
  }

  log_message "INFO" "$REPO_NAME" "Starting git operations"

  # Check for iCloud sync status if repo is in iCloud
  if [[ "$REPO_PATH" == *"Mobile Documents"* ]]; then
    if [[ -n $(find . -name "*.icloud") ]]; then
      log_message "WARN" "$REPO_NAME" "iCloud files still syncing - found .icloud files"
      display_notification "Skipping due to iCloud sync in progress" "Warning" "$REPO_NAME"
      continue
    fi
  fi

  # Pull the latest changes, otherwise you will get errors and won't be able to
  # push if modifying from multiple devices
  # Rebasing re-applies your local commits on top of the latest commits from
  # the remote branch, avoiding unnecessary merge commits
  # Check for unstaged changes and skip pull if found
  if [[ -n $(git status --porcelain) ]]; then
    log_message "INFO" "$REPO_NAME" "Unstaged changes detected. Skipping pull."
  else
    # Pull the latest changes
    # if ! git pull --rebase >>/tmp/git_error.log 2>&1; then
    if ! git pull --rebase 2>"$ERROR_LOG"; then
      ERROR_MSG=$(cat "$ERROR_LOG")
      log_message "ERROR" "$REPO_NAME" "Pull failed: $ERROR_MSG"
      display_notification "Pull failed - check logs" "Git Pull Error" "$REPO_NAME"
      continue
    else
      log_message "INFO" "$REPO_NAME" "Pull completed successfully"
    fi
  fi

  # Check if any files were modified within the last PUSH_INTERVAL seconds
  # -newermt stands for "newer than modification time."
  # This will find Files Modified Within the Last X Seconds, and if ther are
  # RECENT_MODIFICATIONS will contain a non-empty list of file paths
  # Ignore the .git dir as commands like git pull may modify stuff and we'll skip updates
  #
  # Check for recent modifications only if NOWAIT is false
  if ! $NOWAIT; then
    RECENT_MODIFICATIONS=$(find . -type f -not -path './.git/*' -newermt "-${PUSH_INTERVAL} seconds" 2>/dev/null)
    # If RECENT_MODIFICATIONS is not empty (-n), it skips pushing changes for this repository
    if [[ -n "$RECENT_MODIFICATIONS" ]]; then
      log_message "INFO" "$REPO_NAME" "Skipping push due to recent modifications"
      log_message "DEBUG" "$REPO_NAME" "Modified files: $RECENT_MODIFICATIONS"
      continue
    fi
  fi

  # Check for changes or commits not pushed
  UNCOMMITTED_CHANGES=$(git status --porcelain)
  UNPUSHED_COMMITS=$(git rev-list --count origin/$(git rev-parse --abbrev-ref HEAD)..HEAD)

  if [[ -n "$UNCOMMITTED_CHANGES" || "$UNPUSHED_COMMITS" -gt 0 ]]; then
    if [[ -n "$UNCOMMITTED_CHANGES" ]]; then
      log_message "INFO" "$REPO_NAME" "Staging changes"
      # Stage all changes
      git add .

      # Commit with a timestamp message and computer name
      COMPUTER_NAME=$(scutil --get ComputerName)
      TIMESTAMP=$(date '+%y%m%d-%H%M%S')
      if ! git commit -m "$COMPUTER_NAME-$TIMESTAMP" 2>"$ERROR_LOG"; then
        ERROR_MSG=$(cat "$ERROR_LOG")
        log_message "ERROR" "$REPO_NAME" "Commit failed: $ERROR_MSG"
        display_notification "Commit failed - check logs" "Git Commit Error" "$REPO_NAME"
        continue
      else
        log_message "INFO" "$REPO_NAME" "Changes committed successfully"
      fi
    fi

    # Push changes
    if ! git push 2>"$ERROR_LOG"; then
      ERROR_MSG=$(cat "$ERROR_LOG")
      log_message "ERROR" "$REPO_NAME" "Push failed: $ERROR_MSG"
      display_notification "Push failed - check logs" "Git Push Error" "$REPO_NAME"
    else
      SUCCESS_MESSAGES+="\n$REPO_NAME $COMPUTER_NAME-$TIMESTAMP"
      log_message "SUCCESS" "$REPO_NAME" "Push completed successfully"
      # Trigger skitty-notes lualine refresh
      refresh_neovim_skitty "$(basename "$REPO_PATH")"
    fi
  else
    log_message "INFO" "$REPO_NAME" "No changes to push"
  fi
  # Don't delete the file, It will be deleted when I restart the computer
  # rm -f /tmp/git_error.log
done

# Display all success messages in a single notification
if [[ -n "$SUCCESS_MESSAGES" ]]; then
  # display_notification "Repositories updated:$SUCCESS_MESSAGES" "Git Push Success" "ALL"
  ~/github/scripts-public/macos/mac/325-customNotifOn.sh
else
  log_message "INFO" "ALL" "No repositories updated during this run"
fi

# Cleanup old logs (keep last 7 days)
find "$LOG_DIR" -name "*.log" -mtime +7 -delete
