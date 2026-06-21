# ~/snapshot/

This directory holds ephemeral snapshots of working copies (Git / Jujutsu)
created with `snapshot-working-copy.sh`. Each snapshot is a full tarball
of a project directory stored in a date-timestamped subdirectory.

Snapshots are intended as a safety net before risky operations — rebasing,
history rewriting, or experimental changes. They are **not** a backup
strategy with retention policies.

## Directory layout

```
~/snapshot/YYYY-MM-DD_HHMM/project-name.tar.gz
```

## Commands

### `snapshot-working-copy.sh`

Take a snapshot of the current directory:

```sh
$ snapshot-working-copy.sh
```

Take a snapshot of a specific project:

```sh
$ snapshot-working-copy.sh ~/code/my-project
```

### `restore-working-copy.sh`

Restore a snapshot to `/tmp`:

```sh
$ restore-working-copy.sh ~/snapshot/2025-06-21_1430/my-project.tar.gz
```

Use the restored directory immediately:

```sh
$ cd "$(restore-working-copy.sh ~/snapshot/2025-06-21_1430/my-project.tar.gz)"
```

## Cleanup

Snapshots are ephemeral. Delete old ones freely:

```sh
rm -rf ~/snapshot/2025-01-*
```
