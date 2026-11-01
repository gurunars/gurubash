#!/usr/bin/env bash
# Runs inside the check container, repo mounted read-only at /repo.
set -uo pipefail
cd /repo
mkdir -p "$HOME"

fail=0
bad() { echo "FAIL: $*" >&2; fail=1; }

# A worktree's .git points outside the mount, so git cannot be used on /repo.
files=$(find . -path ./.git -prune -o -path ./.tasks-logs -prune -o -type f -print | sed 's|^\./||' | sort)

is_shell() { head -n1 "$1" | grep -Eq '^#!.*\b(ba|z|da)?sh\b'; }
is_python() { head -n1 "$1" | grep -Eq '^#!.*\bpython'; }

shell_files=() py_files=()
while IFS= read -r f; do
  [ -f "$f" ] || continue
  case "$f" in
    */install*.sh | install*.sh | loader | */loader | */loader.* | pkg-manager/get-os.sh | theming/*)
      shell_files+=("$f") ;;
    bins/* | */bins/*)
      if is_python "$f"; then py_files+=("$f")
      elif is_shell "$f"; then shell_files+=("$f"); fi ;;
  esac
done <<<"$files"

# shell: shellcheck (error severity, always as bash) + bash -n
for f in "${shell_files[@]}"; do
  shellcheck --severity=error --shell=bash --format=gcc "$f" || bad "shellcheck $f"
  bash -n "$f" 2>&1 || bad "bash -n $f"
done

# python syntax
for f in "${py_files[@]}"; do
  python3 -I -c 'import ast,sys; ast.parse(open(sys.argv[1]).read(), sys.argv[1])' "$f" 2>&1 \
    || bad "python $f"
done

# JSONC
jsonc=$(printf '%s\n' "$files" | grep -E '^(code/.*\.json|\.vscode/settings\.json)$' || true)
for f in $jsonc; do
  python3 -I - "$f" <<'PY' || bad "jsonc $f"
import json, re, sys
path = sys.argv[1]
s = open(path).read()
out, i, n, instr = [], 0, len(s), False
while i < n:
    c = s[i]
    if instr:
        out.append(c)
        if c == "\\":
            out.append(s[i + 1]); i += 1
        elif c == '"':
            instr = False
    elif c == '"':
        instr = True; out.append(c)
    elif s.startswith("//", i):
        while i < n and s[i] != "\n": i += 1
        continue
    elif s.startswith("/*", i):
        j = s.find("*/", i + 2)
        if j < 0: print(f"{path}: unterminated comment"); sys.exit(1)
        i = j + 2; continue
    else:
        out.append(c)
    i += 1
text = re.sub(r",(\s*[}\]])", r"\1", "".join(out))
try:
    json.loads(text)
except json.JSONDecodeError as e:
    print(f"{path}:{e.lineno}: {e.msg}"); sys.exit(1)
PY
done

# gitconfig
(cd /tmp && git config -f /repo/git/gitconfig --list >/dev/null) || bad "git/gitconfig does not parse"

# vim
vim -u vim/vimrc -es -V1/tmp/vim.log -c 'qa!' </dev/null >/dev/null 2>&1
if grep -E '^E[0-9]+' /tmp/vim.log; then bad "vim/vimrc reports errors"; fi

# loopback
loop=$(printf '%s\n' "$files" | grep -Ev '^(AGENTS\.md|scripts/inside\.sh|tasks/.*)$' |
  while IFS= read -r f; do [ -f "$f" ] && grep -nIE \
    -e '0\.0\.0\.0' -e '\[::\]' -e '[=" ]::[" ]' -e '://localhost' \
    -e '(^|[[:space:]])-p[[:space:]]+[0-9]+:[0-9]+' -e '--publish[= ][0-9]+:[0-9]+' \
    -- "$f" | sed "s|^|$f:|"; done)
if [ -n "$loop" ]; then echo "$loop" >&2; bad "loopback: bind-any or non-loopback address"; fi

# credentials: a first run with a full name and an email, in a throwaway HOME.
# `id` is faked so the installer does not take its root exit.
cred_home=$(mktemp -d /tmp/cred-home.XXXXXX)
cred_bin=$(mktemp -d /tmp/cred-bin.XXXXXX)
printf '#!/bin/sh\necho jane\n' >"$cred_bin/id" && chmod +x "$cred_bin/id"
printf 'Jane Doe\na@example.com\n' |
  env HOME="$cred_home" GURUBASH=/repo PATH="$cred_bin:$PATH" \
    bash /repo/credentials/install.sh >/dev/null 2>&1 || bad "credentials/install.sh failed on a first run"
cred_got=$(env -i HOME="$cred_home" bash -c '. "$HOME/.personal/credentials" && printf "%s|%s" "$NAME" "$EMAIL"' 2>&1)
[ "$cred_got" = "Jane Doe|a@example.com" ] ||
  bad "credentials: sourced NAME|EMAIL is '$cred_got', want 'Jane Doe|a@example.com'"
rm -rf "$cred_home" "$cred_bin"

# make -n install
make -n install >/dev/null || bad "make -n install"

if [ "$fail" -ne 0 ]; then echo "task check: RED" >&2; exit 1; fi
echo "task check: green"
