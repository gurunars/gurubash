---
status: active
type: bug
priority: medium
size: S
depends_on: [3, 4]
---
# `pkg` and `assume-role` cannot start: no `python` on a clean `PATH`

## Request
"I want to clean them up and improve them."

## Steps to reproduce
Seen at bb5b4f6:
1. `env -i HOME=$HOME TERM=xterm /bin/bash -lic 'type python'`

## Actual outcome
```
bash: type: python: not found
```
Both scripts start with `#!/usr/bin/env python`.

## Expected outcome
Both run from a fresh login shell; `python/install.mac.sh` means to provide it.

## Implementation details
Shebang `python3` in both. Remove the `ln -Fs … /opt/homebrew/bin/python` from `python/install.mac.sh`: writing into brew's prefix is what no longer holds.
