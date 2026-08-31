// modules/Indicators.qml
//
// Cluster of mode indicators. Active modes are always visible; inactive ones are
// hidden until the cluster is hovered, then fade in dimmed so they can be turned
// on by clicking without knowing the hotkey.
//
// Two separate rows rather than one interleaved row on purpose: the inactive row
// sits on the outside and the active row on the inside (nearest the window title),
// so revealing the inactive ones grows the group outward instead of pushing the
// active glyphs sideways under the cursor.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import qs.services as Services

Item {
    id: root

    property bool revealed: hoverArea.containsMouse || hideDelay.running

    implicitWidth: layout.implicitWidth
    implicitHeight: Services.Theme.moduleHeight

    // Keep a hover target even when every indicator is collapsed to zero width,
    // otherwise the reveal could never be triggered from an empty cluster.
    readonly property int hoverPad: Services.Theme.spacingHuge

    // Brief grace period so travelling between two indicators does not collapse
    // the group on the way. Started/stopped from the MouseArea rather than from an
    // onRevealedChanged handler, which would feed back into its own binding.
    Timer {
        id: hideDelay
        interval: 120
    }

    // No IpcHandler here on purpose. The bar is instantiated once per monitor, so
    // this component exists twice on a two-display setup, and an IPC target only
    // ever routes to a single handler — the second registration is dropped with a
    // warning. The state it would report comes from singletons anyway, so the
    // `indicators` target lives in shell.qml, which is instantiated once.

    Row {
        id: layout
        anchors.centerIn: parent
        spacing: 0

        // --- inactive block: clipped so it grows out of nothing --------------
        Item {
            id: inactiveBlock
            anchors.verticalCenter: parent.verticalCenter
            clip: true
            width: root.revealed ? inactiveRow.implicitWidth : 0
            height: Services.Theme.moduleHeight

            Behavior on width {
                NumberAnimation {
                    duration: Services.Theme.animDurationNormal
                    easing.type: Easing.OutQuad
                }
            }

            Row {
                id: inactiveRow
                spacing: 0

                BarIndicator {
                    revealed: root.revealed
                    active: false
                    visible: !Services.Notifications.doNotDisturb
                    activeText: "󰂛"
                    inactiveText: "󰂛"
                    onTriggered: Services.Notifications.doNotDisturb = true
                }

                BarIndicator {
                    revealed: root.revealed
                    active: false
                    visible: !Services.Inhibitor.active
                    activeText: "󰅶"
                    inactiveText: "󰅶"
                    onTriggered: Services.Inhibitor.toggle()
                }
            }
        }

        // --- active block: nearest the centre, never moves -------------------
        Row {
            id: activeRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            BarIndicator {
                revealed: root.revealed
                active: Services.Notifications.doNotDisturb
                visible: active
                activeText: "󰂛"
                inactiveText: "󰂛"
                onTriggered: Services.Notifications.doNotDisturb = false
            }

            BarIndicator {
                revealed: root.revealed
                active: Services.Inhibitor.active
                visible: active
                activeText: "󰅶"
                inactiveText: "󰅶"
                onTriggered: Services.Inhibitor.toggle()
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        anchors.margins: -root.hoverPad
        hoverEnabled: true
        // NoButton so this only senses hover and never eats a click meant for an
        // indicator underneath it.
        acceptedButtons: Qt.NoButton

        onContainsMouseChanged: {
            if (containsMouse)
                hideDelay.stop();
            else
                hideDelay.restart();
        }
    }
}
