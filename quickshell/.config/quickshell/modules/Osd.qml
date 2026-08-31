// modules/Osd.qml
//
// On-screen display for volume, brightness and one-off messages. Replaces wob.
//
// Driven entirely over IPC so anything can raise it:
//   qs ipc call osd show '{"icon":"volume-high","value":"40"}'
//   ~/bin/osd -i brightness-high -p 60
//
// Two properties make this a genuinely non-intrusive overlay:
//   mask: Region {}                        - empty input region, so clicks fall
//                                            through to the window underneath
//   keyboardFocus: WlrKeyboardFocus.None   - never steals focus from the app
//
// It renders on the focused monitor rather than a fixed one, which wob could not
// do on a two-monitor setup.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services as Services
import "OsdModel.js" as OsdModel

Scope {
    id: root

    property var state: OsdModel.normalize("{}")
    property bool opened: false

    // Show the value before opening so a fresh OSD starts at its new level;
    // only updates while it is already open animate the bar.
    function show(payloadJson) {
        const next = OsdModel.normalize(payloadJson);
        root.state = next;
        root.opened = true;
        hideTimer.interval = next.duration;
        hideTimer.restart();
    }

    function close() {
        root.opened = false;
        hideTimer.stop();
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.opened = false
    }

    IpcHandler {
        target: "osd"

        function show(payloadJson: string): string {
            root.show(payloadJson);
            return "ok";
        }

        function close(): string {
            root.close();
            return "ok";
        }

        function state(): string {
            return root.opened ? "open" : "closed";
        }
    }

    // Follow the focused monitor. Hyprland reports the focused output by name;
    // match it against Quickshell's screen list.
    readonly property var focusedScreen: {
        const name = Hyprland.focusedMonitor?.name ?? "";
        const screens = Quickshell.screens;
        for (var i = 0; i < screens.length; i++)
            if (screens[i].name === name)
                return screens[i];
        return screens.length > 0 ? screens[0] : null;
    }

    PanelWindow {
        id: panel

        screen: root.focusedScreen
        visible: root.opened

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        WlrLayershell.namespace: "quickshell-osd"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        // Visual-only surface: an empty input region means the OSD never
        // intercepts a click meant for the window beneath it.
        mask: Region {}

        // --- measurement -----------------------------------------------------
        // Nerd Font glyphs draw well outside their monospace cell, so the icon
        // column is sized by ink, not advance width. For a progress OSD it is
        // pinned to the widest glyph the icon's family can produce so the bar
        // does not shift when the level crosses an icon threshold.
        TextMetrics {
            id: iconMetrics
            font.family: Services.Theme.fontFamily
            font.pixelSize: Services.Theme.fontSizeHuge
            text: root.state.glyph
        }

        readonly property int widestFamilyInk: {
            var widest = 0;
            const glyphs = root.state.familyGlyphs;
            for (var i = 0; i < glyphs.length; i++) {
                familyProbe.text = glyphs[i];
                const w = Math.ceil(familyProbe.tightBoundingRect.width);
                if (w > widest)
                    widest = w;
            }
            return widest;
        }

        TextMetrics {
            id: familyProbe
            font.family: Services.Theme.fontFamily
            font.pixelSize: Services.Theme.fontSizeHuge
        }

        // Pin the readout to the width of "100%" so digits do not jitter as the
        // value moves between 9% and 100%.
        TextMetrics {
            id: valueMetrics
            font.family: Services.Theme.fontFamily
            font.pixelSize: Services.Theme.fontSizeMedium
            text: "100%"
        }

        Rectangle {
            id: card

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Math.round(parent.height * 0.12)

            color: Services.Theme.colorBase
            // Tracks Hyprland's decoration:rounding, so the OSD is shaped like the
            // windows it floats over.
            radius: Services.Theme.cornerRadius
            border.color: Services.Theme.colorCardBorder
            border.width: 2

            implicitWidth: contentRow.implicitWidth + Services.Theme.paddingContent * 2
            implicitHeight: Math.max(contentRow.implicitHeight + Services.Theme.paddingMedium * 2,
                                     Services.Theme.moduleHeight + Services.Theme.paddingMedium)

            opacity: root.opened ? Services.Theme.opacityNormal : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Services.Theme.animDurationNormal
                    easing.type: Easing.InOutQuad
                }
            }

            Row {
                id: contentRow
                anchors.centerIn: parent
                spacing: Services.Theme.spacingLarge

                Text {
                    id: iconText
                    anchors.verticalCenter: parent.verticalCenter
                    width: root.state.hasProgress
                        ? Math.max(card.widestFamilyInk, Math.ceil(iconMetrics.tightBoundingRect.width))
                        : Math.ceil(iconMetrics.tightBoundingRect.width)
                    horizontalAlignment: Text.AlignHCenter
                    visible: root.state.glyph !== ""
                    text: root.state.glyph
                    color: Services.Theme.colorText
                    font.family: Services.Theme.fontFamily
                    font.pixelSize: Services.Theme.fontSizeHuge
                    renderType: Text.NativeRendering
                }

                Rectangle {
                    id: track
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.state.hasProgress
                    width: visible ? 220 : 0
                    height: 6
                    radius: 3
                    color: Qt.rgba(Services.Theme.colorRingBg.r,
                                   Services.Theme.colorRingBg.g,
                                   Services.Theme.colorRingBg.b,
                                   Services.Theme.opacityRingBg)

                    Rectangle {
                        height: parent.height
                        radius: parent.radius
                        color: Services.Theme.colorAccent
                        width: parent.width * Math.max(0, Math.min(1, root.state.value / root.state.max))

                        Behavior on width {
                            NumberAnimation {
                                duration: Services.Theme.animDurationFast
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.state.hasProgress
                    width: visible ? Math.ceil(valueMetrics.advanceWidth) : 0
                    horizontalAlignment: Text.AlignRight
                    text: root.state.progressText
                    color: Services.Theme.colorSubtext1
                    font.family: Services.Theme.fontFamily
                    font.pixelSize: Services.Theme.fontSizeMedium
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.state.message !== ""
                    text: root.state.message
                    color: Services.Theme.colorText
                    font.family: Services.Theme.fontFamily
                    font.pixelSize: Services.Theme.fontSizeMedium
                }
            }
        }
    }
}
