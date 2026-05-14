import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.services

Item {
    id: root
    required property var screen
    property int maxWorkspaces: 10

    // Sizes 
    property int sizeSmall: 12
    property int sizeMedium: 16
    property int sizeLarge: 32  // focused pill width

    readonly property var occupiedMap: Hyprland.workspaces.values.reduce(
        (acc, ws) => {
            const winCount = (ws.lastIpcObject && ws.lastIpcObject.windows) || 0
            acc[ws.id] = winCount > 0
            return acc
        },
        {}
    )

    readonly property var monitorMap: Hyprland.workspaces.values.reduce(
        (acc, ws) => {
            const monitorName = (ws.lastIpcObject && ws.lastIpcObject.monitor) || ""
            acc[ws.id] = monitorName
            return acc
        },
        {}
    )

    implicitWidth: bg.implicitWidth
    implicitHeight: bg.implicitHeight

    Rectangle {
        id: bg
        color: "#313244"
        radius: height / 2
        anchors.centerIn: parent

        implicitWidth: row.implicitWidth + 16
        implicitHeight: row.implicitHeight + 16

        Row {
            id: row
            spacing: 5
            anchors.centerIn: parent

            Repeater {
                model: root.maxWorkspaces

                Rectangle {
                    id: wsBox
                    property int wid: index + 1

                    property bool isFocused:
                        Hyprland.focusedWorkspace
                        && Hyprland.focusedWorkspace.id === wid

                    property bool isOccupied: occupiedMap[wid] === true
                    property bool isOnThisMonitor: monitorMap[wid] === root.screen.name
                    property bool isVisible: isOnThisMonitor && (isOccupied || isFocused)

                    visible: isVisible

                    // size logic
                    property int prefHeight: 12
                    property int prefWidth:
                        isFocused ? root.sizeLarge
                        : isOccupied ? root.sizeMedium
                        : root.sizeSmall

                    width: prefWidth
                    height: prefHeight
                    radius: prefHeight / 2

                    Behavior on width {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutCubic
                        }
                    }

                    // colors based on state
                    property color workspaceStateColor: {
                        if (isFocused)
                            return "#b4befe"
                        if (isOccupied)
                            return "#e8e8e8ff"
                        return "#7a7a7a"
                    }

                    color: workspaceStateColor

                    border.width: isOccupied ? 1 : 1
                    border.color: isFocused ? "#b4befe" : "#a2a2a2"

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    property bool hovered: false

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: "#b4befe"
                        opacity: wsBox.hovered ? 0.18 : 0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }

                    // Workspace ID text (shown when focused)
                    Text {
                        anchors.centerIn: parent
                        text: wsBox.wid
                        color: wsBox.isFocused ? "#1e1e2e" : "transparent"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        visible: wsBox.isFocused
                    }

                    SequentialAnimation {
                        id: bounceAnim
                        running: false
                        loops: 1

                        NumberAnimation { target: wsBox; property: "scale"; to: 1.20; duration: 120; easing.type: Easing.OutQuad }
                        NumberAnimation { target: wsBox; property: "scale"; to: 0.92; duration: 120; easing.type: Easing.InOutQuad }
                        NumberAnimation { target: wsBox; property: "scale"; to: 1.0; duration: 130; easing.type: Easing.OutBounce }
                    }

                    Connections {
                        target: Hyprland
                        function onFocusedWorkspaceChanged() {
                            if (wsBox.isFocused) {
                                wsBox.scale = 1
                                bounceAnim.start()
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered: wsBox.hovered = true
                        onExited: wsBox.hovered = false
                        onClicked: {
                            if (!wsBox.isFocused) {
                                Hyprland.dispatch("workspace " + wsBox.wid)
                            }
                        }
                    }
                }
            }
        }
    }
}