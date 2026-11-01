# AGENTS.md

Shell/dotfile setup, installed with `make`. Read this before changing anything.

## Never touch the real `$HOME`

- Installers (`*/install*.sh`) and `make install` never run against the real
  `$HOME`. They write dotfiles, link configs and install packages.
- Allowed: `make -n install` (dry run), or running inside a container with a
  throwaway `HOME`.
- `make` remains the installer. `Taskfile.yml` holds checks only.

## Check

`task check` from the repo root is the gate: exit 0 when clean, non-zero naming
file and line otherwise. It needs only `task` and podman, and runs every tool in
a container with the repo mounted read-only. It covers shellcheck
(`--severity=error`) and `bash -n`, Python syntax, JSONC parsing, the gitconfig,
vim's `vimrc`, the loopback rules and `make -n install`.

## Rules of the tree

- `core/<name>/` is what `make` installs and every shell loads.
  `extensions/<name>/` has the same shape plus an optional `requires` (extension
  names, one per line); `make <name>.install` installs either, `requires` first.
  A shell loads an extension only if `~/.config/gurubash/default-extensions`
  names it; no install ever creates that file.
- `extensions/code/*.json` and `.vscode/settings.json` are JSONC: comments and
  trailing commas are legal. Do not parse with strict JSON.
- `ext use <profile|extension>...` starts a nested shell (`core/ext/`) with extensions
  loaded; exit frees them. A profile is `profiles/<name>` or
  `~/.config/gurubash/profiles/<name>` (wins): one name per line, `#` comments. An
  extension's optional `installed` file is a command to test; none means installed.
- `defaults/profile`, `git/gitconfig`, `vim/vimrc` and `code/*.json` exist only for
  links on machines installed before the split. Edit the real file under `core/`
  or `extensions/`; `task check` fails if the two differ.
- Every `core/<name>/` with a `loader` (or `loader.<os>`) is sourced by every shell.
  Loaders stay fast and silent: no forks you can avoid, no output, no network.
- Loaders must be safe to source repeatedly (nested shells inherit `PATH`): add
  directories only with `path_add [-p] DIR` (defined by the root `loader`, skips
  what is present or missing). Interactive-only parts (`bind`, prompts,
  `ssh-agent`) are guarded and return early in non-interactive shells, which
  print nothing and start no agent. `task check` tests this at depth 1, 2, 3.
- `scripts/` and `tasks/` hold no `install*` or `loader`. `make install` builds
  its list only from directories holding an `install*.sh`, so they are never
  installed.
- Loopback only: never `0.0.0.0`, `::`, `localhost` as a URL host, or an
  unpublished-host `-p N:N`. Use `127.0.0.1`. The check fails on these.
- Never run `npm`, `pip` or a dev server on the host; use the repo's runner.
