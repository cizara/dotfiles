pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property real tempC: 0.0
    property real maxTempC: 100.0
    property real usedFrac: 0.0
    readonly property int tempRounded: Math.round(tempC)

    Process {
        id: tempProc
        command: ["bash", "-c",
            // 1) Try hwmon Package id 0
            "for h in /sys/class/hwmon/hwmon*; do " +
            "  for l in \"$h\"/temp*_label; do " +
            "    [ -r \"$l\" ] || continue; " +
            "    if grep -qi 'package id 0' \"$l\"; then " +
            "      v=$(cat \"${l%_label}_input\" 2>/dev/null); " +
            "      [ -n \"$v\" ] || continue; " +
            "      echo $((v > 1000 ? v/1000 : v)); exit 0; " +
            "    fi; " +
            "  done; " +
            "done; " +

            // 2) Fallback: thermal_zone x86_pkg_temp
            "for z in /sys/class/thermal/thermal_zone*; do " +
            "  [ \"$(cat \"$z/type\" 2>/dev/null)\" = \"x86_pkg_temp\" ] || continue; " +
            "  v=$(cat \"$z/temp\" 2>/dev/null); " +
            "  [ -n \"$v\" ] || continue; " +
            "  echo $((v > 1000 ? v/1000 : v)); exit 0; " +
            "done; " +

            // 3) Last resort: max temperature
            "best=0; " +
            "for f in /sys/class/thermal/thermal_zone*/temp; do " +
            "  [ -r \"$f\" ] || continue; " +
            "  v=$(cat \"$f\" 2>/dev/null); " +
            "  [ -n \"$v\" ] || continue; " +
            "  [ \"$v\" -gt 1000 ] && v=$((v/1000)); " +
            "  [ \"$v\" -gt \"$best\" ] && best=$v; " +
            "done; " +
            "echo \"$best\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = parseFloat(text.trim())
                if (isNaN(t) || t <= 0) return

                root.tempC = t
                const frac = (root.maxTempC > 0) ? (t / root.maxTempC) : 0
                root.usedFrac = Math.max(0, Math.min(1, frac))
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            tempProc.running = false
            tempProc.running = true
        }
    }
}
