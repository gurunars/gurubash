---
status: rejected
rejection_reason: Taskfile.yml with a check task already exists
type: human
priority: high
size: S
---

# Add `Taskfile.yml` with a `check` task

## Why

The repository has no Taskfile, and an executor may not create or change one. Task 2's executor is
writing `scripts/check.sh` as the check; until a Taskfile names it, snapshots commit unchecked and
nothing gates a landing.

## Do

Create `Taskfile.yml` at the repository root:

```yaml
version: '3'

tasks:
  check:
    desc: Everything a landing must pass
    cmds:
      - sh scripts/check.sh
```

Commit it on master. Later tasks add `test`, `lint` and the like beside it; each executor's tools
are the tasks this file names.

## Done when

`task check` runs `scripts/check.sh` from the main checkout, and task 2's next snapshot reports
`checked: true`.
