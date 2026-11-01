---
status: rejected
rejection_reason: task 25 runs make install in real debian:13 and ubuntu:latest containers
priority: medium
type: human
size: S
depends_on: [10]
---
# Run `make install` in a real `ubuntu:latest` container

Task 10's agent has no network or podman of its own, so `task check` only covers the Ubuntu path with stubs: real apt, the real Chrome and VS Code repositories and their packages have not run.

## Steps
From a clone rather than a worktree (git refuses a worktree's `.git` here):
```
podman run --rm -it -v "$PWD:/repo:ro" -e HOME=/tmp/home mirror.gcr.io/library/ubuntu:latest bash -c '
  apt update && apt install -y make sudo && mkdir -p "$HOME" &&
  printf "#!/bin/sh\necho NAME\n" >/usr/local/bin/ollama && chmod +x /usr/local/bin/ollama &&
  cd /repo && make install && apt update'
```
`ollama` is stubbed because no service runs in a container; drop the stub on a real machine. VS Code refuses some commands as root, so `code --list-extensions` may need a stub too.

## Check
- `make install` ends with `DONE`.
- The final `apt update` reports no `Conflicting values set for option Signed-By`. Chrome's and VS Code's packages add their own apt source; `/etc/default/google-chrome` and the `code/add-microsoft-repo` debconf answer are meant to stop that, but neither package's scripts were read. Check `/etc/apt/sources.list.d/` holds one entry per repository, and again after Chrome's `/etc/cron.daily/google-chrome` has run.
