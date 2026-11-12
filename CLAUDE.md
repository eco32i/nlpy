# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Post-install setup for an Ubuntu 26.04 server/workstation (bioinformatics). Branch `dev26.04`; `master` is the main branch. See README.md for the module list.

## Commands

```
make lint                                  # bash -n + shellcheck (docker)
make test                                  # tests/run.sh: runs modules twice in an ubuntu:26.04 container (~3 min)
scripts/bootstrap.sh --dry-run --all       # safe: prints commands only
```

Never run the script for real on the dev machine to test changes: it uses sudo/apt and `link_file` replaces `~/.config/tmux/tmux.conf` (with a backup). Use `--dry-run`, `make test`, or `HOME=$(mktemp -d)`.

## Architecture

- `scripts/bootstrap.sh` only parses args and dispatches. Modules live in `scripts/modules/<name>.sh`, each defining `module_<name>`; `scripts/lib/common.sh` has shared helpers (`run`, `apt_install`, `link_file`, `detect_profile`, ...).
- All side effects must go through `run`/`as_root`/`apt_install`, otherwise `--dry-run` stops being safe.
- Adding a module: create `modules/<name>.sh`, then in bootstrap.sh add the flag (getopt + case + usage), an `APPLIES` entry (which profiles) and an entry in `ORDER` (and `OPT_IN` if it must stay out of `--all`).
- Profile (`workstation|server|container`) comes from `detect_profile`, not from `DISPLAY`/`WAYLAND_DISPLAY`, because the script is often run over SSH. Modules branch with `is_gui_profile` / `has_systemd`.
- Modules must be idempotent; `tests/run.sh` runs them twice.
- `config/tmux/tmux.conf` is symlinked (file, not directory, so TPM plugins stay out of the repo). Clipboard goes through `config/bin/tmux-copy` via tmux-yank's `@override_copy_command`.
- `services/autossh-tunnel@.service` is a template unit; per-tunnel settings come from env files, installed by the opt-in `--services DIR`.
