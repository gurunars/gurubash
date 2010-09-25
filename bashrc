# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi   

# Make bash autocomplete with up arrow from bash history
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

#Add to the end of the ~/.basrc file
#Colors the terminal in a nice way and shows git branch in a prompt all the time
#Adds some additional information to terminal                                   

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}                                                                             

#wrapper for several parser - add hg and svn support in the future
function branch {                                                 
  parse_git_branch                                                
}                                                                 

function proml {
  local        blue="\[\033[0;34m\]"
  local        BLUE="\[\033[1;34m\]"
  local         red="\[\033[0;31m\]"
  local         RED="\[\033[1;31m\]"
  local       green="\[\033[0;32m\]"
  local       GREEN="\[\033[1;32m\]"
  local        cyan="\[\033[0;36m\]"
  local        CYAN="\[\033[1;36m\]"
  local       white="\[\033[0;37m\]"
  local       WHITE="\[\033[1;37m\]"
  case $TERM in
    xterm*)
    TITLEBAR='\[\033]0;\u@\h:\w\007\]'
    ;;
    *)
    TITLEBAR=""
    ;;
  esac

PS1="${TITLEBAR}\
$RED[$BLUE\$(date +%H:%M)$RED]\
$RED[$BLUE\u@\h:$cyan\w$green\$(branch)$RED]\
$WHITE\$ "
PS2='> '
PS4='+ '
}
proml

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Envireonment variables' definitons
if [ -f ~/.bash_env ]; then
    . ~/.bash_env
fi                                                                                                       
