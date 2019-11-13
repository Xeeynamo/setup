# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

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
