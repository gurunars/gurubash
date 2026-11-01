---
status: planned
type: bug
priority: high
size: S
depends_on: [2]
---
# First-run credentials: a full name fails and the email loses its `@`

## Request
"I want to clean them up and improve them."

## Steps to reproduce
Seen at bb5b4f6, the commands from `credentials/install.sh` on a scratch file:
1. `printf 'export NAME=__NAME\nexport EMAIL=__EMAIL\n' > c`
2. `name="Jane Doe"; perl -pi -e s/__NAME/${name}/g c`
3. `email=a@example.com; perl -pi -e s/__EMAIL/${email}/g c; cat c`

## Actual outcome
```
Substitution replacement not terminated at -e line 1.
export NAME=__NAME
export EMAIL=a.com
```

## Expected outcome
`NAME` is `Jane Doe` and `EMAIL` is `a@example.com`: the prompt itself asks for a name "delimited with space". Git then gets that identity from `git/install.sh`.

## Implementation details
Unquoted, and perl interpolates `@example`. Pass values via the environment (`perl -pi -e 's/__NAME/$ENV{NAME}/g'`), and quote the file name. The generated file must also quote values with spaces: `export NAME="Jane Doe"`, since `personal/loader` sources it. Also `username=$(eval whoami)` → `$(id -un)`. Test in the check container with a throwaway `HOME`.
