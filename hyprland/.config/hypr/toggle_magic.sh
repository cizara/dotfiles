#!/bin/bash
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')
magic_addr=$(hyprctl clients -j | jq -r '[.[] | select(.workspace.name == "special:magic")] | first | .address // empty')

if [[ -n "$magic_addr" ]]; then
    # bring the scratchpad window back to the current workspace
    hyprctl dispatch "hl.dsp.window.move({ workspace = $current_ws, follow = false, window = 'address:$magic_addr' })"
else
    # send the focused window to the scratchpad silently
    hyprctl dispatch "hl.dsp.window.move({ workspace = 'special:magic', follow = false })"
fi
