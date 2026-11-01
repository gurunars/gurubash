---
status: done
priority: medium
size: M
depends_on: [7]
commits: [9469a8e504a4..52ec199d50b5]
---
# Re-running `make` is quick and downloads nothing it already has

## Request
"I want to clean them up and improve them."

## Why
`make` re-runs curl-piped installers and an `ollama pull` every time, and setting up git forces all of it.

## Implementation details
- `Makefile`: drop `git.install: ai.install`; only the removed `ff` needed it (task 1).
- `ai/install.sh`: mac via brew through `$INSTALL`; Linux script only when `ollama` is missing; pull only when `ollama list` lacks the model; model name in one place, shared with `ai/loader`.
- `dotnet/install.sh`: skip when `~/.dotnet/dotnet` exists.
- `pkg-manager/install.mac.sh`: look for `/opt/homebrew/bin/brew` — `which` misses it before `pkg-manager/loader.mac` has run.
- `pkg-manager/install.ubuntu.sh`: no `upgrade`/`dist-upgrade` during install; `up` does that.
- `$INSTALL` lines all one style; add a `#!/bin/bash` and `set -e` to every install script, unquoted vars quoted.

## Done when
In the Ubuntu container or with stubs: a second run makes no network call and no package change.
