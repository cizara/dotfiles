#!/bin/bash

win=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:obsidian" and .class == "obsidian") | .address')
current=$(hyprctl activeworkspace -j | jq -r '.name')

if [ -n "$win" ]; then
    hyprctl dispatch movetoworkspace $current,address:$win
else
    win=$(hyprctl clients -j | jq -r --arg class "obsidian" '.[] | select(.class == "obsidian") | .address' | head -n1)
    [ -n "$win" ] && hyprctl dispatch movetoworkspacesilent special:obsidian,address:$win
fi
