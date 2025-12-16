// modules/NotificationsPanel.qml
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.services as Services

Item {
    id: root
    
    implicitWidth: parent?.width ?? 300
    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: Services.Theme.spacingMedium

        // Header row
        RowLayout {
            Layout.fillWidth: true
            spacing: Services.Theme.spacingMedium

            Text {
                text: "󰂚  Notifications"
                font.family: Services.Theme.fontFamilyMono
                font.pixelSize: Services.Theme.fontSizeNormal
                color: Services.Theme.colorText
                opacity: Services.Theme.opacityNormal
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            // DND toggle
            Rectangle {
                width: Services.Theme.pillHeight
                height: Services.Theme.pillHeight
                radius: Services.Theme.spacingMedium
                color: dndBtnMouse.pressed ? Services.Theme.colorButtonPress : (dndBtnMouse.containsMouse ? Services.Theme.colorButtonHover : Services.Theme.colorSurface0)
                border.width: 1
                border.color: Services.Theme.colorSurface1
                Layout.alignment: Qt.AlignVCenter
                opacity: Services.Notifications?.doNotDisturb ? 1.0 : Services.Theme.opacityNormal

                Behavior on color { ColorAnimation { duration: Services.Theme.animDurationNormal } }
                Behavior on opacity { NumberAnimation { duration: Services.Theme.animDurationNormal } }

                Text {
                    anchors.centerIn: parent
                    text: Services.Notifications?.doNotDisturb ? "󰂛" : "󰂚"
                    font.family: Services.Theme.fontFamilyMono
                    font.pixelSize: Services.Theme.iconSizeNormal
                    color: Services.Theme.colorText
                }

                MouseArea {
                    id: dndBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (Services.Notifications)
                            Services.Notifications.doNotDisturb = !Services.Notifications.doNotDisturb
                    }
                }
            }

            // Clear all button
            Rectangle {
                width: Services.Theme.pillHeight
                height: Services.Theme.pillHeight
                radius: Services.Theme.spacingMedium
                color: clearBtnMouse.pressed ? Services.Theme.colorButtonPress : (clearBtnMouse.containsMouse ? Services.Theme.colorButtonHover : Services.Theme.colorSurface0)
                border.width: 1
                border.color: Services.Theme.colorSurface1
                Layout.alignment: Qt.AlignVCenter

                Behavior on color { ColorAnimation { duration: Services.Theme.animDurationNormal } }

                Text {
                    anchors.centerIn: parent
                    text: "󰆴"
                    font.family: Services.Theme.fontFamilyMono
                    font.pixelSize: Services.Theme.iconSizeNormal
                    color: Services.Theme.colorText
                    opacity: Services.Theme.opacityNormal
                }

                MouseArea {
                    id: clearBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (Services.Notifications)
                            Services.Notifications.clearAll()
                    }
                }
            }
        }

        // Notification list area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Services.Theme.moduleRadius
            color: Services.Theme.colorBase
            border.width: 1
            border.color: Services.Theme.colorSurface0
            clip: true

            ScrollView {
                id: scrollView
                anchors.fill: parent
                anchors.margins: Services.Theme.spacingSmall
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    contentItem: Rectangle {
                        implicitWidth: 4
                        radius: 2
                        color: Services.Theme.colorSurface1
                        opacity: parent.active ? 1.0 : 0.5
                    }
                }

                Column {
                    width: scrollView.width - (scrollView.ScrollBar.vertical.visible ? scrollView.ScrollBar.vertical.width : 0) - Services.Theme.spacingSmall * 2
                    spacing: Services.Theme.spacingSmall

                    Repeater {
                        model: Services.Notifications?.history ?? []

                        delegate: Rectangle {
                            id: notifItem
                            required property var modelData
                            
                            width: parent.width
                            implicitHeight: notifContent.implicitHeight + Services.Theme.spacingMedium * 2
                            radius: Services.Theme.spacingSmall
                            color: notifMouse.containsMouse ? Services.Theme.colorSurface0 : Services.Theme.colorMantle
                            border.width: 1
                            border.color: {
                                const urgency = modelData?.urgency ?? 1
                                if (urgency === 2) return Services.Theme.colorRed      // Critical
                                if (urgency === 1) return Services.Theme.colorBlue    // Normal
                                return Services.Theme.colorGreen                      // Low
                            }

                            Behavior on color { ColorAnimation { duration: Services.Theme.animDurationFast } }

                            MouseArea {
                                id: notifMouse
                                anchors.fill: parent
                                hoverEnabled: true
                            }

                            RowLayout {
                                id: notifContent
                                anchors.fill: parent
                                anchors.margins: Services.Theme.spacingMedium
                                spacing: Services.Theme.spacingMedium

                                // App icon or fallback
                                Rectangle {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    Layout.alignment: Qt.AlignTop
                                    radius: Services.Theme.spacingSmall
                                    color: Services.Theme.colorSurface0

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰂚"
                                        font.family: Services.Theme.fontFamilyMono
                                        font.pixelSize: 20
                                        color: Services.Theme.colorText
                                        opacity: Services.Theme.opacityMuted
                                    }
                                }

                                // Text content
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop
                                    spacing: Services.Theme.spacingSmall

                                    Text {
                                        Layout.fillWidth: true
                                        text: notifItem.modelData?.summary ?? "Notification"
                                        font.family: Services.Theme.fontFamilyMono
                                        font.pixelSize: Services.Theme.fontSizeNormal
                                        font.weight: Font.Medium
                                        color: Services.Theme.colorText
                                        elide: Text.ElideRight
                                        wrapMode: Text.Wrap
                                        maximumLineCount: 2
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: notifItem.modelData?.body ?? ""
                                        font.family: Services.Theme.fontFamilyMono
                                        font.pixelSize: Services.Theme.fontSizeSmall
                                        color: Services.Theme.colorSubtext0
                                        elide: Text.ElideRight
                                        wrapMode: Text.Wrap
                                        maximumLineCount: 3
                                        visible: text.length > 0
                                    }

                                    // Time ago
                                    Text {
                                        text: notifItem.modelData?.timeStr ?? ""
                                        font.family: Services.Theme.fontFamilyMono
                                        font.pixelSize: Services.Theme.fontSizeSmall
                                        color: Services.Theme.colorSubtext1
                                        opacity: Services.Theme.opacityMuted
                                    }
                                }

                                // Dismiss button
                                Rectangle {
                                    Layout.preferredWidth: 24
                                    Layout.preferredHeight: 24
                                    Layout.alignment: Qt.AlignTop
                                    radius: 12
                                    color: dismissMouse.pressed ? Services.Theme.colorButtonPress : (dismissMouse.containsMouse ? Services.Theme.colorRed : "transparent")
                                    opacity: dismissMouse.containsMouse ? 1.0 : 0.5

                                    Behavior on color { ColorAnimation { duration: Services.Theme.animDurationFast } }
                                    Behavior on opacity { NumberAnimation { duration: Services.Theme.animDurationFast } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: ""
                                        font.family: Services.Theme.fontFamilyMono
                                        font.pixelSize: 12
                                        color: Services.Theme.colorText
                                    }

                                    MouseArea {
                                        id: dismissMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (notifItem.modelData?.notification)
                                                notifItem.modelData.notification.dismiss()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Empty state
            Text {
                anchors.centerIn: parent
                text: Services.Notifications?.doNotDisturb ? "Do Not Disturb enabled" : "No new notifications"
                color: Services.Theme.colorSubtext0
                font.family: Services.Theme.fontFamilyMono
                font.pixelSize: Services.Theme.fontSizeNormal
                opacity: Services.Theme.opacityMuted
                visible: (Services.Notifications?.history.length ?? 0) === 0
            }
        }
    }
}
