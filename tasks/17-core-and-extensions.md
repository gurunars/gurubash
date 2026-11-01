---
status: done
priority: high
size: L
depends_on: [5, 7, 8, 10, 11, 13]
commits: [e0230a2e669d..a39a30073d49]
---
# Split into core and extensions: `make` installs and loads core only

## Request
"I want to have "core" bash settings and "extension" ones. So that I don't ALWAYS e.g. install AWS CLI or something."

## Why
A new machine gets a small shell; AWS, Java and the rest only when asked for.

## Contract
```
core/<name>/        install.sh, install.<os>.sh, loader, loader.<os>, bins/, bins/<os>/
extensions/<name>/  the same, plus optional `requires` (extension names, one per line)
make                installs core only
make <name>.install core or extension, with its `requires` first
```
- A shell sources core only, plus each extension named in `~/.config/gurubash/default-extensions` (one per line; absent means none; never created by an install).
- Sourcing an extension also puts its `bins` on `PATH`. Unknown name: one line on stderr, the shell still starts.
- `$GURUBASH/loader` and `~/.gurubashrc` keep working unchanged, so an installed machine needs no re-run.

Core: `aliases credentials defaults git history ls-beauty personal pkg-manager system terminal theming vim`.
Extensions: `ai android aws chrome code conda dotnet go java python`; `ai` and `aws` require `python`.

## Implementation details
- `git mv`; update every `${GURUBASH}/…` path, the symlink targets of `defaults`, `git`, `vim`, and `code`, and `scripts/check.sh`. Existing symlinks in the real `$HOME` point at old paths: leave a relative symlink at each of `defaults/profile`, `git/gitconfig`, `vim/vimrc`, `code/settings.json`, `code/keybindings.json` until task 19 re-links them.
- Extension loaders are side-effect free apart from env, and safe to source twice (`path_add`).

## Done when
In a container with a throwaway `HOME`: `make -n` names only core; a new shell has no `aws`, `conda`, `dotnet` on `PATH`; `make -n aws.install` includes `python`; a `default-extensions` naming `go` adds `~/go/bin`.

## Verify
- `task check`
