import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Item {
    id: monitor

    property int batteryPercent: 100
    property string batteryStatus: "Unknown"

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            readerPercent.running = true
            readerStatus.running = true
        }
    }

    Process {
        id: readerPercent
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT0/capacity"]

        stdout: StdioCollector {
            onStreamFinished: {
                let pct = parseInt(this.text.trim())
                if (!isNaN(pct)) monitor.batteryPercent = pct
            }
        }
    }

    Process {
        id: readerStatus
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT0/status"]

        stdout: StdioCollector {
            onStreamFinished: monitor.batteryStatus = this.text.trim()
        }
    }
}
