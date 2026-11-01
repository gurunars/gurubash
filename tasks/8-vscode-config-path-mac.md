---
status: done
type: bug
priority: medium
size: M
depends_on: [2]
commits: [4f851c13c594..55e2132ee48a]
---
# VS Code on the Mac ignores the repo's settings and keybindings

## Request
"I want to clean them up and improve them."

## Steps to reproduce
Seen at bb5b4f6, on the Mac after `make`:
1. `ls -la ~/.config/Code/User/settings.json "$HOME/Library/Application Support/Code/User/settings.json"`

## Actual outcome
```
~/.config/Code/User/settings.json -> ~/.gurubash/code/settings.json
~/Library/Application Support/Code/User/settings.json   (regular file, 752 bytes)
```
VS Code reads only the second; no `keybindings.json` there at all.

## Expected outcome
The repo's files are what VS Code loads, as `code/install.sh` intends.

## Implementation details
- `VS_PATH` per OS: set it in `install.mac.sh`/`install.ubuntu.sh` or branch on `$OS`.
- **`ln -f` must not destroy an existing regular file**: move it to `<name>.bak` first.
- Merge into `code/settings.json`, keeping their comment, these live keys: `dev.containers.dockerPath`, `dev.containers.dockerComposePath`, `js/ts.experimental.useTsgo`, `intellij.region`, `intellij.dataSharing`, `git.ignoreMissingGitWarning`, `makefile.configureOnOpen`.
- Drop stale: `python.showStartPage`, `python.languageServer: Pylance` next to the `ms-pyright.pyright` extension (keep the setting, remove that extension), and the unused `workbench.editorAssociations` entry.
- Extensions: remove the deprecated `msjsdiag.vscode-react-native` and `ms-vscode.vscode-typescript-next`; replace the per-line comments with a list in one loop.
- Never run this against the real `$HOME`; applying it is task 16.

## Done when
In a container with a throwaway `HOME`, on both OS branches: links point at the repo, an existing file survives as `.bak`, and a second run leaves the `.bak` intact.
