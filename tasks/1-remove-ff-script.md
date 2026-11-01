---
status: done
priority: medium
size: S
commits: [bb5b4f6..a22d4d2]
---
# Remove the `ff` script, ignore `__pycache__`

## Request
"I want to clean them up and improve them."

## Why
Leaves a clean checkout, which landing requires.

## Implementation details
`~/bins/ff` is the compiled replacement; the working-tree deletion of `git/bins/ff` was committed as it stood.
