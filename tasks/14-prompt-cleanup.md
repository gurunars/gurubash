---
status: review
priority: low
size: S
depends_on: [11]
---
# Prompt: fewer forks, no dead files

## Request
"I want to clean them up and improve them."

## Why
Every prompt forks `date`, `git` and sed; the AWS marker shows a literal `??`.

## Implementation details
- `$(date +%H:%M)` → `\A`.
- `parse_git_branch` → `git symbolic-ref --short -q HEAD`, falling back to the short hash when detached (today it prints `(HEAD detached …)`).
- `theming/shapes/multiline`: `$(eval whoami)` → `$EUID`.
- `aws_assumed_role`: `??` → `AWS:`.
- Delete `theming/theming`: nothing sources it.
- Keep the look otherwise identical, themes included.

## Done when
In the check container, the rendered `PS1` matches before and after for: normal, failed command, git branch, detached HEAD, assumed role — other than the marker.
