---
status: planned
type: human
priority: high
size: S
depends_on: [17]
---
# Commit the exec bits and compat symlinks task 17 could not make

## Why
An agent's tools can only write plain files, with no `chmod`, `ln` or `git mv`. So task 17 committed its moved files as mode 644, and the five old paths are plain copies, not the relative symlinks it asked for. Until this is done:
- `up`, `assume-role` and `pkg` are not executable from a fresh checkout or after a pull. `make pkg-manager.install`, `make aws.install` or `make python.install` sets the bit locally, which shows as a mode change in `git status`.
- The five old paths are copies. `task check` fails if one differs from the real file, so an edit must go to both.

## TODO
Run this from the repo root, after 17 lands:
- [ ] Set the exec bits and replace the copies with symlinks:
```
chmod +x core/pkg-manager/bins/ubuntu/up core/pkg-manager/get-os.sh core/pkg-manager/install-if-missing.mac.sh core/pkg-manager/install-if-missing.ubuntu.sh extensions/aws/bins/assume-role extensions/python/bins/pkg
ln -sf ../core/defaults/profile defaults/profile
ln -sf ../core/git/gitconfig git/gitconfig
ln -sf ../core/vim/vimrc vim/vimrc
ln -sf ../extensions/code/settings.json code/settings.json
ln -sf ../extensions/code/keybindings.json code/keybindings.json
git add -A core extensions defaults git vim code && git commit -m "Restore exec bits; old config paths become symlinks"
```
- [ ] `task check`

## Done when
`git ls-files -s core extensions | grep 100755` lists those six files, `git ls-files -s defaults git vim code` shows five entries of mode 120000, and `task check` is green.
