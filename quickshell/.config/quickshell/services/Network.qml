pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string connectedSsid: "No Internet"
    property int signalStrength: 0 // 0–100 %

    readonly property bool connected: connectedSsid !== "No Internet" && connectedSsid.length > 0

    Timer {
        interval: 3000
        repeat: true
        running: true
        onTriggered: {
            connectedSsidProc.running = false
            connectedSsidProc.running = true
        }
    }

    Process {
        id: connectedSsidProc
        command: ["bash", "-c", "nmcli -t -f active,ssid,signal dev wifi | grep '^yes:' || true"]

        stdout: StdioCollector {
            onStreamFinished: {
                var output = text.trim()
                if (output.length > 0) {
                    var parts = output.split(":")
                    if (parts.length >= 3) {
                        var ssid = parts[1]
                        var strength = parseInt(parts[2])
                        root.connectedSsid = ssid || "No Internet"
                        root.signalStrength = isNaN(strength) ? 0 : strength
                    }
                }
                // Only reset to "No Internet" if explicitly disconnected
                // Don't reset on empty output to avoid flickering
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                // On actual error, check if we should disconnect
                if (text.trim().length > 0) {
                    root.connectedSsid = "No Internet"
                    root.signalStrength = 0
                }
            }
        }
    }
}
