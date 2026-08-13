-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Rules stored as locals can be toggled with :set_enabled(false) for debugging
local suppressMaximize = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})
-- suppressMaximize:set_enabled(false)

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})


-- Floating windows
hl.window_rule({
    name  = "obsidian-float",
    match = { class = "^(md\\.obsidian\\.Obsidian)$" },
    float = true,
    size  = "1200 1500",
})

hl.window_rule({
    name  = "btop-float",
    match = { title = "^(btop)$" },
    float = true,
    size  = "1300 850",
    move  = "40 70",
})

hl.window_rule({
    name  = "misc-float",
    match = { class = "^(Cssh|galculator|zoom)$" },
    float = true,
})

hl.window_rule({
    name  = "pavucontrol-float",
    match = { class = "^(org.pulseaudio.pavucontrol)$" },
    float = true,
    size  = "1600 1000",
    move  = "40 70",
})

hl.window_rule({
    name  = "file-dialog-float",
    match = { title = "^(Open|Save) (File|Folder|As|file|folder|as).*$" },
    float = true,
    size  = "1400 1000",
})

hl.window_rule({
    name  = "file-dialog-float-2",
    match = { title = ".* wants to (open|save)$" },
    float = true,
})

hl.window_rule({
    name  = "screen-share-float",
    match = { title = ".* is sharing your screen%.$" },
    float = true,
})

hl.window_rule({
    name  = "google-signin-float",
    match = { title = "^Sign in - Google Accounts.*" },
    float = true,
})

hl.window_rule({
    name    = "launcher-style",
    match   = { class = "^(launcher)$" },
    border_size = 0,
    opacity = 0.8,
})

hl.window_rule({
    name  = "mousepad-float",
    match = { class = "^(org.xfce.mousepad)$" },
    float = true,
    size  = "1300 1000",
})


-- Idle inhibit
hl.window_rule({
    name         = "firefox-meet-idle",
    match        = { class = "^(Firefox)$", title = "^(Meet - .*-.*-.*)$" },
    idle_inhibit = "focus",
})


-- Zoom
hl.window_rule({
    name  = "zoom-audio-float",
    match = { class = "^(zoom)$", title = "^(Choose ONE of the audio conference options|zoom)$" },
    float = true,
})

hl.window_rule({
    name = "zoom-meeting-tile",
    match = { class = "^(zoom)$", title = "^(Zoom Meeting|Zoom - Free Account)$" },
    tile  = true,
})

hl.window_rule({
    name         = "zoom-inhibit-idle",
    match        = { class = "^(zoom)$" },
    idle_inhibit = "fullscreen",
})


-- Layer rules (uncomment to use, e.g. to add blur to wofi or waybar)
-- hl.layer_rule({ name = "wofi-blur",   match = { namespace = "^wofi$"   }, blur = true })
-- hl.layer_rule({ name = "waybar-blur", match = { namespace = "^waybar$" }, blur = true })
