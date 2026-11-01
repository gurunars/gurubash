---
status: review
type: bug
priority: medium
size: S
depends_on: [2]
---
# `pkg demo` crashes and creates no package

## Request
"I want to clean them up and improve them."

## Steps to reproduce
Seen at bb5b4f6, in an empty scratch directory:
1. `python3 -B ~/.gurubash/python/bins/pkg demo`

## Actual outcome
```
FileExistsError: [Errno 17] File exists: 'demo'
```

## Expected outcome
`demo/__init__.py` and `demo/tests.py` exist, empty — the script's own stated purpose ("Create Python package").

## Implementation details
`os.makedirs` then `os.mkdir` on the same path. Then `open()` without a mode would fail too: `"w"` needed on both. Regression test runs in the check container.
