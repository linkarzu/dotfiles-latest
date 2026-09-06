# Clean up stale OpenCode sessions

This script removes OpenCode sessions that have not had activity within a
configurable retention period, then safely rebuilds the SQLite database so the
deleted space is returned to macOS.

## Why this exists

OpenCode stores session state in `~/.local/share/opencode/opencode.db`. Current
OpenCode releases also retain durable `message.updated.1` and
`message.part.updated.1` events. These events can contain complete historical
message or tool snapshots rather than small deltas, and the event table does
not have a built-in retention limit.

Snapshot-based change summaries make this substantially worse. A user message
can contain `summary.diffs` with the full patch for every changed file. If a
repository tracks generated logs or build output, each update can append
another multi-megabyte copy of those patches to the event table.

The database that prompted this script reached approximately 123 GiB. Its
event table occupied about 112 GiB, and individual `ILP persistent
orchestrator` messages included patches as large as 114 MiB. One tracked file,
`.worktrees/ilp-v1/logs/orchestrator.jsonl`, contributed an 86.2 MiB patch to a
single message snapshot. Sessions older than seven days owned approximately
113 GiB of removable event, message, and part payloads.

This is live SQLite data, not unused pages, so `VACUUM` by itself cannot fix the
initial problem. The session records and their event aggregates must be deleted
first. After deletion, this database also needs an explicit rebuild because its
`auto_vacuum` setting is disabled.

Related upstream reports:

- [Unbounded growth of the event table](https://github.com/anomalyco/opencode/issues/33356)
- [`message.updated.1` event-table bloat](https://github.com/anomalyco/opencode/issues/32005)
- [SQLite auto-vacuum is disabled](https://github.com/anomalyco/opencode/issues/31526)
- [Request for configurable retention](https://github.com/anomalyco/opencode/issues/34875)

OpenCode does not currently provide a supported retention, event-pruning, or
database-vacuum command. It does provide `opencode session delete`, which this
script uses instead of directly deleting application rows.

## Safety model

The script is read-only unless `--apply` is supplied. During an apply run it:

1. Refuses to start while any process has the OpenCode database open.
2. Runs SQLite's `quick_check` before deleting anything.
3. Protects a stale parent if any descendant has recent activity. OpenCode
   recursively deletes child sessions, so this check prevents a stale parent
   from taking a recent child with it.
4. Deletes only the highest safe node in each stale subtree through
   `opencode session delete`.
5. Checkpoints the WAL every 25 deletion operations to limit temporary disk
   growth.
6. Verifies that all safely deletable stale sessions are gone and checks the
   database again.
7. Rebuilds only when the compacted copy and a safety margin fit in available
   disk space.
8. Validates the compacted copy with `quick_check` and compares critical table
   row counts before replacing the original database.
9. Keeps the original database in place until the replacement has passed all
   checks. If replacement validation fails, it restores the original.
10. Reports the filesystem's available space before and after every successful
    apply run.

The cutoff is calculated once at startup from `session.time_updated`. A failed
or interrupted deletion run can be rerun; already deleted sessions will no
longer appear in its next dry run.

`--apply` is intentionally non-interactive so the command can be scripted. It
permanently deletes the selected sessions and does not export them or retain a
persistent backup after the replacement database passes validation. Always
review the dry run first.

## Requirements

- macOS
- Bash
- OpenCode
- SQLite 3
- `lsof`

All are available in the current dotfiles environment or the standard macOS
installation.

## Usage

Run a read-only preview with the default seven-day retention period:

```sh
~/github/dotfiles-latest/opencode/scripts/cleanup-stale-sessions/cleanup-stale-sessions.sh
```

Include every target's ID, last activity time, title, and directory:

```sh
~/github/dotfiles-latest/opencode/scripts/cleanup-stale-sessions/cleanup-stale-sessions.sh --list
```

Quit every OpenCode CLI, TUI, desktop, and server process, then apply the
cleanup:

```sh
~/github/dotfiles-latest/opencode/scripts/cleanup-stale-sessions/cleanup-stale-sessions.sh --apply
```

Use a different retention period:

```sh
~/github/dotfiles-latest/opencode/scripts/cleanup-stale-sessions/cleanup-stale-sessions.sh --days 14 --apply
```

Delete stale sessions without physically rebuilding the database:

```sh
~/github/dotfiles-latest/opencode/scripts/cleanup-stale-sessions/cleanup-stale-sessions.sh --apply --no-compact
```

Without compaction, SQLite can reuse the deleted pages, but the database file
will not become smaller on disk.

At the end of an apply run, the script prints the available disk space measured
immediately before cleanup and after all requested work finishes. These values
come from `df`; other filesystem activity and APFS space accounting can affect
the observed difference.

For the database measured when this script was created, a seven-day cleanup is
expected to reduce the database from approximately 123 GiB to 9-11 GiB after
compaction. The result will vary as session activity and stored output change.

## Preventing recurrence

The global `opencode.jsonc` in this repository sets:

```json
{
  "snapshot": false
}
```

This prevents OpenCode from embedding repository snapshot diffs in future
message summaries. The tradeoff is that OpenCode can no longer undo or revert
agent changes through its UI. Restart every running OpenCode process after the
configuration change because configuration is loaded only at startup.

Disabling snapshots prevents the measured Git-diff amplification, but OpenCode
can still retain other message and tool events. Running the dry run
periodically remains useful until upstream retention support is available.
