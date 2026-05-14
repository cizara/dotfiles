pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string connectedSsid: "No Internet"
    property int signalStrength: 0 // 0–100 %
    property bool wifiEnabled: true

    readonly property bool connected: connectedSsid !== "No Internet" && connectedSsid.length > 0

    Timer {
        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            connectedSsidProc.running = false
            connectedSsidProc.running = true
            
            wifiStateProc.running = false
            wifiStateProc.running = true
        }
    }
    
    Process {
        id: wifiStateProc
        command: ["bash", "-c", "iwctl device wlan0 show | grep 'Powered' || echo on"]
        stdout: StdioCollector {
            onStreamFinished: {
                // Output is like "Powered               on"
                const s = text.trim().toLowerCase()
                root.wifiEnabled = (s.includes("on"))
            }
        }
    }

    // Toggle function exposed to consumers
    function toggleWifi() {
        wifiToggleProc.command = ["bash", "-c", "iwctl device wlan0 set-property Powered " + (root.wifiEnabled ? "off" : "on")]
        wifiToggleProc.running = false
        wifiToggleProc.running = true
        
        // Optimistic update
        root.wifiEnabled = !root.wifiEnabled
    }
    
    Process {
        id: wifiToggleProc
        command: []
    }

    Process {
        id: connectedSsidProc
        // Using iwctl to get status.
        // We grep for 'Connected network' and 'RSSI'
        command: ["bash", "-c", "iwctl station wlan0 show | grep -E 'Connected network|RSSI' || echo ''"]

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                var ssid = "No Internet"
                var rssi = -100

                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (line.includes("Connected network")) {
                        // Extract everything after "Connected network" and spaces
                        // Expected format: "Connected network                   My SSID"
                        var parts = line.split(/\s{2,}/) // Split by 2 or more spaces
                        if (parts.length >= 2) {
                             ssid = parts[1].trim()
                        }
                    } else if (line.includes("RSSI")) {
                        // Expected format: "RSSI                                -55 dBm"
                        var parts = line.split(/\s+/)
                        // Find the number part
                        for (var j = 0; j < parts.length; j++) {
                            if (parts[j].match(/^-[0-9]+$/)) {
                                rssi = parseInt(parts[j])
                                break
                            }
                        }
                    }
                }

                root.connectedSsid = ssid
                // Convert RSSI (-100 to -50) to percentage (0 to 100)
                // -50 or better -> 100%
                // -100 or worse -> 0%
                var quality = 2 * (rssi + 100)
                if (quality > 100) quality = 100
                if (quality < 0) quality = 0
                root.signalStrength = quality
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
