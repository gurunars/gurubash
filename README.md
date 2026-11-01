Shell and dotfile setup: bash, vim, git, VS Code and the tools around them,
installed with `make`.

## Install

On Ubuntu, first:

    sudo apt install -y git make

Then:

    git clone https://github.com/gurunars/gurubash.git ~/.gurubash
    cd ~/.gurubash
    make

`make -n install` shows what would run without running it.

## Core and extensions

The repository has two kinds of component:

- **Core** (`core/<name>/`) is what `make` installs and every shell loads: aliases,
  the prompt and its themes, git, vim, history, `ls` colours, and the package manager.
- **Extensions** (`extensions/<name>/`) are the tools for one kind of work: `ai`,
  `android`, `aws`, `chrome`, `code`, `go`, `java`, `python`. Nothing is installed or
  loaded for them until you ask.

Install one with `make <name>.install`. An extension's `requires` file lists the
extensions it needs (one per line); those install first, so `make aws.install` also
installs `python`.

A shell loads an extension only if `~/.config/gurubash/default-extensions` names it,
one per line. Nothing is loaded by default, and no install creates that file. A tool
that was on your `PATH` before (say `go`, or Android's platform-tools) is missing
until its extension is loaded: `make go.install`, then add `go` to the file.

## Layout

A component is a directory. These files in it are used:

- `install.sh`: run by `make` on every OS.
- `install.<os>.sh`: run by `make` on that OS only (`mac` or `ubuntu`), before `install.sh`.
- `loader`: sourced by every shell that loads the component.
- `loader.<os>`: sourced by every shell on that OS, after every component's `loader`.
- `bins/`: its directory is added to `PATH`.
- `bins/<os>/`: added to `PATH` on that OS only.

Extensions also take an optional `installed` file, a command that tests whether the
extension's tools are present. With none, the extension counts as installed.

Loaders run in every shell, nested ones included, so they stay fast, silent and safe
to source twice. `path_add [-p] DIR` adds a directory to `PATH` only if it exists and
is not already there.

`scripts/` and `tasks/` are not components and are never installed.

## Extensions in a nested shell: `ext`

`ext` loads extensions into a nested shell for one piece of work. Leaving the shell
frees them: their `PATH` entries, aliases, functions and variables are gone.

    ext ls                 list extensions and profiles
    ext use aws python     start a nested shell with these loaded
    ext use cloud          a profile, see below
    ext off                leave the nested shell (same as exit)

`ext use` refuses an extension that is not installed and says which `make` command
installs it.

## Profiles

A profile is a named list of extensions, one name per line, with `#` comments:

    # Cloud work: AWS tools and Python.
    aws
    python

Profiles live in `profiles/<name>` in the repository. Your own profiles in
`~/.config/gurubash/profiles/<name>` win over the repository's with the same name.
A profile can name another profile.

## Personal files: `~/.personal`

Every regular file in `~/.personal/` is sourced by every shell, after the aliases and
before the prompt, so it can set variables for the rest of the setup. `make` creates
the directory and, on a first run as a user (not root), `~/.personal/credentials`,
which asks for your name and email once. Keep secrets and machine-specific settings
there; the repository never contains them.

## Prompt and theme

The prompt is chosen by two variables, read when a shell starts:

- `BASH_THEME`: one of `dual-line.blue` (the default), `dual-line.white.nobold` or
  `dual-line.yellow`, from `core/theming/themes/`.
- `BASH_SHAPE`: the layout, `multiline` (the default), from `core/theming/shapes/`.

Set them in a file in `~/.personal/`, which loads before the theme does, e.g.
`export BASH_THEME=dual-line.yellow`.

## Checks: `task check`

The repository's gate is `task check`, run from the repository root. It needs only
[`task`](https://taskfile.dev) and [podman](https://podman.io). It runs every check in
a container with the repository mounted read-only, and exits non-zero naming the file
and line when something fails. The checks cover:

- shellcheck at warning severity, and `bash -n`, on every shell file;
- Python syntax and the shebang of each `bins/` Python script;
- JSONC parsing of the VS Code configuration;
- the gitconfig and `vimrc`;
- the loopback rule: nothing binds or publishes on a bind-any address;
- that a first run of the credentials installer works, and that `make install` runs
  end to end on Ubuntu with its system commands stubbed;
- that a new shell's `PATH` does not grow with nested shells and loads only what
  `default-extensions` names;
- `ext use`, `ext ls` and `ext off` behaviour;
- `make -n` for core, extensions and their `requires`.

Run it before you commit a change to the setup.
