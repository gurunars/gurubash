alias spack='dpkg-buildpackage -rfakeroot -uc -us -sa -tc -D'
alias pack='git-buildpackage -rfakeroot -uc -us -sa -tc -D --git-tag --git-ignore-new'
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias pylint='pylint -f colorized -i y -r n '
alias clean='find . -name "*.pyc" -or -name "*~" -or -name "*.pyo" -or -name "*.swp" -delete'
alias z='cd ..'
alias zz='cd ../..'
alias zzz=cd ../../..'

function col {
    first="awk '{print "
    last="}'"
    cmd="${first}\$${1}${last}"
    eval $cmd
}
