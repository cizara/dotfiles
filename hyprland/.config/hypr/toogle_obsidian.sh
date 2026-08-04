#!/bin/bash
current_id=$(hyprctl activeworkspace -j | jq -r '.id')

win=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:obsidian" and (.class | ascii_downcase | contains("obsidian"))) | .address')

if [[ -n "$win" ]]; then
    hyprctl dispatch "hl.dsp.window.move({ workspace = $current_id, follow = false, window = 'address:$win' })"
else
    win=$(hyprctl clients -j | jq -r '.[] | select(.class | ascii_downcase | contains("obsidian")) | .address' | head -n1)
    [[ -n "$win" ]] && hyprctl dispatch "hl.dsp.window.move({ workspace = 'special:obsidian', follow = false, window = 'address:$win' })"
fi
