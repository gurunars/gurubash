---
status: done
type: bug
priority: medium
size: S
depends_on: [2]
commits: [ef47f578069c..7b1034cfad36]
---
# `assume-role` crashes whenever an external id is given

## Request
"I want to clean them up and improve them."

## Steps to reproduce
Seen at bb5b4f6; fails before any AWS call:
1. `python3 -B ~/.gurubash/aws/bins/assume-role arn:aws:iam::123456789012:role/x ext`

## Actual outcome
```
TypeError: sequence item 12: expected str instance, list found
```

## Expected outcome
`aws sts assume-role` is called with `--external-id ext` — the positional the script's own parser declares.

## Implementation details
`nargs='*'` gives a list; use `nargs='?'`. Replace `shell=True` and the joined string with an argv list, dropping the shell quotes around `--query`. Fix `anonymours`. Test with a stub `aws` on `PATH`, never the real one.
