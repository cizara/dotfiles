# AGENTS.md

Arch Linux dotfiles repository managed with GNU Stow. Each directory contains configs for a specific application.

## Configuration Locations

**Shell & Terminal**
- `bash/` - Bash shell
- `tmux/` - Terminal multiplexer
- `starship/` - Shell prompt
- `environment.d/` - Environment variables

**Terminal Emulators**
- `ghostty/` - Ghostty terminal

**Editors**
- `nvim/` - Neovim
- `vim/` - Vim
- `vscode/` - VS Code
- `zed/` - Zed editor

**Window Managers (Wayland)**
- `hyprland/` - Hyprland compositor
- `quickshell/` - QuickShell
- `uwsm/` - Wayland session manager

**Desktop Components**
- `wofi/` - App launcher
- `swaylock/` - Screen locker
- `imv/` - Image viewer

**Utilities**
- `bin/` - Custom scripts
- `glow/` - Markdown renderer (config + custom glamour style)
- `gitconfig/` - Git config
- `cssh/` - ClusterSSH

## Structure

Each directory uses stow's structure: `package/.config/app/` → `~/.config/app/`
