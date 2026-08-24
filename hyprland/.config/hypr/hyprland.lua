-- Hyprland Lua configuration entry point
-- See https://wiki.hypr.land/Configuring/Start/

-- You can split this config into multiple files and require them:
-- require("myModule")

home    = os.getenv("HOME")
local xdg_run = os.getenv("XDG_RUNTIME_DIR")

terminal    = "ghostty"
fileManager = "thunar"
menu        = "wofi -c " .. home .. "/.config/wofi/config -s " .. home .. "/.config/wofi/style.css"


-----------------------------
---- ENVIRONMENT VARIABLES --
-----------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XCURSOR_SIZE",    "24")
hl.env("HYPRCURSOR_SIZE", "24")


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- gsettings set org.gnome.desktop.interface gtk-enable-primary-paste true")
    -- wob is gone: volume/brightness feedback is drawn by the quickshell OSD, so
    -- there is no FIFO to create and no tail -f to keep running.
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Note: permission changes require a Hyprland restart to apply
hl.permission("/usr/(bin|local/bin)/grim",                            "screencopy", "allow")
hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")


--------------------
---- GESTURES ------
--------------------

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })


----------------
---- DEBUG -----
----------------

hl.config({ debug = { disable_logs = false } })


---------------------
---- LOAD MODULES ---
---------------------

require("monitors")
require("keyboard")
require("theme")
require("binds")
require("windows")
