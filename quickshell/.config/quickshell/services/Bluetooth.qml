pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool powered: false
    property bool connected: false
    property string deviceName: ""   // connected device name (first one), or ""

    function refresh() {
        poweredProc.running = false
        poweredProc.running = true

        connectedDevProc.running = false
        connectedDevProc.running = true
    }

    Timer {
        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // Powered: yes/no
    Process {
        id: poweredProc
        // use busctl + jq for reliability (bluetoothctl show output can be empty/flaky)
        command: ["bash", "-lc", "busctl call org.bluez / org.freedesktop.DBus.ObjectManager GetManagedObjects --json=pretty | jq -r '.data[0] | to_entries[] | select(.key | test(\"/org/bluez/hci[0-9]+$\")) | .value[\"org.bluez.Adapter1\"].Powered.data'"]

        stdout: StdioCollector {
            onStreamFinished: {
                var v = text.trim()
                // v should be "true" or "false"
                root.powered = (v === "true")
                if (!root.powered) {
                    root.connected = false
                    root.deviceName = ""
                }
            }
        }
    }

    // First connected device name
    Process {
        id: connectedDevProc
        // use busctl + jq to find first connected device
        command: ["bash", "-lc", "busctl call org.bluez / org.freedesktop.DBus.ObjectManager GetManagedObjects --json=pretty | jq -r '.data[0] | to_entries[] | select(.key | test(\"/org/bluez/hci[0-9]+/dev_\")) | select(.value[\"org.bluez.Device1\"].Connected.data == true) | .value[\"org.bluez.Device1\"].Name.data' | head -n1"]

        stdout: StdioCollector {
            onStreamFinished: {
                var name = text.trim()

                if (!root.powered) {
                    root.connected = false
                    root.deviceName = ""
                    return
                }

                if (name.length > 0) {
                    root.deviceName = name
                    root.connected = true
                } else {
                    root.connected = false
                    root.deviceName = ""
                }
            }
        }
    }
}
