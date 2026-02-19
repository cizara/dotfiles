pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property real usedFrac: 0.0
    readonly property int percent: Math.round(usedFrac * 100)
    
    property real prevIdle: 0
    property real prevTotal: 0

    Process {
        id: cpuProc
        command: ["bash", "-c", "head -n 1 /proc/stat | awk '{print $2\" \"$3\" \"$4\" \"$5\" \"$6\" \"$7\" \"$8\" \"$9\" \"$10\" \"$11}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/)
                if (parts.length < 4) return

                // user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice
                const user = parseFloat(parts[0]) || 0
                const nice = parseFloat(parts[1]) || 0
                const system = parseFloat(parts[2]) || 0
                const idle = parseFloat(parts[3]) || 0
                const iowait = parseFloat(parts[4]) || 0
                const irq = parseFloat(parts[5]) || 0
                const softirq = parseFloat(parts[6]) || 0
                const steal = parseFloat(parts[7]) || 0

                const idleTime = idle + iowait
                const totalTime = user + nice + system + idle + iowait + irq + softirq + steal

                if (root.prevTotal > 0) {
                    const diffIdle = idleTime - root.prevIdle
                    const diffTotal = totalTime - root.prevTotal

                    if (diffTotal > 0) {
                        const usage = (diffTotal - diffIdle) / diffTotal
                        root.usedFrac = Math.max(0, Math.min(1, usage))
                    }
                }

                root.prevIdle = idleTime
                root.prevTotal = totalTime
            }
        }
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running = false
            cpuProc.running = true
        }
    }

    Component.onCompleted: {
        cpuProc.running = true
    }
}
