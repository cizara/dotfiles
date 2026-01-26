import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.modules

Scope {
    id: root

    Process {
        id: btopProcess
        running: false
        command: ["ghostty", "--title=btop", "-e", "btop"]
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: topBar
            required property var modelData
            screen: modelData
            color: "transparent"
            exclusiveZone: 40

            anchors { top: true; left: true; right: true }
            implicitHeight: 40

            // LEFT
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                padding: 6

                Workspaces {
                    Layout.alignment: Qt.AlignVCenter
                    screen: topBar.screen
                }
                Cpu {
                    onActivate: () => {
                        btopProcess.running = false
                        btopProcess.running = true
                    }
                }
                Memory {}
                Disk {}
                Temperature {}
            }

            // CENTER
            Row {
                id: centerCluster
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                HyprlandWindow {}
            }

            // RIGHT
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                padding: 6

                Mediaplayer { id: media }
                SystemTray {}
                Battery {}
                DateTime {}
                Pfpanel {}
            }
        }
    }
}