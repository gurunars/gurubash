" Load plugins
:filetype indent on
:filetype on
:filetype plugin on

" Change leader commands character
:let mapleader = ","

" Romove trailing spaces automatically
" :autocmd BufWritePre * :%s/\s\+$//e

" Indentation
:set smartindent                    "turn on smart indentation
:set tabstop=4                      "set tab character to 4 characters
:set expandtab                      "enter spaces when tab is pressed
:set shiftwidth=4                   "indent width for autoindent
:set softtabstop=4
:set autoindent                     "copy indent from current line when starting a new line
":set paste                         "disable wired indentation when pasting

" Folding
":set foldenable
":set fdm=indent

" Spaces/tabs highlighting
:hi ExtraSpaces ctermbg=DarkMagenta ctermfg=DarkMagenta guibg=DarkMagenta guifg=DarkMagenta
:match ExtraSpaces /\s\+\%#\@<!$/

:hi Tabs ctermbg=DarkRed ctermfg=DarkRed guibg=DarkMagenta guifg=DarkMagenta
:2match Tabs /\t/

" Highlight search results
:set hlsearch

" Configure search
" smart case sensitivity
:set ignorecase
:set smartcase
" smart replacement
:set gdefault
" handy highlighting
:set incsearch
:set showmatch
:set hlsearch
" stop highlighting
:nnoremap <leader><space> :noh<cr>

" Handline line lengths
:set textwidth=80
:set formatoptions=qrn1
:highlight OverLength ctermbg=red ctermfg=white
:3match OverLength /\%81v.\+/

" Most frequent typo ; instad of :
:nnoremap ; :

" Misc
:set scrolloff=3                    " have 3 lines of offset (or buffer) when scrolling
":set number                         " enable line numbering
:set statusline=%F%m%r%h%w\ [TYPE=%Y\ %{&ff}]\ [%l/%L\ (%p%%)] "Informative status line
:set laststatus=2 " make sure that the status line is shown
:set backspace=indent,eol,start     " Make backspaces more powerfull
:set ruler                          " show line and column number
:syntax on                          " syntax highlighting
:set showcmd                        " show (partial) command in status line
":set mouse=a                        " enable mouse in vim

" Highlight current cursor location (fucking handy)
" togle with \t
:hi CursorLine   cterm=NONE ctermbg=DarkBlue ctermfg=white guibg=DarkBlue guifg=white
:hi CursorColumn cterm=NONE ctermbg=DarkBlue ctermfg=white guibg=DarkBlue guifg=white
:nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>

" Redraw higlighting when exiting insert mode
:autocmd InsertLeave * redraw!
