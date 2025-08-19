#
# ~/.bash_profile
#

# Prefer US English and use UTF-8
export LANG="en_US.UTF-8";
export LC_ALL="en_US.UTF-8";

export PATH=~/bin:~/.local/bin:$PATH

# Starts Univeral Wayland Session Manager
if uwsm check may-start && uwsm select; then
  exec uwsm start default
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
