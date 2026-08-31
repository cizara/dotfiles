// modules/Panel.qml
pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services as Services
import qs.modules
import qs.modules.controlpanel
import "." as Modules

Singleton {
    id: controller

    property bool open: false
    property bool closing: false

    function toggle()     { controller.open ? controller.closePanel() : controller.openPanel() }
    function openPanel()  { controller.closing = false; controller.open = true }
    function closePanel() { controller.closing = true; controller.open = false }

    // ---- BACKDROP (click to close) ----
    LazyLoader {
        id: backdropLoader
        activeAsync: controller.open || controller.closing

        PanelWindow {
            id: backdrop
            color: "transparent"
            visible: true
            exclusiveZone: -1

            anchors { top: true; bottom: true; left: true; right: true }

            MouseArea {
                anchors.fill: parent
                onClicked: controller.closePanel()
            }
        }
    }

    // ---- MAIN PANEL WINDOW ----
    LazyLoader {
        id: panelLoader
        activeAsync: controller.open || controller.closing

        PanelWindow {
            id: panel
            visible: true
            color: "transparent"
            exclusiveZone: 0
            
            focusable: true
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            implicitWidth: 360
            implicitHeight: 1020

            anchors { top: true; right: true }

            // slide positions
            property int barHeight: 36
            property int gapUnderBar: 20
            property int shownTop: 6
            property int hiddenTop: shownTop - height - 20

            margins { top: hiddenTop; right: 6 }

            Behavior on margins.top {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                    onRunningChanged: {
                        if (!running && controller.closing && !controller.open)
                            controller.closing = false
                    }
                }
            }

            Component.onCompleted: margins.top = shownTop

            Connections {
                target: controller
                function onOpenChanged() {
                    if (!controller.open)
                        panel.margins.top = panel.hiddenTop
                }
            }

            // ---- CONTENT ----
            Rectangle {
                id: container
                anchors.fill: parent
                radius: Services.Theme.moduleRadius
                color: Services.Theme.colorMantle

                StackLayout {
                    id: contentStack
                    anchors.fill: parent
                    currentIndex: 0

                    // --- Index 0: Main Dashboard ---
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            id: mainLayout
                            anchors.fill: parent
                            anchors.margins: Services.Theme.paddingLarge
                            spacing: Services.Theme.spacingXLarge

                            // --- Top Section ---
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Services.Theme.spacingXLarge

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: Services.Theme.spacingTiny
                                    Layout.alignment: Qt.AlignVCenter

                                    RowLayout {
                                        spacing: Services.Theme.spacingMedium

                                        Text {
                                            text: Services.SystemDetails?.osIcon ?? ""
                                            color: Services.Theme.colorText
                                            font.pixelSize: Services.Theme.iconSizeHuge
                                        }

                                        Text {
                                            text: Services.SystemDetails?.uptime ?? "--"   // your service uses uptime -p already
                                            color: Services.Theme.colorText
                                            opacity: Services.Theme.opacitySubtle
                                            font.pixelSize: Services.Theme.fontSizeLarge
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                // Session actions, top-right of the header next to
                                // the uptime readout.
                                Modules.PowerActions {
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                radius: 1
                                color: Services.Theme.colorSurface0
                                opacity: Services.Theme.opacityNormal
                            }

                            // --- Your panel content goes here ---

                            GridLayout {
                                id: middleGrid
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: Services.Theme.spacingLarge
                                rowSpacing: Services.Theme.spacingLarge

                                // Make all items stretch equally
                                Layout.preferredWidth: parent.width

                                Network {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                    onActivate: function() { contentStack.currentIndex = 1 }
                                }
                                Bluetooth {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                    onActivate: function() { console.log("bluetooth clicked") }
                                }

                                Inhibitor {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                }

                                Dnd {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60                         
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                radius: 1
                                color: Services.Theme.colorSurface0
                                opacity: Services.Theme.opacityNormal
                            }

                            Volume {
                                Layout.fillWidth: true
                            }

                            Brightness {
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                radius: 1
                                color: Services.Theme.colorSurface0
                                opacity: Services.Theme.opacityNormal
                            }

                            // --- System Notifications ---
                            Modules.NotificationsPanel {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }
                        }
                    }

                    // --- Index 1: Network List ---
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        Modules.NetworkPanel {
                            anchors.fill: parent
                            anchors.margins: Services.Theme.paddingLarge
                            onBack: contentStack.currentIndex = 0
                        }
                    }
                }
            }
        }
    }

    function init() {}
}