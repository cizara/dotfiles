-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
--
-- DP-1 es el puerto HDMI del laptop (DDI + LSPCon interno, por eso el kernel lo llama DP).
-- Estaba clavado a 29.97 Hz porque el monitor venia con HDMI Mode = 1.4 en el OSD, y con eso
-- publicaba un EDID de HDMI 1.4 (300 MHz, sin HDMI Forum VSDB) => 4K@30 era el techo real.
-- Con HDMI Mode = 2.0 aparece el bloque HDMI Forum (600 MHz) y con el VIC 97 = 4K@60.
--
-- Apagar/prender el panel interno es MANUAL: SUPER + CTRL + M (ver binds.lua).
-- Automatizarlo no funciono: al arrancar todavia no hay monitores enumerados
-- (hl.get_monitor devuelve nil tanto al parsear el config como en hyprland.start) y el
-- monitor.added de DP-1 pasa antes de que se registre el handler. Probado 2026-08-13.
--
-- Si cambias mode/position/scale del interno, actualizar tambien el bind en binds.lua.
hl.monitor({ output = "DP-1",  mode = "3840x2160@60",    position = "0x0",    scale = 1     })
hl.monitor({ output = "eDP-1", mode = "3200x1800@59.98", position = "3840x0", scale = 1.333 })
