-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local mainMod      = "SUPER"
local mainModShift = mainMod .. " + SHIFT"
local mainModCtrl  = mainMod .. " + CTRL"
local mainModAlt   = mainMod .. " + ALT"


-- Core window actions
hl.bind(mainMod      .. " + Return",    hl.dsp.exec_cmd(terminal))
hl.bind(mainModShift .. " + H",         hl.dsp.exec_cmd(home .. "/bin/herdr-foot"))
hl.bind(mainModShift .. " + Q",         hl.dsp.window.close())
hl.bind(mainModShift .. " + E",         hl.dsp.exec_cmd("uwsm stop"))
hl.bind(mainMod      .. " + E",         hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod      .. " + V",         hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod      .. " + D",         hl.dsp.exec_cmd(menu))
hl.bind(mainMod      .. " + K",         hl.dsp.window.pseudo())
hl.bind(mainMod      .. " + J",         hl.dsp.layout("togglesplit"))
hl.bind(mainMod      .. " + L",         hl.dsp.exec_cmd("swaylock -f -c 000000"))
-- suspend-then-hibernate, not plain suspend: S3 first (instant resume), then writes the
-- image to /swapfile and powers off after HibernateDelaySec (90min, /etc/systemd/sleep.conf).
-- Plain "systemctl suspend" can never fall through to hibernate, and with no idle daemon
-- and the lid never closed, this bind is the only sleep trigger on the machine.
hl.bind(mainModCtrl  .. " + L",         hl.dsp.exec_cmd("swaylock -c 000000 -f && systemctl suspend-then-hibernate"))
hl.bind(mainModShift .. " + space",     hl.dsp.window.float({ action = "toggle" }))
-- Toggle the internal panel. Only turns it OFF when an external monitor is present, so it
-- can never leave the machine with no display. If the internal is already off it always
-- turns it back on, which also makes this the recovery path. Mode/position/scale must match
-- monitors.lua. (SUPER+SHIFT+E is "uwsm stop" — do not put this on SHIFT.)
hl.bind(mainModCtrl  .. " + M",         function()
    local function notify(args)
        hl.exec_cmd("notify-send -a hyprland " .. args)
    end
    -- NUNCA llamar a hyprctl desde aca. Un bind de Lua corre *dentro* del
    -- compositor, y hyprctl necesita hablar con el compositor por su socket, que
    -- esta bloqueado justo ejecutando este codigo. El resultado es
    -- "Hyprland IPC didn't respond in time / Couldn't read (6)" y jq recibe basura.
    -- Solo se puede: la API nativa hl.*, y comandos que no toquen el compositor
    -- (leer /sys esta bien).
    --
    -- Devuelve: hay_externo_activo, hay_cable_conectado
    local function external_state()
        -- external-monitors -v lista los conectores no-internos conectados leyendo
        -- /sys (card1-DP-1, etc). Le preguntamos a Hyprland cual de esos tiene
        -- realmente encendido: que haya cable no alcanza, una salida conectada pero
        -- deshabilitada dejaria la pantalla en negro igual.
        local pipe = io.popen(home .. "/bin/external-monitors -v 2>/dev/null")
        if not pipe then return false, false end
        local connectors = {}
        for line in pipe:lines() do
            local name = line:match("^card%d+%-(.+)$") or line
            if name ~= "" then table.insert(connectors, name) end
        end
        pipe:close()

        for _, name in ipairs(connectors) do
            if hl.get_monitor(name) then
                return true, true
            end
        end
        return false, #connectors > 0
    end
    if hl.get_monitor("eDP-1") then
        local active_external, cable_connected = external_state()
        if active_external then
            hl.monitor({ output = "eDP-1", disabled = true })
            notify("'Panel interno apagado' 'SUPER+CTRL+M para prenderlo'")
        elseif cable_connected then
            notify("-u critical 'No apago el interno' 'Hay cable conectado pero la salida esta deshabilitada'")
        else
            notify("-u critical 'No apago el interno' 'Es la unica pantalla conectada'")
        end
    else
        -- disabled = false explicito: sin eso la regla de eDP-1 se queda con el disabled
        -- del toggle anterior y el monitor no vuelve. En un "hyprctl reload" no hace falta
        -- porque las reglas se reconstruyen de cero, pero en runtime se mergean.
        hl.monitor({ output = "eDP-1", disabled = false, mode = "3200x1800@59.98", position = "3840x0", scale = 1.333 })
        notify("'Panel interno prendido'")
    end
end)
-- Reroll the wallpaper. Talks to quickshell over IPC; -q so a press during a
-- shell restart is a no-op instead of an error.
hl.bind(mainModShift .. " + W",         hl.dsp.exec_cmd(home .. "/bin/qs-ipc -q wallpaper next"))

-- Group (tabbed) window management
hl.bind(mainMod      .. " + G",   hl.dsp.group.toggle())
hl.bind(mainModShift .. " + G",   hl.dsp.window.move({ out_of_group = true }))
hl.bind(mainMod      .. " + tab", hl.dsp.group.next())
hl.bind(mainModShift .. " + tab", hl.dsp.group.prev())

-- Window swallowing
hl.bind(mainMod .. " + X", hl.dsp.window.toggle_swallow())


-- Focus (also changes group active for arrow keys)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down"  }))
hl.bind(mainMod .. " + left",  hl.dsp.group.prev())
hl.bind(mainMod .. " + right", hl.dsp.group.next())

-- Move focused window
hl.bind(mainModShift .. " + left",  hl.dsp.window.move({ direction = "left"  }))
hl.bind(mainModShift .. " + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainModShift .. " + up",    hl.dsp.window.move({ direction = "up"    }))
hl.bind(mainModShift .. " + down",  hl.dsp.window.move({ direction = "down"  }))

-- Move focused window into group
hl.bind(mainModAlt .. " + left",  hl.dsp.window.move({ into_group = "left"  }))
hl.bind(mainModAlt .. " + right", hl.dsp.window.move({ into_group = "right" }))
hl.bind(mainModAlt .. " + up",    hl.dsp.window.move({ into_group = "up"    }))
hl.bind(mainModAlt .. " + down",  hl.dsp.window.move({ into_group = "down"  }))


-- Workspaces: switch and move window
for i = 1, 10 do
    local key = i % 10  -- 10 maps to key 0
    hl.bind(mainMod      .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainModShift .. " + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Move current workspace to monitor
hl.bind(mainModCtrl .. " + left",  hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(mainModCtrl .. " + right", hl.dsp.workspace.move({ monitor = "r" }))

-- Special (scratchpad) workspaces
-- Super+S: toggle focused window between current workspace and special:magic
-- (script checks window's current workspace and moves accordingly)
hl.bind(mainMod      .. " + S", hl.dsp.exec_cmd(home .. "/.config/hypr/toggle_magic.sh"))
hl.bind(mainModShift .. " + S", hl.dsp.window.move({ workspace = "special:magic", follow = false }))
-- Show/hide special:magic as an overlay, mirroring Super+Ctrl+minus for obsidian.
-- Also the escape hatch: a special workspace left open and empty covers the monitor
-- and eats every click on every workspace, and this is the only way to close it.
hl.bind(mainModCtrl  .. " + S", hl.dsp.workspace.toggle_special("magic"))

-- Obsidian scratchpad
hl.bind(mainModCtrl  .. " + minus", hl.dsp.workspace.toggle_special("obsidian"))
hl.bind(mainMod      .. " + minus", hl.dsp.exec_cmd(home .. "/.config/hypr/toogle_obsidian.sh"))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })


-- Volume and brightness. Feedback goes to the quickshell OSD (modules/Osd.qml)
-- instead of wob, so there is no FIFO to set up at startup and the popup appears
-- on the focused monitor. The scripts also fix the old "mic mute" bind, which was
-- a copy of the output-mute command and so muted the speakers, not the mic.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(home .. "/bin/volume up"),       { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(home .. "/bin/volume down"),     { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(home .. "/bin/volume mute"),     { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(home .. "/bin/volume mic-mute"), { locked = true })

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(home .. "/bin/brightness up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(home .. "/bin/brightness down"), { locked = true, repeating = true })

-- Media controls
local players = "spotify,YoutubeMusic,chromium.instance2"
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl -p '" .. players .. "' next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl -p '" .. players .. "' pause"),       { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl -p '" .. players .. "' play"),        { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl -p '" .. players .. "' previous"),    { locked = true })
hl.bind(mainMod .. " + P",hl.dsp.exec_cmd("playerctl -p '" .. players .. "' play-pause"))

-- Screenshots
hl.bind(mainMod      .. " + Print", hl.dsp.exec_cmd('grim -t jpeg -o "$(hyprctl monitors -j | jq -r \'.[] | select(.focused) | .name\')" ' .. home .. '/Pictures/Screenshots/$(date +\'%Y-%m-%d_%H-%M-%S.jpg\')'))
hl.bind(mainMod      .. " + O",     hl.dsp.exec_cmd('grim -t jpeg -g "$(/usr/bin/slurp)" ' .. home .. '/Pictures/Screenshots/$(date +\'%Y-%m-%d_%H-%M-%S.jpg\')'))
hl.bind(mainModShift .. " + I",     hl.dsp.exec_cmd("XDG_CURRENT_DESKTOP=sway flameshot gui"))
