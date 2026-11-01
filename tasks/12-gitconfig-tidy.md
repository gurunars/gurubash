---
status: active
priority: low
size: S
depends_on: [2]
---
# Tidy `git/gitconfig` without changing behaviour

## Request
"I want to clean them up and improve them."

## Why
`color.ui` and `core.whitespace` are each set twice, with the later one silently winning.

## Implementation details
- One section per name, each key once, at the value that wins today (`color.ui=true`, `core.whitespace=trailing-space,space-before-tab`), consistent two-space indent.
- `lg`: drop the no-op `--color-words`. `br`: `branch -l` is just `branch`.
- Leave `ci = commit --no-verify`, `cl = clean -fdx` and `credential.helper` as they are: user's choices.
- `git/install.sh`: quote paths.

## Done when
`git config -f git/gitconfig --get <key>` is unchanged for every key before and after, except the two aliases; no key listed twice.
