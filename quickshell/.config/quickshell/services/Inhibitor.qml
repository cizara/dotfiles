pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool active: false

    Process {
        id: inhibitorProcess
        running: root.active

        command: [
            "systemd-inhibit",
            "--what=idle:sleep",
            "--who=QuickShell",  
            "--why=Idle inhibitor enabled",
            "--mode=block",
            "cat"
        ]

        onStarted: {
            console.log("Idle inhibitor started (PID:", pid, ")")
        }

        onExited: (exitCode, exitStatus) => {
            console.log("Idle inhibitor exited:", exitCode, exitStatus)
        }
    }

    function toggle() {
        active = !active
    }
}
