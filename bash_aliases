alias spack='dpkg-buildpackage -rfakeroot -uc -us -sa -tc -D'
alias pack='git-buildpackage -rfakeroot -uc -us -sa -tc -D --git-tag --git-ignore-new'
alias ls='ls -h --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -hl'
alias la='ls -hA'
alias l='ls -hCF'
alias dch='dch --no-auto-nmu'
alias pylint='pylint -f colorized -i y -r n '
alias clean='find . -name "*.pyc" -or -name "*~" -or -name "*.pyo" -or -name "*.swp" -delete'
alias z='cd ..'
alias zz='cd ../..'
alias zzz='cd ../../..'
alias cs='mcs -pkg:gtk-sharp-2.0'
alias giff='git diff --cached'
#Add python application's parent dir to PYTHONPATH
alias pa='filepath=`pwd`;export PYTHONPATH=$PYTHONPATH:${filepath%/*}'
gtag='git-buildpackage --git-tag-only -d'

function col {
    first="awk '{print "
    last="}'"
    cmd="${first}\$${1}${last}"
    eval $cmd
}

