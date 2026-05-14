import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

Row {
    id: root

    spacing: 4
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items.values

        Rectangle {
            id: component
            required property SystemTrayItem modelData
            property alias item: component.modelData
            width: 24
            height: 24
            radius: 4
            color: mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

            Behavior on color {
                ColorAnimation { duration: 200 }
            }

            IconImage {
                anchors.centerIn: parent
                implicitWidth: 20
                implicitHeight: 20
                source: component.item.icon
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: component.item.menu
                anchor.window: component.QsWindow.window

                anchor.onAnchoring: {
                    const window = component.QsWindow.window;
                    const widgetRect = window.contentItem.mapFromItem(
                        component, 0, component.height, 
                        component.width, component.height
                    );
                    menuAnchor.anchor.rect = widgetRect;
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: component
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                
                onClicked: function (mouse) {
                    if (component.item.onlyMenu || mouse.button === Qt.RightButton) {
                        menuAnchor.open();
                    } else if (mouse.button === Qt.LeftButton) {
                        component.item.activate();
                    } else {
                        component.item.secondaryActivate();
                    }
                }
                
                onHoveredChanged: {
                    if (component.modelData.tooltipTitle != "")
                        tooltip.visible = mouseArea.containsMouse;
                }
            }

            Loader {
                id: tooltip
                active: visible
                visible: false

                sourceComponent: PopupWindow {
                    visible: tooltip.visible
                    color: "transparent"
                    
                    anchor {
                        item: component
                        margins.top: 5
                        rect {
                            y: component.height
                        }
                    }

                    Rectangle {
                        implicitWidth: tooltipText.implicitWidth + 10
                        implicitHeight: tooltipText.implicitHeight + 10
                        color: Qt.rgba(0.1, 0.1, 0.1, 0.95)
                        radius: 4
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.2)

                        Text {
                            id: tooltipText
                            anchors.centerIn: parent
                            text: component.modelData.tooltipTitle
                            color: "white"
                            padding: 5
                        }
                    }
                }
            }
        }
    }
}
