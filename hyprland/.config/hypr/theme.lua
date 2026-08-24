-- See https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 5,

        border_size = 2,

        no_focus_fallback    = true,
        resize_on_border     = false,
        hover_icon_on_border = false,
        allow_tearing        = false,

        col = {
            active_border   = "rgb(8A8A8D)",
            inactive_border = "rgba(595959aa)",
        },

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
        -- Always split right/down instead of following the cursor half, so where a
        -- new window lands depends only on the layout, not on where the mouse was.
        force_split = 2,
    },

    master = {
        new_status = "master",
    },

    misc = {
        font_family             = "JetBrains Mono",
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,

        -- Wake the displays on input. There is no idle daemon on this machine, but
        -- DPMS still gets turned off by the lock bind, and without these the screen
        -- stays black until the mouse is physically moved.
        key_press_enables_dpms  = true,
        mouse_move_enables_dpms = true,

        -- Default is 1 ping, which pops the "app is not responding" dialog at every
        -- brief stall (Zoom and Electron apps do this constantly).
        anr_missed_pings        = 3,

        focus_on_activate          = true,
        disable_scale_notification = true,
        on_focus_under_fullscreen  = 1,
    },

    cursor = {
        hide_on_key_press        = true,
        warp_on_change_workspace = 1,
    },

    -- eDP-1 runs at scale 1.333. Without this, XWayland clients render at 1x and
    -- get upscaled by the compositor, which is what makes them look blurry on the
    -- internal panel while native Wayland clients stay sharp.
    xwayland = {
        force_zero_scaling = true,
    },

    ecosystem = {
        no_update_news = true,
    },

    group = {
        drag_into_group = true,
        groupbar = {
            font_size     = 13,
            indicator_gap = 5,
            col = {
                active = "rgba(33ccffee)",
            },
        },
    },
})


-- Bezier curves
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 }    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 }    } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 }       } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 }    } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 }     } })

-- Spring curve for window open/close (more natural, physics-based feel)
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })


-- Animations — see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default"      })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })

-- Windows use spring for open/close for a more natural feel
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, spring = "easy"                        })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  spring = "easy",        style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })

hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick"        })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick"        })
