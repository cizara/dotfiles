pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

// from github.com/end-4/dots-hyprland

Singleton {
    id: root
    signal brightnessChanged()

    property var ddcMonitors: []
    readonly property list<BrightnessMonitor> monitors: Quickshell.screens.map(screen => monitorComp.createObject(root, { screen }))

    function getMonitorForScreen(screen: ShellScreen): var {
        return monitors.find(m => m.screen === screen)
    }

    function increaseBrightness(): void {
        const focusedName = Hyprland.focusedMonitor.name
        const monitor = monitors.find(m => focusedName === m.screen.name)
        if (monitor)
            monitor.setBrightness(monitor.brightness + 0.05)
    }

    function decreaseBrightness(): void {
        const focusedName = Hyprland.focusedMonitor.name
        const monitor = monitors.find(m => focusedName === m.screen.name)
        if (monitor)
            monitor.setBrightness(monitor.brightness - 0.05)
    }

    reloadableId: "brightness"

    Process { id: setProc }

    component BrightnessMonitor: QtObject {
        id: monitor

        required property ShellScreen screen

        property int rawMaxBrightness: 100
        property real brightness
        property real brightnessMultiplier: 1.0
        property real multipliedBrightness: Math.max(0, Math.min(1, brightness * brightnessMultiplier))
        property bool ready: false
        property bool animateChanges: true

        onBrightnessChanged: {
            if (!monitor.ready) return
            root.brightnessChanged()
            syncBrightness()
        }

        function initialize() {
            monitor.ready = false
            initProc.command = ["sh", "-c", `echo "a b c $(brightnessctl g) $(brightnessctl m)"`]
            initProc.running = true
        }

        readonly property Process initProc: Process {
            stdout: SplitParser {
                onRead: data => {
                    const [, , , current, max] = data.split(" ")
                    monitor.rawMaxBrightness = parseInt(max)
                    monitor.brightness = parseInt(current) / monitor.rawMaxBrightness
                    monitor.ready = true
                }
            }
        }

        function syncBrightness() {
            const brightnessValue = Math.max(Math.min(monitor.multipliedBrightness, 1), 0)
            const rawValueRounded = Math.max(Math.floor(brightnessValue * monitor.rawMaxBrightness), 1)
            setProc.command = ["brightnessctl", "set", rawValueRounded.toString()]
            setProc.startDetached()
        }

        function setBrightness(value: real): void {
            value = Math.max(0, Math.min(1, value))
            monitor.brightness = value
        }

        Component.onCompleted: initialize()
    }

    Component { id: monitorComp; BrightnessMonitor {} }
}