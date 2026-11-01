---
status: planned
type: bug
priority: medium
size: L
depends_on: [7, 13]
---
# `make` always fails on Ubuntu

## Request
"I want to clean them up and improve them."

## Steps to reproduce
Seen at bb5b4f6:
1. `bash ~/.gurubash/python/install.ubuntu.sh; echo "exit=$?"`

`git.install` depends on `python.install`, so a full `make` stops there.

## Actual outcome
```
Python no go yet
exit=1
```

## Expected outcome
`make` completes on the Ubuntu LTS current today: `README.md` gives it as the setup, with no OS caveat, and the repo carries `*.ubuntu.sh` throughout.

## Implementation details
Decided: Ubuntu stays supported rather than removed (a revert brings either back).
- `python/install.ubuntu.sh`: apt `python3`, `pipx`-free, no `exit 1`.
- `pkg-manager/install-if-missing.ubuntu.sh`: `brew list` → `dpkg -s`; `apt-key` is gone → keyring under `/etc/apt/keyrings` with `signed-by`; `arch=amd64` → the `ARCH` it already computes; delete the commented args.
- Test: `make install` in an `ubuntu:latest` container with a throwaway `HOME` — never published ports, chrome/code/ollama may be stubbed if unavailable on the architecture, and say which were.

## Verify
- `task check`
