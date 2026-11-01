---
status: review
priority: medium
size: S
depends_on: [17]
---
# Remove conda and dotnet, keep the rest as extensions

## Request

> I personally don't care about what is always on. I think conda and dotnet can be removed foreever.
> android, go, java and ai should be extensions.

(the user, 2026-11-01)

## Contract

- conda and dotnet are gone: their configs, extensions and any mention, with nothing left to enable.
- android, go, java and ai are extensions, off in an ordinary shell until loaded.
- Nothing is chosen as always-on: `~/.config/gurubash/default-extensions` holds nothing by default.
- python is not named in the request: it stays as task 17 leaves it.
- A tool that relied on one of these being always there is the user's to load. The README says how.

## Done when

No file names conda or dotnet; a new shell has android, go, java and ai off, and each loads as an
extension; `make check` or the repository's own check passes.

The re-link on the user's machine (`make defaults.install git.install vim.install`) is run by the
session after this lands, not by the executor.
