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
    */install*.sh | install*.sh | loader | */loader | */loader.* | core/pkg-manager/get-os.sh | core/theming/* | core/ext/rcfile)
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
grep -En '\bln\b.*/opt/homebrew/(bin|opt)/' core/*/install*.sh extensions/*/install*.sh && bad "installer links into brew's prefix"

# Machines installed before the core/extensions split link these old paths until
# they re-link. Plain copies or symlinks, they must stay the same as the real file.
for pair in defaults/profile:core/defaults/profile git/gitconfig:core/git/gitconfig \
  vim/vimrc:core/vim/vimrc code/settings.json:extensions/code/settings.json \
  code/keybindings.json:extensions/code/keybindings.json; do
  cmp -s "${pair%%:*}" "${pair##*:}" || bad "${pair%%:*} differs from ${pair##*:}: old links would read stale config"
done

# JSONC
jsonc=$(printf '%s\n' "$files" | grep -E '^((extensions/)?code/.*\.json|\.vscode/settings\.json)$' || true)
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
(cd /tmp && git config -f /repo/core/git/gitconfig --list >/dev/null) || bad "core/git/gitconfig does not parse"

# vim
vim -u core/vim/vimrc -es -V1/tmp/vim.log -c 'qa!' </dev/null >/dev/null 2>&1
if grep -E '^E[0-9]+' /tmp/vim.log; then bad "core/vim/vimrc reports errors"; fi

# vim: e, f and r are rebase-todo maps only; in any other file they keep vim's own meaning.
vimtest=$(mktemp -d /tmp/vimtest.XXXXXX)
printf 'pick abc1234 subject\n' >"$vimtest/git-rebase-todo"
printf 'pick abc1234 subject\n' >"$vimtest/plain.txt"
for name in git-rebase-todo plain.txt; do
  (cd "$vimtest" && vim -u /repo/core/vim/vimrc -es \
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
    bash /repo/core/credentials/install.sh >/dev/null 2>&1 || bad "core/credentials/install.sh failed on a first run"
cred_got=$(env -i HOME="$cred_home" bash -c '. "$HOME/.personal/credentials" && printf "%s|%s" "$NAME" "$EMAIL"' 2>&1)
[ "$cred_got" = "Jane Doe|a@example.com" ] ||
  bad "credentials: sourced NAME|EMAIL is '$cred_got', want 'Jane Doe|a@example.com'"
rm -rf "$cred_home" "$cred_bin"

# pkg demo: creates demo/__init__.py and demo/tests.py, both empty, in a scratch dir.
# Regression: it crashed with FileExistsError on the second mkdir.
pkg_dir=$(mktemp -d /tmp/pkg-demo.XXXXXX)
(cd "$pkg_dir" && python3 -B /repo/extensions/python/bins/pkg demo >/dev/null 2>&1) || bad "pkg demo crashed"
for m in __init__.py tests.py; do
  [ -f "$pkg_dir/demo/$m" ] && [ ! -s "$pkg_dir/demo/$m" ] || bad "pkg demo: demo/$m missing or not empty"
done
# A second run keeps what is already there rather than truncating it.
printf 'x\n' >"$pkg_dir/demo/tests.py"
(cd "$pkg_dir" && python3 -B /repo/extensions/python/bins/pkg demo >/dev/null 2>&1) || bad "pkg demo crashed on a second run"
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
  python3 -B /repo/extensions/aws/bins/assume-role "$ar_role" ext >/dev/null 2>&1 ||
  bad "assume-role crashes when given an external id"
ar_got=$(cat "$ar_dir/args" 2>/dev/null || true)
[ "$ar_got" = "$ar_want" ] || bad "assume-role: aws argv is [$(echo $ar_got)], want [$(echo $ar_want)]"
# Without an external id, no --external-id is passed.
rm -f "$ar_dir/args"
env -i HOME="$ar_dir/home" PATH="$ar_bin:/usr/bin:/bin" AR_ARGS="$ar_dir/args" SHELL="$ar_true" \
  python3 -B /repo/extensions/aws/bins/assume-role "$ar_role" >/dev/null 2>&1 ||
  bad "assume-role crashes without an external id"
grep -qx -- '--external-id' "$ar_dir/args" 2>/dev/null && bad "assume-role: --external-id passed without an external id"
rm -rf "$ar_dir"

# extensions/code/install.sh: on both OS branches the links point at the repo, an existing
# regular file survives as .bak, and a second run leaves that .bak intact.
for os in mac ubuntu; do
  if [ "$os" = mac ]; then rel="Library/Application Support/Code/User"; else rel=".config/Code/User"; fi
  vs_home=$(mktemp -d /tmp/vscode-home.XXXXXX)
  vs_dir="$vs_home/$rel"
  mkdir -p "$vs_dir"
  printf 'live\n' >"$vs_dir/settings.json"
  run_vs() { env HOME="$vs_home" GURUBASH=/repo OS="$os" bash /repo/extensions/code/install.sh >/dev/null 2>&1; }
  run_vs || bad "extensions/code/install.sh ($os) failed on a first run"
  for f in settings.json keybindings.json; do
    [ "$(readlink "$vs_dir/$f")" = "/repo/extensions/code/$f" ] || bad "code ($os): $f is not linked to the repo"
  done
  [ "$(cat "$vs_dir/settings.json.bak" 2>/dev/null)" = live ] || bad "code ($os): existing settings.json did not survive as .bak"
  run_vs || bad "extensions/code/install.sh ($os) failed on a second run"
  [ "$(cat "$vs_dir/settings.json.bak" 2>/dev/null)" = live ] || bad "code ($os): second run changed settings.json.bak"
  [ "$(readlink "$vs_dir/settings.json")" = "/repo/extensions/code/settings.json" ] || bad "code ($os): second run broke the settings.json link"
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

# A shell loads core only, plus what default-extensions names.
mkdir -p "$rc_home/go/bin" "$rc_home/Library/Android/sdk/platform-tools"
rc_path() { rc_run bash -c '. "$HOME/.gurubashrc"; echo ":$PATH:"' 2>/dev/null; }
ext_list="$rc_home/.config/gurubash/default-extensions"
plain=$(rc_path)
for e in "$rc_home/go/bin" "$rc_home/Library/Android/sdk/platform-tools" /repo/extensions/; do
  case "$plain" in *":$e"*) bad "a new shell has $e on PATH with no default-extensions" ;; esac
done
rc_run bash -c '. "$HOME/.gurubashrc"; command -v aws pkg assume-role' >/dev/null 2>&1 &&
  bad "a new shell has an extension's command on PATH"
# android, ai and java set variables when loaded; none is set in a new shell.
plain_env=$(rc_run bash -c '. "$HOME/.gurubashrc"; echo "${ANDROID_HOME:-}|${AI_MODEL:-}|${JAVA_HOME:-}"' 2>/dev/null)
[ "$plain_env" = "||" ] || bad "a new shell has android, ai or java loaded: ANDROID_HOME|AI_MODEL|JAVA_HOME is [$plain_env]"
mkdir -p "$(dirname "$ext_list")"
printf 'go\n\npython' >"$ext_list"
named=$(rc_path)
case "$named" in *":$rc_home/go/bin:"*) ;; *) bad "default-extensions naming go does not add ~/go/bin: $named" ;; esac
case "$named" in *":/repo/extensions/python/bins:"*) ;; *) bad "default-extensions naming python does not add its bins: $named" ;; esac
case "$named" in *":$rc_home/Library/Android/sdk/platform-tools:"*) bad "android is on PATH though default-extensions does not name it" ;; esac
d1=$(rc_run bash -lic 'count' 2>&1 | tail -n1)
d2=$(rc_run bash -lic 'bash -ic count' 2>&1 | tail -n1)
[ "$d1" = "$d2" ] || bad "PATH grows with nested shells and extensions: depth 1/2 = $d1/$d2 entries"
# android and ai load when named, and set their variables; a nested shell adds nothing again.
printf 'android\nai\n' >"$ext_list"
loaded_env=$(rc_run bash -c '. "$HOME/.gurubashrc"; echo "$ANDROID_HOME|$AI_MODEL"' 2>/dev/null)
[ "$loaded_env" = "$rc_home/Library/Android/sdk|gemma4:26b" ] ||
  bad "default-extensions naming android and ai: ANDROID_HOME|AI_MODEL is [$loaded_env]"
case "$(rc_path)" in *":$rc_home/Library/Android/sdk/platform-tools:"*) ;; *) bad "default-extensions naming android does not add its platform-tools" ;; esac
d1=$(rc_run bash -lic 'count' 2>&1 | tail -n1)
d2=$(rc_run bash -lic 'bash -ic count' 2>&1 | tail -n1)
[ "$d1" = "$d2" ] || bad "PATH grows with nested shells and android: depth 1/2 = $d1/$d2 entries"
# An unknown name, or one climbing out of extensions/: one line each on stderr, and the shell starts.
printf 'nosuch\n../core/vim\ngo\n' >"$ext_list"
unk_err=$(rc_run bash -c '. "$HOME/.gurubashrc"; echo started >&2' 2>&1 >/dev/null)
[ "$(grep -c 'unknown extension' <<<"$unk_err")" = 2 ] && [ "$(wc -l <<<"$unk_err")" = 3 ] && [ "$(tail -n1 <<<"$unk_err")" = started ] ||
  bad "unknown default-extensions names: stderr is [$unk_err], want one line each, then the shell starts"
case "$(rc_path)" in *":$rc_home/go/bin:"*) ;; *) bad "an unknown extension name stopped the ones after it" ;; esac
rm -rf "$rc_home" "$rc_bin"

# ext use: a nested shell with extensions loaded; leaving it frees PATH, aliases and
# functions. Run on a copy of the repo holding a test extension "probe" (an alias, a
# function, a bins dir) and one holding another alias ("probe2").
ex_dir=$(mktemp -d /tmp/ext-use.XXXXXX)
ex_repo="$ex_dir/repo"
ex_home="$ex_dir/home"
ex_stub="$ex_dir/stub"
mkdir -p "$ex_home/.config/gurubash/profiles" "$ex_stub"
cp -a /repo "$ex_repo"
rm -rf "$ex_repo/.git"
mkdir -p "$ex_repo/extensions/probe/bins" "$ex_repo/extensions/probe2" "$ex_repo/extensions/probe3" "$ex_repo/extensions/missing"
printf 'true\n' >"$ex_repo/extensions/probe3/loader"
printf 'alias probe_alias="echo probed"\nprobe_fn() { :; }\nexport PROBE=1\n' >"$ex_repo/extensions/probe/loader"
printf 'alias probe2_alias="echo probed2"\n' >"$ex_repo/extensions/probe2/loader"
printf 'false\n' >"$ex_repo/extensions/missing/installed"
printf '# mine\nprobe  # an extension\nprobe2\n' >"$ex_home/.config/gurubash/profiles/both"
printf 'export GURUBASH=%s\n. ${GURUBASH}/loader\n' "$ex_repo" >"$ex_home/.bashrc"
printf '#!/bin/sh\n' >"$ex_stub/aws" && chmod +x "$ex_stub/aws"
ex_run() { env -i HOME="$ex_home" TERM=xterm PATH="$ex_stub:/usr/bin:/bin" "$@"; }
ex_run EX_REPO="$ex_repo" bash -ic 'ext ls' >"$ex_dir/ls" 2>&1 || bad "ext ls failed: $(cat "$ex_dir/ls")"
grep -qE '^  aws$' "$ex_dir/ls" && grep -q 'missing (not installed: make missing.install)' "$ex_dir/ls" &&
  grep -q '^  cloud: aws python$' "$ex_dir/ls" && grep -q '^  both: probe probe2$' "$ex_dir/ls" ||
  bad "ext ls does not list extensions, profiles and the missing one: $(cat "$ex_dir/ls")"

cat >"$ex_dir/outer.sh" <<'OUTER'
snap() { echo "$PATH"; alias; declare -F; }
before=$(snap)
ext use cloud both <<'L1'
echo "L1 ext=$GURUBASH_EXT"
case ":$PATH:" in *":$EX_REPO/extensions/aws/bins:"*) echo "L1 aws-bins";; esac
alias probe_alias >/dev/null && echo "L1 alias"
declare -F probe_fn >/dev/null && echo "L1 fn"
echo "L1 probe=$PROBE"
ext use cloud probe
echo "L1 same-name ext=$GURUBASH_EXT"
ext use probe3 <<'L2'
echo "L2 ext=$GURUBASH_EXT"
alias probe_alias >/dev/null && echo "L2 alias-from-outer"
exit 7
L2
echo "L1 after-inner status=$? ext=$GURUBASH_EXT"
alias probe2_alias >/dev/null && echo "L1 alias2"
exit 3
L1
echo "status=$?"
after=$(snap)
[ "$before" = "$after" ] && echo "FREED"
[ -z "$GURUBASH_EXT" ] && [ -z "$PROBE" ] && echo "CLEAN"
ext use missing; echo "refused=$?"
ext use nosuch; echo "unknown=$?"
ext off; echo "off-outside=$?"
ext use probe <<'L1'
ext off
echo "NOT REACHED"
L1
echo "off-status=$?"
OUTER
cp "$ex_dir/outer.sh" "$ex_home/outer.sh"
ex_out=$(ex_run EX_REPO="$ex_repo" bash -ic '. "$HOME/outer.sh"' 2>"$ex_dir/err" </dev/null) || true
for want in 'L1 ext=aws python probe probe2' 'L1 aws-bins' 'L1 alias' 'L1 fn' 'L1 probe=1' \
  'L1 same-name ext=aws python probe probe2' 'L2 ext=aws python probe probe2 probe3' 'L2 alias-from-outer' \
  'L1 after-inner status=7 ext=aws python probe probe2' 'L1 alias2' 'status=3' FREED CLEAN \
  'refused=1' 'unknown=1' 'off-outside=1' 'off-status=0'; do
  grep -qxF -- "$want" <<<"$ex_out" || bad "ext use: missing '$want' in: $(echo $ex_out) / $(tail -n 5 "$ex_dir/err")"
done
grep -q 'NOT REACHED' <<<"$ex_out" && bad "ext off did not leave the shell"
grep -q 'make missing.install' "$ex_dir/err" || bad "ext use refusal does not name make missing.install"
rm -rf "$ex_dir"

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

# `make` names core only; an extension comes when asked for, with its `requires` first.
plain_plan=$(make -n)
for e in extensions/*/; do
  e=$(basename "$e")
  grep -qE "Installed $e\b|extensions/$e/" <<<"$plain_plan" && bad "make -n names the extension $e"
  ext_plan=$(make -n "$e.install") && grep -q "Installed $e" <<<"$ext_plan" || bad "make -n $e.install runs nothing"
done
grep -q 'Installed vim' <<<"$plain_plan" || bad "make -n does not install the core"
for e in aws ai; do
  req_plan=$(make -n "$e.install")
  grep -q 'Installed python' <<<"$req_plan" || bad "make -n $e.install does not include python"
  [ "$(grep -n 'Installed python' <<<"$req_plan" | cut -d: -f1)" -lt "$(grep -n "Installed $e" <<<"$req_plan" | cut -d: -f1)" ] ||
    bad "make $e.install installs $e before what it requires"
done
make -n nosuch.install >/dev/null 2>&1 && bad "make nosuch.install should fail: there is no such component"

# `make` always failed on Ubuntu. A full `make install`, core and every extension, down
# the Ubuntu path, in a throwaway HOME, with no network: everything that touches the
# system or downloads is a stub, and sudo runs nothing but records what it was asked.
# As root, so core/credentials/install.sh leaves ~/.personal empty.
ub_dir=$(mktemp -d /tmp/ubuntu-make.XXXXXX)
ub_bin="$ub_dir/bin"
ub_log="$ub_dir/sudo.log"
mkdir -p "$ub_bin" "$ub_dir/home"
cat >"$ub_bin/sudo" <<'STUB'
#!/bin/sh
echo "$*" >>"$UB_LOG"
if [ "$1" = tee ]; then cat >>"$UB_LOG"; fi
STUB
cat >"$ub_bin/dpkg" <<'STUB'
#!/bin/sh
if [ "$1" = --print-architecture ]; then echo arm64; exit 0; fi
exit 1
STUB
printf '#!/bin/sh\necho root\n' >"$ub_bin/id"
printf '#!/bin/sh\necho KEY\n' >"$ub_bin/wget"
printf '#!/bin/sh\n' >"$ub_bin/curl"
printf '#!/bin/sh\n' >"$ub_bin/code"
printf '#!/bin/sh\necho NAME\n' >"$ub_bin/ollama"
chmod +x "$ub_bin"/*
# A copy without .git: a worktree's .git points outside the mount, and git refuses it.
cp -a /repo "$ub_dir/repo"
rm -rf "$ub_dir/repo/.git"
ub_extensions=$(cd extensions && for e in */; do printf '%s.install ' "${e%/}"; done)
env HOME="$ub_dir/home" PATH="$ub_bin:$PATH" UB_LOG="$ub_log" make -C "$ub_dir/repo" install $ub_extensions </dev/null >"$ub_dir/out" 2>&1 ||
  bad "make install fails on Ubuntu: $(tail -n 5 "$ub_dir/out")"
[ ! -e "$ub_dir/home/.config/gurubash/default-extensions" ] || bad "an install created default-extensions"
for b in core/pkg-manager/bins/ubuntu/up extensions/aws/bins/assume-role extensions/python/bins/pkg; do
  [ -x "$ub_dir/repo/$b" ] || bad "$b is not executable after an install"
done
for want in \
  'apt install -y python3' \
  'apt install -y git' \
  'tee /etc/apt/keyrings/code.asc' \
  'deb [arch=arm64 signed-by=/etc/apt/keyrings/code.asc] https://packages.microsoft.com/repos/code stable main' \
  'deb [arch=arm64 signed-by=/etc/apt/keyrings/google-chrome-stable.asc] https://dl.google.com/linux/chrome/deb/ stable main'; do
  grep -qxF -- "$want" "$ub_log" 2>/dev/null || bad "make install on Ubuntu: sudo was never asked for '$want'"
done
grep -q 'apt-key' "$ub_log" 2>/dev/null && bad "make install on Ubuntu uses apt-key, which is gone"
rm -rf "$ub_dir"

if [ "$fail" -ne 0 ]; then echo "task check: RED" >&2; exit 1; fi
echo "task check: green"
