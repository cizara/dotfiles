pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property real usedFrac: 0.0
    property real usedGiB: 0.0
    property real totalGiB: 0.0
    readonly property int percent: Math.round(usedFrac * 100)

    Process {
        id: memProc
        command: ["bash", "-c", "awk '/MemTotal:/ {t=$2} /MemAvailable:/ {a=$2} END{print t\" \"a}' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/)
                if (parts.length < 2) return

                const totalKB = parseFloat(parts[0])
                const availKB = parseFloat(parts[1])
                if (isNaN(totalKB) || isNaN(availKB) || totalKB <= 0) return

                const usedKB = Math.max(0, totalKB - availKB)
                root.totalGiB = totalKB / (1024 * 1024)
                root.usedGiB = usedKB / (1024 * 1024)
                root.usedFrac = Math.max(0, Math.min(1, usedKB / totalKB))
            }
        }
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            memProc.running = false
            memProc.running = true
        }
    }
}
