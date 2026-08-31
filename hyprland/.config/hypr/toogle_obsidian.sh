#!/bin/bash
# Super+minus: move Obsidian in and out of special:obsidian.
#
# Same three states as toggle_magic.sh, and the same reason for the first one: if
# the workspace is open (Super+Ctrl+minus, or a tray/dbus activation) and we move
# its only window away, Hyprland leaves it open and empty on the monitor, eating
# every click. Close it instead.
set -uo pipefail

if [[ $(hyprctl monitors -j | jq -r '.[] | select(.focused) | .specialWorkspace.name') == "special:obsidian" ]]; then
    hyprctl dispatch "hl.dsp.workspace.toggle_special('obsidian')"
    exit 0
fi

current_id=$(hyprctl activeworkspace -j | jq -r '.id')

win=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:obsidian" and (.class | ascii_downcase | contains("obsidian"))) | .address')

if [[ -n "$win" ]]; then
    hyprctl dispatch "hl.dsp.window.move({ workspace = $current_id, follow = false, window = 'address:$win' })"
else
    win=$(hyprctl clients -j | jq -r '.[] | select(.class | ascii_downcase | contains("obsidian")) | .address' | head -n1)
    [[ -n "$win" ]] && hyprctl dispatch "hl.dsp.window.move({ workspace = 'special:obsidian', follow = false, window = 'address:$win' })"
fi
