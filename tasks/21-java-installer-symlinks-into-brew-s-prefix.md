---
status: active
priority: low
type: task
size: S
---
# Java installer symlinks into brew's prefix

## Request
Found while doing #5: `java/install.mac.sh` runs `sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk …`, writing into brew's prefix, the same thing #5 removed from `python/install.mac.sh`.

## Steps to reproduce
1. `grep -En '/opt/homebrew/' java/install.mac.sh`

## Actual outcome
The installer creates a symlink inside `/opt/homebrew/` (under `opt/`), with `sudo`.

## Expected outcome
The JDK is found without writing into brew's prefix, e.g. via `JAVA_HOME` set from `/usr/libexec/java_home` or `brew --prefix` in a loader.

## Implementation details
Decide the replacement, change `java/install.mac.sh`, and only then tighten the check in `scripts/inside.sh` (the `ln … /opt/homebrew/bin/` check from #5 could cover `opt/` too).
