---
status: active
priority: high
size: M
depends_on: [14, 17]
---
# Extension profiles: load a bunch of configs temporarily, then free them

## Request
"It would be nice to have extension profiles where a bunch of configs are loaded temporarily (like in venv) and then freed."

## Why
Work on one kind of project with its tools on hand, and leave no trace in the shell afterwards.

## Contract
```
ext use <profile|extension>...   nested shell with those loaded; `exit` or Ctrl-D frees them
ext ls                           extensions and profiles; marks active and not-installed
ext off                          exits an `ext use` shell; error outside one
```
- A profile is `profiles/<name>` in the repo or `~/.config/gurubash/profiles/<name>` (wins): one extension or profile per line, `#` comments.
- `GURUBASH_EXT` holds the active names, space-separated; the prompt shows them as `(aws java)`.
- `ext use` inside `ext use` nests: exiting frees only the inner layer. Same name twice is a no-op.
- An extension not installed is refused, naming `make <name>.install`. Nothing is ever installed by `ext use`.
- Exit status of the nested shell is returned.

## Implementation details
Decided: a nested shell, not venv's in-place `activate`/`deactivate`. Exit frees everything, including aliases, functions and exported variables, with no snapshot to get wrong; `aws/bins/assume-role` already works this way. The cost is unexported shell state not carrying in.
- `ext` is a function in a new `core/ext/loader`, since `ext off` can't work as a script.
- Nested shell: `bash --rcfile` a generated file or `GURUBASH_EXT` read by the root `loader`, whichever keeps the core loader untouched for everyone else.
- "Installed" = an extension's optional `installed` file, a command to test; none means installed.
- Starter profiles: `profiles/android` (`android java`), `profiles/cloud` (`aws python`).
- Tab completion of names.

## Done when
In a container: `ext use cloud` has `aws`'s `bins` on `PATH` and an alias defined by a test extension; after `exit`, `PATH`, aliases and functions equal what they were. Nesting and the refusal covered too.

## Verify
- `task check`
