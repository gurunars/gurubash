---
status: planned
type: human
priority: low
size: S
depends_on: [8]
---
# Apply the VS Code config on the Mac

## Why
Agents never run installers against the real `$HOME`, and this replaces the live `settings.json`.

## TODO
- [ ] `cd ~/.gurubash && make code.install`
- [ ] Restart VS Code; check the dev-container podman paths still apply
- [ ] Delete `~/Library/Application Support/Code/User/settings.json.bak` and `~/.config/Code` when happy

## Done when
You say so.
