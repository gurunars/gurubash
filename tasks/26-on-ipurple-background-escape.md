---
status: review
type: bug
priority: medium
size: S
---
# `On_IPurple` is not a background colour: `\033[10;95m` sets the font and a foreground

## Steps to reproduce
1. In a shell with the core loaded, run `printf '%b' "$On_IPurple" | od -c` (or inspect `core/theming/bash_color_definitions` line 70).
2. Compare with `On_IBlue` (`\033[0;104m`) and the other `On_I*` lines, which all use `0;10x`.

## Actual outcome
`On_IPurple='\033[10;95m'`. `10` is the SGR "primary font" code, and `95` is a bright magenta *foreground*. Nothing sets a background, so any use of `On_IPurple` shows no purple background.

## Expected outcome
`On_IPurple='\033[0;105m'`, the high-intensity purple background, matching the sibling entries.
