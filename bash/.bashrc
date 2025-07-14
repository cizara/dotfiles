#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load aliases
[[ -f ~/.aliases ]] && . ~/.aliases
# Load local configs
[[ -f ~/.bash_local ]] && . ~/.bash_local

# k8s command line tools
source '/usr/bin/switch.sh'
alias kubectl=kubecolor

# Some useful aliases
alias ls='eza -g'
alias cat='bat -p'
alias vi=vim
alias v=nvim
alias grep='grep --color'

# Custom prompt
eval "$(starship init bash)"

# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=50000000;
export HISTFILESIZE=$HISTSIZE;
export HISTCONTROL=ignoredups;
# Make some commands not show up in history
export HISTIGNORE=" *:ls:cd:cd -:pwd:exit:date:* --help";

# Prefer US English and use UTF-8
export LANG="en_US.UTF-8";
export LC_ALL="en_US.UTF-8";

export PATH=~/bin:~/.local/bin:$PATH

# Setup fzf shell integration
eval "$(fzf --bash)"

# Starts Univeral Wayland Session Manager
if uwsm check may-start && uwsm select; then
  exec uwsm start default
fi

# Load K8s aliases
[[ -f ~/.kubernetes_aliases ]] && . ~/.kubernetes_aliases

