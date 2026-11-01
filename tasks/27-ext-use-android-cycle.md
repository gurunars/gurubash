---
status: planned
type: bug
priority: high
size: S
depends_on: [18]
---
# `ext use android` refuses to start: "nests too deep"

## Request
"It would be nice to have extension profiles where a bunch of configs are loaded temporarily (like in venv) and then freed."

## Steps to reproduce
Seen at e37682c:
1. `env -i HOME=$HOME TERM=xterm /bin/bash -lic 'ext use android; echo rc=$?'`

## Actual outcome
```
ext: profile 'android' nests too deep (a cycle?)
rc=1
```
`ext ls` shows `android: ` with no members.

## Expected outcome
A nested shell with the `android` and `java` extensions loaded, and `ext ls` showing `android: android java`: task 18's contract names `profiles/android` as `android java`.

## Implementation details
`profiles/android` lists `android`, and `_ext_expand` in `core/ext/loader` resolves that line to the profile again. Inside a profile, a line naming the profile itself means the extension of that name; a real cycle (`a` → `b` → `a`) is still refused. Regression test in `task check`, which should also load every shipped profile.

## Verify
- `task check`
