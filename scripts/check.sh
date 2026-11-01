#!/usr/bin/env bash
# Host side of `task check`: needs only podman. Builds one small tools image
# (replacing the one it held before), then runs scripts/inside.sh in it with the
# repo mounted read-only.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
image=localhost/gurubash-check:local

want=$(cat "$root/scripts/Containerfile" | podman run --rm -i mirror.gcr.io/library/busybox:1.37 sha256sum | cut -c1-12)
have=$(podman image inspect --format '{{index .Labels "containerfile"}}' "$image" 2>/dev/null || true)
if [ "$have" != "$want" ]; then
  old=$(podman image inspect --format '{{.Id}}' "$image" 2>/dev/null || true)
  podman build -q --label "containerfile=$want" -t "$image" -f "$root/scripts/Containerfile" "$root/scripts" >/dev/null
  new=$(podman image inspect --format '{{.Id}}' "$image")
  if [ -n "$old" ] && [ "$old" != "$new" ]; then podman rmi "$old" >/dev/null 2>&1 || true; fi
fi

exec podman run --rm --network none -v "$root:/repo:ro" -w /repo -e HOME=/tmp/home "$image" \
  bash /repo/scripts/inside.sh
