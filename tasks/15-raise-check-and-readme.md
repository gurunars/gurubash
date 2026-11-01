---
status: review
priority: low
size: S
depends_on: [3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14, 17, 18]
---
# Raise shellcheck to warning, and write the README

## Request
"I want to clean them up and improve them."

## Why
Once the cleanup is in, the gate should keep it there, and a new machine should need no reading of the source.

## Implementation details
- `scripts/check.sh`: `--severity=warning`; fix what it finds; any exclusion carries its reason inline.
- `README.md`: the layout (`install.sh`, `install.<os>.sh`, `loader`, `loader.<os>`, `bins/`, `bins/<os>/`), `make <name>.install`, core vs extensions, `ext`, profiles, `~/.personal`, `BASH_THEME`, `task check`.
- `.gitattributes`: remove if the `vimrc` line still serves nothing.

## Done when
`task check` green at warning.
