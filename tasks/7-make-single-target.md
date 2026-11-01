---
status: done
type: bug
priority: high
size: S
depends_on: [2]
commits: [66c4c2184aab..17d5d88b0c03]
---
# `make vim.install` silently does nothing

## Request
"I want to clean them up and improve them."

## Steps to reproduce
Seen at bb5b4f6:
1. `cd ~/.gurubash && make -n vim.install`

## Actual outcome
No output, nothing would run. `make -n install` lists 151 lines.

## Expected outcome
The `%.install` rule's recipe runs for the named component, as it does under `make install`.

## Implementation details
`.PHONY: $(MAKECMDGOALS)` makes the goal phony, and make skips pattern rules for phony targets. Must work on macOS's GNU Make 3.81.
Also, in the `Makefile`: drop the `upgrade` and `test: java.install` leftovers; build the `install` prerequisites only from directories holding an `install*.sh` (so `tasks/` and `scripts/` are not "Installed"); keep dependency order working.

## Verify
- `task check`
