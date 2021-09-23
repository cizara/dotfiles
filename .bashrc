#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load aliases
[[ -f ~/.aliases ]] && . ~/.aliases
# Load local configs
[[ -f ~/.bash_local ]] && . ~/.bash_local

# command line with only current directory
PS1='[\u@\h \W]\$ '
# command line with full path
PS1='[\u@\h:\w]\$ '

# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=50000000;
export HISTFILESIZE=$HISTSIZE;
export HISTCONTROL=ignoredups;
# Make some commands not show up in history
export HISTIGNORE=" *:ls:cd:cd -:pwd:exit:date:* --help:* -h:pony:pony add *:pony update *:pony save *:pony ls:pony ls *";

# Prefer US English and use UTF-8
export LANG="en_US.UTF-8";
export LC_ALL="en_US.UTF-8";

# If running from tty1 start Sway
if [ "$(tty)" = "/dev/tty1" ]; then
  export WLR_DRM_NO_MODIFIERS=1
  dbus-launch sway -d 2> ~/.sway.log
fi

export PATH=$PATH:~/bin:~/.local/bin
