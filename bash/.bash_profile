#
# ~/.bash_profile
#

# Prefer US English and use UTF-8
export LANG="en_US.UTF-8";
export LC_ALL="en_US.UTF-8";

export PATH=~/bin:~/.local/bin:$PATH

# Starts Univeral Wayland Session Manager
if uwsm check may-start && uwsm select; then
  # finalize and clean if restarting from a crash
  uwsm finalize WAYLAND_DISPLAY DISPLAY XCURSOR_SIZE XCURSOR_THEME
  systemctl --user reset-failed >/dev/null 2>&1 || true
  exec uwsm start default
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
