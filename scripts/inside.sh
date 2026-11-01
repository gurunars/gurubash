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

# python bins start with python3: a clean PATH has no bare `python`
for f in "${py_files[@]}"; do
  head -n1 "$f" | grep -Eq '^#!/usr/bin/env python3$' || bad "shebang is not python3: $f"
done

# installers never write into brew's prefix (bin/ or opt/)
grep -En '\bln\b.*/opt/homebrew/(bin|opt)/' */install*.sh && bad "installer links into brew's prefix"

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

# vim: e, f and r are rebase-todo maps only; in any other file they keep vim's own meaning.
vimtest=$(mktemp -d /tmp/vimtest.XXXXXX)
printf 'pick abc1234 subject\n' >"$vimtest/git-rebase-todo"
printf 'pick abc1234 subject\n' >"$vimtest/plain.txt"
for name in git-rebase-todo plain.txt; do
  (cd "$vimtest" && vim -u /repo/vim/vimrc -es \
    -c "redir! > $vimtest/$name.maps | echo &filetype | silent nmap e | silent nmap f | silent nmap r | redir END | q" \
    "$name" </dev/null >/dev/null 2>&1)
done
for k in e f r; do
  grep -q "^n  $k .*:s/pick/$k/<CR>" "$vimtest/git-rebase-todo.maps" ||
    bad "vim: '$k' is not the rebase todo map in a git-rebase-todo file: $(cat "$vimtest/git-rebase-todo.maps")"
  grep -q 'pick/' "$vimtest/plain.txt.maps" && bad "vim: '$k' is overridden in a plain file: $(cat "$vimtest/plain.txt.maps")"
done
rm -rf "$vimtest"

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

# pkg demo: creates demo/__init__.py and demo/tests.py, both empty, in a scratch dir.
# Regression: it crashed with FileExistsError on the second mkdir.
pkg_dir=$(mktemp -d /tmp/pkg-demo.XXXXXX)
(cd "$pkg_dir" && python3 -B /repo/python/bins/pkg demo >/dev/null 2>&1) || bad "pkg demo crashed"
for m in __init__.py tests.py; do
  [ -f "$pkg_dir/demo/$m" ] && [ ! -s "$pkg_dir/demo/$m" ] || bad "pkg demo: demo/$m missing or not empty"
done
# A second run keeps what is already there rather than truncating it.
printf 'x\n' >"$pkg_dir/demo/tests.py"
(cd "$pkg_dir" && python3 -B /repo/python/bins/pkg demo >/dev/null 2>&1) || bad "pkg demo crashed on a second run"
[ "$(cat "$pkg_dir/demo/tests.py")" = "x" ] || bad "pkg demo: second run truncated demo/tests.py"
rm -rf "$pkg_dir"

# assume-role: an external id reaches `aws sts assume-role` as --external-id, and an
# absent USER gives the anonymous session name. A stub aws on PATH records its argv
# and prints fake credentials; SHELL is /bin/true so the spawned shell exits at once.
ar_dir=$(mktemp -d /tmp/assume-role.XXXXXX)
ar_bin="$ar_dir/bin"
mkdir -p "$ar_bin"
cat >"$ar_bin/aws" <<'STUB'
#!/bin/sh
printf '%s\n' "$@" >"$AR_ARGS"
printf 'AK\tSK\tST\n'
STUB
chmod +x "$ar_bin/aws"
ar_role='arn:aws:iam::123456789012:role/x'
ar_true=$(command -v true)
ar_want=$(printf '%s\n' sts assume-role --role-arn "$ar_role" --role-session-name \
  Personal-assumed-anonymous-role --query \
  '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' \
  --output text --external-id ext)
env -i HOME="$ar_dir/home" PATH="$ar_bin:/usr/bin:/bin" AR_ARGS="$ar_dir/args" SHELL="$ar_true" \
  python3 -B /repo/aws/bins/assume-role "$ar_role" ext >/dev/null 2>&1 ||
  bad "assume-role crashes when given an external id"
ar_got=$(cat "$ar_dir/args" 2>/dev/null || true)
[ "$ar_got" = "$ar_want" ] || bad "assume-role: aws argv is [$(echo $ar_got)], want [$(echo $ar_want)]"
# Without an external id, no --external-id is passed.
rm -f "$ar_dir/args"
env -i HOME="$ar_dir/home" PATH="$ar_bin:/usr/bin:/bin" AR_ARGS="$ar_dir/args" SHELL="$ar_true" \
  python3 -B /repo/aws/bins/assume-role "$ar_role" >/dev/null 2>&1 ||
  bad "assume-role crashes without an external id"
grep -qx -- '--external-id' "$ar_dir/args" 2>/dev/null && bad "assume-role: --external-id passed without an external id"
rm -rf "$ar_dir"

# code/install.sh: on both OS branches the links point at the repo, an existing
# regular file survives as .bak, and a second run leaves that .bak intact.
for os in mac ubuntu; do
  if [ "$os" = mac ]; then rel="Library/Application Support/Code/User"; else rel=".config/Code/User"; fi
  vs_home=$(mktemp -d /tmp/vscode-home.XXXXXX)
  vs_dir="$vs_home/$rel"
  mkdir -p "$vs_dir"
  printf 'live\n' >"$vs_dir/settings.json"
  run_vs() { env HOME="$vs_home" GURUBASH=/repo OS="$os" bash /repo/code/install.sh >/dev/null 2>&1; }
  run_vs || bad "code/install.sh ($os) failed on a first run"
  for f in settings.json keybindings.json; do
    [ "$(readlink "$vs_dir/$f")" = "/repo/code/$f" ] || bad "code ($os): $f is not linked to the repo"
  done
  [ "$(cat "$vs_dir/settings.json.bak" 2>/dev/null)" = live ] || bad "code ($os): existing settings.json did not survive as .bak"
  run_vs || bad "code/install.sh ($os) failed on a second run"
  [ "$(cat "$vs_dir/settings.json.bak" 2>/dev/null)" = live ] || bad "code ($os): second run changed settings.json.bak"
  [ "$(readlink "$vs_dir/settings.json")" = "/repo/code/settings.json" ] || bad "code ($os): second run broke the settings.json link"
  rm -rf "$vs_home"
done

# PATH must not grow with nested shells; a non-interactive shell prints nothing
# and starts no agent.
rc_home=$(mktemp -d /tmp/rc-home.XXXXXX)
rc_bin=$(mktemp -d /tmp/rc-bin.XXXXXX)
printf '#!/bin/sh\ntouch "%s/agent-started"\n' "$rc_home" >"$rc_bin/ssh-agent"
chmod +x "$rc_bin/ssh-agent"
printf 'export GURUBASH=/repo\n. ${GURUBASH}/loader\n' >"$rc_home/.gurubashrc"
printf '. "${HOME}/.gurubashrc"\n' >"$rc_home/.bashrc"
cp "$rc_home/.bashrc" "$rc_home/.profile"
mkdir -p "$rc_home/.personal"   # empty: must not source a literal '*'
rc_run() { env -i HOME="$rc_home" TERM=xterm PATH="$rc_bin:/usr/bin:/bin" "$@"; }
printf '#!/bin/sh\necho "$PATH" | tr : "\\n" | wc -l\n' >"$rc_bin/count"
chmod +x "$rc_bin/count"
d1=$(rc_run bash -lic 'count' 2>&1 | tail -n1)
d2=$(rc_run bash -lic 'bash -ic count' 2>&1 | tail -n1)
d3=$(rc_run bash -lic 'bash -ic "bash -ic count"' 2>&1 | tail -n1)
[ "$d1" = "$d2" ] && [ "$d2" = "$d3" ] ||
  bad "PATH grows with nested shells: depth 1/2/3 = $d1/$d2/$d3 entries"
rm -f "$rc_home/agent-started"
ni_out=$(rc_run bash -c '. "$HOME/.gurubashrc"' 2>&1)
[ -z "$ni_out" ] || bad "non-interactive shell printed: $ni_out"
[ ! -e "$rc_home/agent-started" ] || bad "non-interactive shell started ssh-agent"
rm -rf "$rc_home" "$rc_bin"

# make -n install
make -n install >/dev/null || bad "make -n install"

# a named component runs its own recipe; tasks/ and scripts/ are not installed.
# Captured first: grep -q exiting early would SIGPIPE make, and pipefail hides the match.
vim_plan=$(make -n vim.install)
grep -q 'Installed vim' <<<"$vim_plan" || bad "make -n vim.install runs nothing"
install_plan=$(make -n install)
for d in tasks scripts; do
  grep -q "Installed $d" <<<"$install_plan" && bad "make -n install installs $d/"
done

if [ "$fail" -ne 0 ]; then echo "task check: RED" >&2; exit 1; fi
echo "task check: green"
