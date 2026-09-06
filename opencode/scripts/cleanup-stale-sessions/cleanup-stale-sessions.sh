#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

readonly DEFAULT_DAYS=7
readonly DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode"
readonly DB="$DATA_DIR/opencode.db"

days=$DEFAULT_DAYS
apply=false
compact=true
list=false
targets_file=''
compact_db=''
available_before_bytes=''

error() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage:
  cleanup-stale-sessions.sh [--days DAYS] [--list]
  cleanup-stale-sessions.sh [--days DAYS] --apply [--no-compact]

Options:
  --days DAYS    Delete sessions with no activity for this many days (default: 7)
  --list         List every deletion target during the dry run
  --apply        Perform deletion; without this flag the script is read-only
  --no-compact   Delete data but do not rebuild the database to return space to macOS
  -h, --help     Show this help

The apply operation must run while every OpenCode process is stopped.
EOF
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || error "Required command not found: $1"
}

cleanup_temporary_files() {
  [[ -z "$targets_file" ]] || rm -f "$targets_file"
  [[ -z "$compact_db" ]] || rm -f "$compact_db"
}

human_bytes() {
  awk -v bytes="$1" 'BEGIN {
    split("B KiB MiB GiB TiB", units, " ")
    value = bytes + 0
    unit = 1
    while (value >= 1024 && unit < 5) {
      value /= 1024
      unit++
    }
    printf "%.1f %s", value, units[unit]
  }'
}

available_disk_bytes() {
  df -Pk "$DATA_DIR" | awk 'NR == 2 { printf "%.0f", $4 * 1024 }'
}

print_disk_space_summary() {
  local available_after_bytes
  available_after_bytes=$(available_disk_bytes)

  printf '\nDisk space summary:\n'
  printf 'Available before cleanup: %s\n' "$(human_bytes "$available_before_bytes")"
  printf 'Available after cleanup:  %s\n' "$(human_bytes "$available_after_bytes")"
}

database_is_open() {
  lsof "$DB" >/dev/null 2>&1
}

quick_check() {
  local database=$1 result
  result=$(sqlite3 -readonly "$database" 'PRAGMA quick_check;')
  if [[ "$result" != 'ok' ]]; then
    printf 'SQLite quick check failed for %s: %s\n' "$database" "$result" >&2
    return 1
  fi
}

checkpoint() {
  sqlite3 "$DB" 'PRAGMA wal_checkpoint(TRUNCATE);' >/dev/null
}

table_counts() {
  local database=$1
  sqlite3 -readonly -separator '|' "$database" '
    SELECT "session", count(*) FROM session
    UNION ALL SELECT "message", count(*) FROM message
    UNION ALL SELECT "part", count(*) FROM part
    UNION ALL SELECT "event", count(*) FROM event
    UNION ALL SELECT "event_sequence", count(*) FROM event_sequence
    UNION ALL SELECT "session_message", count(*) FROM session_message
    UNION ALL SELECT "todo", count(*) FROM todo;
  '
}

while (($# > 0)); do
  case "$1" in
  --apply)
    apply=true
    shift
    ;;
  --list)
    list=true
    shift
    ;;
  --no-compact)
    compact=false
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  --days)
    (($# >= 2)) || error '--days requires an integer.'
    days=$2
    shift 2
    ;;
  *)
    usage >&2
    error "Unknown option: $1"
    ;;
  esac
done

[[ "$days" =~ ^[0-9]+$ ]] || error '--days must be a positive integer.'
((days > 0)) || error '--days must be greater than zero.'

require_command awk
require_command df
require_command lsof
require_command mktemp
require_command opencode
require_command sqlite3

[[ -f "$DB" ]] || error "OpenCode database not found: $DB"
[[ ! -L "$DB" ]] || error "Refusing to operate on a symlinked database: $DB"
if $apply && database_is_open; then
  error 'OpenCode is using the database. Quit every OpenCode CLI, TUI, desktop, and server process first.'
fi

trap cleanup_temporary_files EXIT
targets_file=$(mktemp "${TMPDIR:-/tmp}/opencode-stale-sessions.XXXXXX")

readonly cutoff=$(
  sqlite3 -readonly "$DB" "SELECT CAST(strftime('%s', 'now', '-$days days') AS INTEGER) * 1000;"
)
readonly cutoff_utc=$(sqlite3 -readonly "$DB" "SELECT datetime($cutoff / 1000, 'unixepoch') || ' UTC';")

# A stale parent cannot be deleted if any descendant is recent because OpenCode
# recursively removes children. Pick only the highest safe node in each stale subtree.
readonly tree_sql="
  WITH RECURSIVE
  descendants(ancestor_id, id) AS (
    SELECT parent_id, id FROM session WHERE parent_id IS NOT NULL
    UNION ALL
    SELECT descendants.ancestor_id, session.id
    FROM descendants
    JOIN session ON session.parent_id = descendants.id
  ),
  safe AS (
    SELECT current.id, current.parent_id, current.time_updated, current.title, current.directory
    FROM session AS current
    WHERE current.time_updated < $cutoff
      AND NOT EXISTS (
        SELECT 1
        FROM descendants
        JOIN session AS child ON child.id = descendants.id
        WHERE descendants.ancestor_id = current.id
          AND child.time_updated >= $cutoff
      )
  ),
  targets AS (
    SELECT safe.*
    FROM safe
    LEFT JOIN safe AS parent ON parent.id = safe.parent_id
    WHERE parent.id IS NULL
  )
"

stats=$(sqlite3 -readonly -separator '|' "$DB" "$tree_sql
  SELECT
    (SELECT count(*) FROM session),
    (SELECT count(*) FROM session WHERE time_updated < $cutoff),
    (SELECT count(*) FROM session WHERE time_updated >= $cutoff),
    (SELECT count(*) FROM safe),
    (SELECT count(*) FROM session WHERE time_updated < $cutoff AND id NOT IN (SELECT id FROM safe)),
    (SELECT count(*) FROM targets);
")
IFS='|' read -r total_sessions stale_sessions recent_sessions safe_sessions protected_sessions target_count <<<"$stats"

sqlite3 -readonly "$DB" "$tree_sql SELECT id FROM targets ORDER BY time_updated, id;" >"$targets_file"

printf 'OpenCode stale-session cleanup\n'
printf 'Database:                 %s\n' "$DB"
printf 'Retention:                %s days\n' "$days"
printf 'Cutoff:                   %s\n' "$cutoff_utc"
printf 'Total sessions:           %s\n' "$total_sessions"
printf 'Stale sessions:           %s\n' "$stale_sessions"
printf 'Recent sessions retained: %s\n' "$recent_sessions"
printf 'Safe stale sessions:      %s\n' "$safe_sessions"
printf 'Protected stale parents:  %s\n' "$protected_sessions"
printf 'Deletion operations:      %s\n' "$target_count"

if $list; then
  printf '\nDeletion targets:\n'
  sqlite3 -readonly -separator ' | ' "$DB" "$tree_sql
    SELECT id, datetime(time_updated / 1000, 'unixepoch') || ' UTC', title, directory
    FROM targets
    ORDER BY time_updated, id;
  "
fi

if ! $apply; then
  printf '\nDry run only. Re-run with --apply to delete these sessions.\n'
  exit 0
fi

available_before_bytes=$(available_disk_bytes)

((target_count > 0)) || {
  printf '\nNo stale sessions are safe to delete.\n'
  print_disk_space_summary
  exit 0
}

printf '\nRunning pre-cleanup database check. This can take several minutes...\n'
quick_check "$DB" || error 'Pre-cleanup database validation failed.'

deleted=0
while IFS= read -r session_id; do
  [[ -n "$session_id" ]] || continue
  database_is_open && error 'Another process opened the database during cleanup. Close OpenCode and re-run the script.'
  if ! OPENCODE_DISABLE_AUTOUPDATE=1 OPENCODE_DISABLE_MODELS_FETCH=1 \
    opencode --pure session delete "$session_id" >/dev/null; then
    error "OpenCode failed to delete session $session_id. Re-run the script to continue with the remaining sessions."
  fi
  deleted=$((deleted + 1))
  if ((deleted % 25 == 0)); then
    checkpoint
    printf 'Deleted %s/%s stale session trees...\n' "$deleted" "$target_count"
  fi
done <"$targets_file"

checkpoint
printf 'Deleted %s stale session trees.\n' "$deleted"

remaining_safe=$(sqlite3 -readonly "$DB" "$tree_sql SELECT count(*) FROM safe;")
((remaining_safe == 0)) || error "$remaining_safe safe stale sessions remain after deletion. Re-run the cleanup before compacting."

printf 'Running post-deletion database check...\n'
quick_check "$DB" || error 'Post-deletion database validation failed.'

if ! $compact; then
  printf 'Compaction skipped. SQLite can reuse the freed pages, but macOS disk usage will not decrease yet.\n'
  print_disk_space_summary
  exit 0
fi

metrics=$(sqlite3 -readonly -separator '|' "$DB" '
  SELECT page_size, page_count, freelist_count
  FROM pragma_page_size, pragma_page_count, pragma_freelist_count;
')
IFS='|' read -r page_size page_count freelist_count <<<"$metrics"
live_upper_bound=$(((page_count - freelist_count) * page_size))
available_bytes=$(available_disk_bytes)
margin=$((live_upper_bound / 5))
((margin >= 1073741824)) || margin=1073741824
required_bytes=$((live_upper_bound + margin))

printf 'Estimated compacted size: at most %s\n' "$(human_bytes "$live_upper_bound")"
printf 'Available disk space:     %s\n' "$(human_bytes "$available_bytes")"

if ((available_bytes < required_bytes)); then
  printf 'Compaction skipped: at least %s of free space is required for a guarded rebuild.\n' \
    "$(human_bytes "$required_bytes")"
  printf 'The deleted space remains reusable inside SQLite. Use an external volume for VACUUM INTO to return it to macOS.\n'
  print_disk_space_summary
  exit 0
fi

compact_db="$DB.compact.$$.tmp"
backup_db="$DB.pre-cleanup.$$"
source_counts=$(table_counts "$DB")
source_mode=$(stat -f '%Lp' "$DB")
compact_sql_path=${compact_db//\'/\'\'}

printf 'Building compacted database...\n'
sqlite3 "$DB" "VACUUM INTO '$compact_sql_path';"
chmod "$source_mode" "$compact_db"
quick_check "$compact_db" || error 'Compacted database validation failed; the original remains unchanged.'

compact_counts=$(table_counts "$compact_db")
[[ "$compact_counts" == "$source_counts" ]] || error 'Compacted database row counts do not match the source database.'

checkpoint
database_is_open && error 'The database was opened during compaction. Close OpenCode and re-run the cleanup.'

mv "$DB" "$backup_db"
[[ ! -e "$DB-wal" ]] || mv "$DB-wal" "$backup_db-wal"
[[ ! -e "$DB-shm" ]] || mv "$DB-shm" "$backup_db-shm"
mv "$compact_db" "$DB"
compact_db=''

if ! quick_check "$DB" || [[ "$(table_counts "$DB")" != "$source_counts" ]]; then
  rm -f "$DB" "$DB-wal" "$DB-shm"
  mv "$backup_db" "$DB"
  [[ ! -e "$backup_db-wal" ]] || mv "$backup_db-wal" "$DB-wal"
  [[ ! -e "$backup_db-shm" ]] || mv "$backup_db-shm" "$DB-shm"
  error 'Replacement validation failed; the original database was restored.'
fi

rm -f "$backup_db" "$backup_db-wal" "$backup_db-shm"
final_bytes=$(stat -f '%z' "$DB")
printf 'Cleanup complete. Compacted database size: %s\n' "$(human_bytes "$final_bytes")"
print_disk_space_summary
