---
status: review
type: bug
priority: high
size: M
depends_on: [2]
---
# `PATH` grows with every nested shell

## Request
"I want to clean them up and improve them."

## Steps to reproduce
Seen at bb5b4f6:
1. `env -i HOME=$HOME TERM=xterm /bin/bash -lic 'echo $PATH | tr : "\n" | wc -l; bash -ic "echo \$PATH | tr : \"\\n\" | wc -l"'`

## Actual outcome
29 entries at depth 1, 39 at depth 2.

## Expected outcome
The same entries at any depth: a shell config must be safe to source repeatedly. Nothing else settles this but the `loader` design, so treat it as this repo's rule; `AGENTS.md` records it.

## Implementation details
- `path_add` in the root `loader` (skips what is present), used by every `*/loader` and `bins` loop; `unset` afterwards.
- Non-interactive shells return early after `PATH`: `.bashrc` and `.profile` both link to `defaults/profile`, and `bind`, prompts and `ssh-agent` have no place in them.
- `system/loader`: no `. /etc/profile` from `.bashrc` — only a login shell needs it, and macOS's `path_helper` reorders `PATH` on it. Don't start a fresh `ssh-agent` per shell: reuse one socket under `~/.ssh`.
- `personal/loader`: empty `~/.personal` sources a literal `*`; guard with `[ -f ]` and quote.
- `conda/loader.mac`: both hard-coded prefixes get prepended even when absent, shadowing brew's `python3` when present — add only what exists, after brew.
- `history/loader`: set `HISTCONTROL` once, remove the boilerplate comments, add `HISTSIZE`/`HISTFILESIZE` = 100000, load Homebrew's bash completion when present.
- `android/loader`: drop the removed `tools` dir and the duplicate `ANDROID_SDK` only if nothing here reads it.

## Done when
Regression test in the check container: entry count equal at depth 1, 2, 3, and a non-interactive shell prints nothing and starts no agent.
