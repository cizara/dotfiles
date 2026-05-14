pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property real usedFrac: 0.0
    property real usedGiB: 0.0
    property real totalGiB: 0.0
    property real availGiB: 0.0
    readonly property int percent: Math.round(usedFrac * 100)

    // You can change this to monitor a different mount point
    property string mountPoint: "/"

    Process {
        id: diskProc
        command: ["bash", "-c", "df -B1 " + root.mountPoint + " | awk 'NR==2 {print $2\" \"$3\" \"$4}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/)
                if (parts.length < 3) return

                const totalBytes = parseFloat(parts[0])
                const usedBytes = parseFloat(parts[1])
                const availBytes = parseFloat(parts[2])
                
                if (isNaN(totalBytes) || isNaN(usedBytes) || totalBytes <= 0) return

                root.totalGiB = totalBytes / (1024 * 1024 * 1024)
                root.usedGiB = usedBytes / (1024 * 1024 * 1024)
                root.availGiB = availBytes / (1024 * 1024 * 1024)
                root.usedFrac = Math.max(0, Math.min(1, usedBytes / totalBytes))
            }
        }
    }

    Timer {
        interval: 5000  // Update every 5 seconds (disk usage changes slowly)
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            diskProc.running = false
            diskProc.running = true
        }
    }
}
