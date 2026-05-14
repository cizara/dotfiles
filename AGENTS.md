# AGENTS.md

Arch Linux dotfiles repository managed with GNU Stow. Each directory contains configs for a specific application.

## Configuration Locations

**Shell & Terminal**
- `bash/` - Bash shell
- `tmux/` - Terminal multiplexer
- `starship/` - Shell prompt
- `environment.d/` - Environment variables

**Terminal Emulators**
- `kitty/` - Kitty terminal
- `ghostty/` - Ghostty terminal

**Editors**
- `nvim/` - Neovim
- `vim/` - Vim
- `vscode/` - VS Code
- `zed/` - Zed editor

**Window Managers (Wayland)**
- `sway/` - Sway compositor
- `hyprland/` - Hyprland compositor
- `quickshell/` - QuickShell
- `uwsm/` - Wayland session manager

**Desktop Components**
- `waybar/` - Status bar
- `wofi/` - App launcher
- `mako/` - Notifications
- `swaylock/` - Screen locker
- `imv/` - Image viewer

**Utilities**
- `bin/` - Custom scripts
- `gitconfig/` - Git config
- `cssh/` - ClusterSSH

## Structure

Each directory uses stow's structure: `package/.config/app/` → `~/.config/app/`
