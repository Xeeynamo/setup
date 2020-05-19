# If not running interactively, don't do anything
[[ $- != *i* ]] && return

FULL_TIME='\t'
USER_NAME='\u'
HOST_NAME='\h'
HOST_FULLNAME='\H'
CURRENT_PATH='\W'
CURRENT_FULLPATH='\w'
WHITE='\[\033[00m\]'
LIGHT_YELLOW='\[\033[33m\]'
LIGHT_PURPLE="\[\033[34m\]"
LIGHT_GREEN="\[\033[32m\]"
LIGHT_CYAN="\[\033[36m\]"
RESET="\[$(tput sgr0)\]"

export PS1="$LIGHT_PURPLE[$FULL_TIME] $LIGHT_GREEN$USER_NAME@$HOST_NAME $LIGHT_YELLOW$CURRENT_FULLPATH$LIGHT_CYAN`__git_ps1`\n$RESET$ "

alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gh='git h'
alias ghs='git h -5'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias ga='git add -A'
alias gap='git add -p'
alias gs='git status -s'
alias gd='git diff'
alias gdc='git diff --cached'
alias gri='git rebase -i'
alias gf='git fetch origin'
alias gr='git rebase origin/master'
alias gpu='git push -u origin HEAD'
alias startvs='start *.sln'
alias pi='ssh pi@raspberrypi'
