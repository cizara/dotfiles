import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects

PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    color: "transparent"
    visible: true
    exclusiveZone: -1
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    focusable: false

    mask: Region { item: container; intersection: Intersection.Xor }

    anchors {
        top: true
        left: true
        bottom: true
        right: true
    }

    Item {
        id: container
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent

            gradient: Gradient {
                GradientStop { position: 0.0; color: '#181825' }   // top
                    GradientStop { position: 1.0; color: '#000000' }   // bottom
                    }

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        maskSource: mask
                        maskEnabled: true
                        maskInverted: true
                        maskThresholdMin: 0.5
                        maskSpreadAtMin: 1
                    }
                }

                Item {
                    id: mask

                    anchors.fill: parent
                    layer.enabled: true
                    visible: false

                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: 7
                        anchors.rightMargin: 7
                        anchors.topMargin: 40
                        anchors.bottomMargin: 0

                        radius: 14
                    }
                }
            }
        }