#!/bin/bash

win=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:obsidian" and .class == "obsidian") | .address')
current=$(hyprctl activeworkspace -j | jq -r '.name')

if [ -n "$win" ]; then
    hyprctl dispatch movetoworkspace $current,address:$win
else
    current_ws=$(hyprctl activeworkspace -j | jq -r '.name')
    win=$(hyprctl clients -j | jq -r --arg class "obsidian" --arg ws "$current_ws" '.[] | select(.class == "obsidian" and .workspace.name == $ws) | .address' | head -n1)
    [ -n "$win" ] && hyprctl dispatch movetoworkspacesilent special:obsidian,address:$win
fi
