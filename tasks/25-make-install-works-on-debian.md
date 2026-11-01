---
status: done
type: bug
priority: high
size: S
commits: [a4ad541753f2..b4f4dced1887]
---

# `make install` works on Debian

## Why

The user's coding work moves to a Debian 13 home server (2026-11-01). gurubash knows the Mac and
Ubuntu, and its OS check and package manager scripts are named per OS.

## Contract

`make` on Debian 13 picks the apt path it uses on Ubuntu, without a copy of each Ubuntu file: one name
for the apt family. Ubuntu and the Mac behave as before.

## Done when

`make install` in a real `debian:13` container ends 0 and a new shell starts clean; the same still
holds in `ubuntu:latest`.

## Verify

- `task check`
