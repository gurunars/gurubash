---
status: review
priority: high
size: M
---
# `task check` in a container, and `AGENTS.md`

## Request
"I want to clean them up and improve them."

## Why
Every other task needs a green/red gate that runs nothing on the host and never touches the real `$HOME`.

## Contract
`task check` from the repo root: exit 0 when clean, non-zero naming file and line otherwise. Needs only `task` and podman on the host.

Covers:
- shellcheck `--severity=error` + `bash -n`: every `install*.sh`, `loader*`, `loader`, `get-os.sh`, `theming/*` shell file, `bins/*` with a shell shebang
- Python syntax for `bins/*` with a python shebang
- `code/*.json` and `.vscode/settings.json` parsed as JSONC (comments and trailing commas are legal)
- `git config -f git/gitconfig --list` parses
- `vim -u vim/vimrc -es` reports no errors
- loopback check: fails on the patterns in `~/.claude/CLAUDE.md` (`0.0.0.0`, `::`, `localhost` as a URL host, unpublished-host `-p N:N`), reference `~/repo/visa/scripts/check-loopback.mjs`
- `make -n install` succeeds

## Implementation details
- `Taskfile.yml` + `scripts/check.sh`; one small image or a pinned public one per tool, `podman run --rm`, repo mounted read-only. Read `container-hygiene` skill first.
- `make` remains the installer; `Taskfile.yml` is checks only.
- `AGENTS.md` rules: installers and `make install` never run against the real `$HOME` — only `make -n`, or inside a container with a throwaway `HOME`; `code/settings.json` is JSONC; every directory with a `loader` is sourced by every shell, so loaders stay fast and silent.
- `scripts/` and `tasks/` hold no `install*`/`loader`; `*/` targets must tolerate them until 7 lands.

## TODO
- [x] [M] `Taskfile.yml`, `scripts/check.sh`, tool images
- [x] [S] Loopback check
- [x] [S] `AGENTS.md`
- [x] [S] Fix anything at severity error so the first run is green

## Done when
`task check` green on the branch, and red when a `0.0.0.0` is added to any tracked file.

## Verify
- `task check`
