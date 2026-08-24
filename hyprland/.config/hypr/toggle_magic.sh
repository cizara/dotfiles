#!/bin/bash
# Super+S: scratchpad toggle for special:magic. Three states, checked in this order:
#
#   1. special:magic is open on this monitor -> just close it. This is the "hide"
#      case when the window was revealed by opening the workspace instead of by
#      moving it out: clicking a tray icon activates the window, and activating a
#      window that lives in a special workspace opens that workspace.
#   2. special:magic holds a window          -> bring it back to this workspace
#   3. special:magic is empty                -> send the focused window there
#
# Case 1 is the whole reason this script is not just the two moves. Moving the last
# window out of an *open* special workspace does not close it:
# misc:close_special_on_empty only fires when a window is closed, never when it is
# moved away. What is left is a special workspace that is open and empty, which
# covers the monitor and swallows every click on every workspace, with no bind to
# get out of it (that is what Super+Ctrl+S is for now).
set -uo pipefail

# Only the focused monitor: toggle_special acts on it, so closing a special that is
# open elsewhere would move it here instead of closing it.
if [[ $(hyprctl monitors -j | jq -r '.[] | select(.focused) | .specialWorkspace.name') == "special:magic" ]]; then
    hyprctl dispatch "hl.dsp.workspace.toggle_special('magic')"
    exit 0
fi

current_ws=$(hyprctl activeworkspace -j | jq -r '.id')
magic_addr=$(hyprctl clients -j | jq -r '[.[] | select(.workspace.name == "special:magic")] | first | .address // empty')

if [[ -n "$magic_addr" ]]; then
    # bring the scratchpad window back to the current workspace
    hyprctl dispatch "hl.dsp.window.move({ workspace = $current_ws, follow = false, window = 'address:$magic_addr' })"
else
    # send the focused window to the scratchpad silently
    hyprctl dispatch "hl.dsp.window.move({ workspace = 'special:magic', follow = false })"
fi
