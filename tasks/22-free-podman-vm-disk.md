---
status: planned
priority: high
type: human
size: S
---
# Free space in the podman VM: `task check` cannot start

## Why
The podman VM's disk is full, so every `task check` and every agent sandbox fails before checking any code. No agent has a tool that prunes podman, and `make_snapshot` will not commit while the check is red, so task 13 cannot commit its finished rebase. Other tasks that need the check are blocked the same way.

## Steps to reproduce
Run `task check` from the repo root.

## Actual outcome
`open /var/tmp/auth.json.<n>: no space left on device`, while pulling `mirror.gcr.io/library/busybox:1.37` (exit 125). The agent sandbox (`localhost/tasks-sandbox:1`) fails the same way.

## Expected outcome
`task check` runs to its result.

## What to do
Run `podman system df` to see what is using the space, then remove what is unused: stopped containers, dangling images, old build stages. Keep base images and the images in use. Then re-run task 13, whose next step is `make_snapshot`.
