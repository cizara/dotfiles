#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=50000000;
export HISTFILESIZE=$HISTSIZE;
export HISTCONTROL=ignoredups;
# Make some commands not show up in history
export HISTIGNORE=" *:ls:cd:cd -:pwd:exit:date:* --help";

# bat as the pager. Single -p is style=plain only; -pp would also kill paging.
# BAT_PAGER is set explicitly so bat does not read PAGER and find itself.
export PAGER='bat -p'
export BAT_PAGER='less -RF'
export MANPAGER='bat -l man -p'

# Load aliases
[[ -f ~/.aliases ]] && . ~/.aliases
# Load local configs
[[ -f ~/.bash_local ]] && . ~/.bash_local

# Load K8s aliases
[[ -f ~/.kubernetes_aliases ]] && . ~/.kubernetes_aliases

# Some useful aliases
alias kubectl=kubecolor
alias ls='eza -g'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias cat='bat -p'
alias vi=vim
alias grep='grep --color'
lt() { if [ "$#" -eq 0 ]; then eza -g -T -l -L 2; else eza -g -T -l -L "$@"; fi; }
v() { if [ "$#" -eq 0 ]; then nvim .; else nvim "$@"; fi; }

# k8s command line tools
source '/usr/bin/switch.sh'
# Custom prompt
eval "$(starship init bash)"
# Setup fzf shell integration
eval "$(fzf --bash)"
# Try integration
eval "$(try init ~/try-tmp/)"
