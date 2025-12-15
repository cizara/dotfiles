import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland
import qs.modules.datetimepanel

PanelWindow {
    id: panel
    visible: false
    color: "transparent"
    exclusiveZone: 0
    focusable: true
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    property bool remindersExpanded: false
    property bool weatherExpanded: false

    property bool mouseInside: false
    property bool userDismissed: false

    onVisibleChanged: {
        if (visible) {
            remindersExpanded = false
            weatherExpanded = false
            mouseInside = false
            userDismissed = false
            focusTimer.start()
        } else {
            focusTimer.stop()
        }
    }

    onRemindersExpandedChanged: if (remindersExpanded) weatherExpanded = false
    onWeatherExpandedChanged: if (weatherExpanded) remindersExpanded = false

    // Timer to check if mouse has left and been outside for a moment
    Timer {
        id: focusTimer
        interval: 1000
        repeat: true
        
        property int ticksOutside: 0
        
        onTriggered: {
            if (!panel.mouseInside) {
                ticksOutside++
                // Only close after mouse has been outside for 3 ticks (3 seconds total)
                if (ticksOutside >= 3 && panel.visible) {
                    panel.visible = false
                }
            } else {
                ticksOutside = 0
            }
        }
    }

    // --- shadow ---
    property int shadowPad: 10
    property real shadowOpacity: 0.28
    property real shadowBlur: 0.55
    property int shadowOffsetY: 6

    // size
    property int contentW: 600
    property int contentH: 300
    implicitWidth: contentW + shadowPad * 2
    implicitHeight: contentH + shadowPad * 2

    anchors { top: true; left: true }
    margins { top: 6 - shadowPad; left: 6 - shadowPad }

    Item {
        id: wrap
        anchors.fill: parent
        anchors.margins: panel.shadowPad

        Rectangle {
            anchors.fill: parent
            radius: 14
            antialiasing: true
            color: "#181825"

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowOpacity: panel.shadowOpacity
                shadowVerticalOffset: panel.shadowOffsetY
                shadowBlur: panel.shadowBlur
            }
        }

        Rectangle {
            id: clipCard
            anchors.fill: parent
            radius: 14
            color: "transparent"
            clip: true
            antialiasing: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // ========================= DASHBOARD CONTENT =========================
                Item {
                    id: dashboardPage
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Full content mouse tracking for auto-close
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true
                        z: 20000
                        
                        onEntered: panel.mouseInside = true
                        onExited: panel.mouseInside = false
                        
                        onPressed: function(mouse) { mouse.accepted = false }
                        onReleased: function(mouse) { mouse.accepted = false }
                        onClicked: function(mouse) { mouse.accepted = false }
                        onDoubleClicked: function(mouse) { mouse.accepted = false }
                        onWheel: function(wheel) { wheel.accepted = false }
                    }

                    // Overlay for REMINDERS expansion only (full-page)
                    Item {
                        id: overlaySurface
                        anchors.fill: parent
                        visible: panel.remindersExpanded
                        z: 9999

                        Rectangle { anchors.fill: parent; color: "#000000"; opacity: 0 }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: (m) => { m.accepted = true }
                            onClicked: (m) => { m.accepted = true }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 12

                        ColumnLayout {
                            Layout.preferredWidth: 280
                            Layout.minimumWidth: 280
                            Layout.maximumWidth: 280
                            Layout.fillHeight: true

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                opacity: panel.remindersExpanded ? 0.0 : 1.0
                                enabled: !panel.remindersExpanded
                                Behavior on opacity { NumberAnimation { duration: 140 } }

                                Calendar { anchors.fill: parent }
                            }
                        }

                        // RIGHT: non-layout container (so expansions don't fight Layout)
                        Item {
                            id: rightRegion
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumWidth: 180

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 12

                                Item {
                                    id: weatherSlot
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.minimumHeight: 65
                                    opacity: panel.remindersExpanded ? 0.0 : 1.0
                                    enabled: !panel.remindersExpanded
                                    Behavior on opacity { NumberAnimation { duration: 140 } }
                                }

                                Item {
                                    id: remindersSlot
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.minimumHeight: 90
                                }
                            }
                        }
                    }

                    // ===== Weather Host =====
                    Item {
                        id: weatherHost
                        z: 9500

                        Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                        Weather {
                            anchors.fill: parent
                            iconDir: "../assets/weather"

                            expanded: panel.weatherExpanded
                            onRequestExpand: panel.weatherExpanded = true
                            onRequestCollapse: panel.weatherExpanded = false

                            // pause fetch only when reminders is full-expanded
                            active: panel.visible && !panel.remindersExpanded
                        }
                    }

                    // ===== Reminders Host =====
                    Item {
                        id: remindersHost
                        z: 10000

                        opacity: panel.weatherExpanded ? 0.0 : 1.0
                        enabled: !panel.weatherExpanded
                        Behavior on opacity { NumberAnimation { duration: 140 } }

                        Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                        Reminders {
                            anchors.fill: parent
                            expanded: panel.remindersExpanded
                            onRequestExpand: panel.remindersExpanded = true
                            onRequestCollapse: panel.remindersExpanded = false
                        }
                    }

                    // Reminders state machine (full-page expand)
                    StateGroup {
                        states: [
                            State {
                                name: "remindersNormal"
                                when: !panel.remindersExpanded
                                ParentChange { target: remindersHost; parent: remindersSlot }
                                PropertyChanges { target: remindersHost; x: 0; y: 0; width: remindersSlot.width; height: remindersSlot.height }
                            },
                            State {
                                name: "remindersExpanded"
                                when: panel.remindersExpanded
                                ParentChange { target: remindersHost; parent: overlaySurface }
                                PropertyChanges { target: remindersHost; x: 0; y: 0; width: overlaySurface.width; height: overlaySurface.height }
                            }
                        ]
                    }

                    // Weather state machine (expand over ENTIRE right side)
                    StateGroup {
                        states: [
                            State {
                                name: "weatherNormal"
                                when: !panel.weatherExpanded
                                ParentChange { target: weatherHost; parent: weatherSlot }
                                PropertyChanges { target: weatherHost; x: 0; y: 0; width: weatherSlot.width; height: weatherSlot.height }
                            },
                            State {
                                name: "weatherExpanded"
                                when: panel.weatherExpanded
                                ParentChange { target: weatherHost; parent: rightRegion }
                                PropertyChanges { target: weatherHost; x: 0; y: 0; width: rightRegion.width; height: rightRegion.height }
                            }
                        ]
                    }
                }
            }
        }
    }
}
