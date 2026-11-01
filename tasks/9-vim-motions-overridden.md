---
status: planned
type: bug
priority: high
size: S
depends_on: [2]
---
# In vim, `e`, `f` and `r` no longer move or replace, in every file

## Request
"I want to clean them up and improve them."

## Steps to reproduce
Seen at bb5b4f6:
1. `vim -u ~/.gurubash/vim/vimrc -es -c 'redir! > out | silent nmap e | silent nmap f | silent nmap r | redir END | q'; cat out`

## Actual outcome
```
n  e           * :s/pick/e/<CR>
n  f           * :s/pick/f/<CR>
n  r           * :s/pick/r/<CR>
```

## Expected outcome
Built-in motions outside a rebase todo. The comment in `vim/vimrc` scopes these maps to "git rebase interactive".

## Implementation details
`autocmd FileType gitrebase nnoremap <buffer>` for the three, in an augroup; regression test runs both filetypes via `-es`.
Tidy the file while here, keeping behaviour: drop the second `hlsearch`, the dead commented-out settings, the stray `\t` comment (the map is `<Leader>c`), and repeated autocmds on re-source (augroups).
