// modules/PowerActions.qml
//
// Session actions for the control panel header, using the Lucide SVGs that were
// already sitting unused in assets/power_icons/.
//
// The destructive three (log out / reboot / shut down) need two clicks: the first
// arms the button and it highlights, the second within a few seconds runs it. That
// is deliberately not a modal dialog — a modal would need its own keyboard focus
// handling, and this panel is pointer-driven.
//
// Suspend runs exactly the command the SUPER+CTRL+L bind runs, comment and all:
// suspend-then-hibernate, so S3 comes first for an instant resume and the machine
// only writes the hibernate image after HibernateDelaySec. Plain `systemctl
// suspend` can never fall through to hibernate, so it must not be used here.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import qs.services as Services

Row {
    id: root

    spacing: Services.Theme.spacingSmall

    // Index in `actions` currently awaiting a second click, or -1.
    property int arming: -1

    readonly property var actions: [
        {
            icon: "lock.svg",
            label: "Lock",
            confirm: false,
            cmd: ["swaylock", "-f", "-c", "000000"]
        },
        {
            icon: "moon.svg",
            label: "Suspend",
            confirm: false,
            cmd: ["bash", "-c", "swaylock -c 000000 -f && systemctl suspend-then-hibernate"]
        },
        {
            icon: "log-out.svg",
            label: "Log out",
            confirm: true,
            cmd: ["uwsm", "stop"]
        },
        {
            icon: "refresh-cw.svg",
            label: "Reboot",
            confirm: true,
            cmd: ["systemctl", "reboot"]
        },
        {
            icon: "power.svg",
            label: "Shut down",
            confirm: true,
            cmd: ["systemctl", "poweroff"]
        }
    ]

    Timer {
        id: armTimer
        interval: 3000
        onTriggered: root.arming = -1
    }

    Process {
        id: runner
    }

    function invoke(index) {
        const action = root.actions[index];
        if (action.confirm && root.arming !== index) {
            root.arming = index;
            armTimer.restart();
            return;
        }
        root.arming = -1;
        armTimer.stop();
        runner.command = action.cmd;
        // Detached: these outlive the shell (and in the logout case, kill it), so
        // they must not be children of the quickshell process.
        runner.startDetached();
    }

    Repeater {
        model: root.actions

        delegate: Rectangle {
            id: button

            required property int index
            required property var modelData

            readonly property bool arming: root.arming === button.index

            width: Services.Theme.moduleHeight
            height: Services.Theme.moduleHeight
            radius: Services.Theme.cornerRadius
            antialiasing: true

            color: button.arming
                ? Services.Theme.colorRed
                : (mouse.containsMouse ? Services.Theme.colorButtonHover : "transparent")

            Behavior on color {
                ColorAnimation {
                    duration: Services.Theme.animDurationFast
                }
            }

            scale: mouse.pressed ? Services.Theme.scalePress : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: Services.Theme.animDurationNormal
                    easing.type: Easing.OutCubic
                }
            }

            Image {
                anchors.centerIn: parent
                source: Qt.resolvedUrl("../assets/power_icons/" + button.modelData.icon)
                // Render the SVG at device resolution rather than scaling a 24px
                // raster up; these are 24px documents.
                sourceSize.width: Services.Theme.iconSizeLarge
                sourceSize.height: Services.Theme.iconSizeLarge
                width: Services.Theme.iconSizeLarge
                height: Services.Theme.iconSizeLarge
                smooth: true
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.invoke(button.index)
            }

            // Label doubles as the confirm prompt, so an armed button says what a
            // second click will do rather than relying on colour alone.
            Text {
                anchors.bottom: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                visible: mouse.containsMouse || button.arming
                text: button.arming ? ("Confirm " + button.modelData.label.toLowerCase()) : button.modelData.label
                color: button.arming ? Services.Theme.colorRed : Services.Theme.colorSubtext1
                font.family: Services.Theme.fontFamily
                font.pixelSize: Services.Theme.fontSizeSmall
            }
        }
    }
}
