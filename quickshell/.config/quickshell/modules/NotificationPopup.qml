// modules/NotificationPopup.qml
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.Notifications
import Quickshell.Widgets
import Quickshell
import qs.services as Services

Rectangle {
    id: root

    property bool onlyVisible: true
    required property var modelData

    Component.onCompleted: {
        appearAnimation.running = true;
    }

    // Initially offscreen and invisible
    x: width
    opacity: 0

    width: 350
    color: Services.Theme.colorBase
    radius: Services.Theme.moduleRadius
    border.color: {
        const urgency = modelData?.urgency ?? 1
        if (urgency === 2) return Services.Theme.colorRed      // Critical
        if (urgency === 1) return Services.Theme.colorBlue    // Normal
        return Services.Theme.colorGreen                       // Low
    }
    border.width: 2

    height: contentRow.height + 20

    ParallelAnimation {
        id: appearAnimation
        running: false

        NumberAnimation {
            target: root
            to: 0
            property: "x"
            duration: 200
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: root
            to: 1
            property: "opacity"
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    ParallelAnimation {
        id: discardAnimation
        running: false
        property var doAfter: () => {}

        NumberAnimation {
            target: root
            to: root.width
            property: "x"
            duration: 200
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: root
            to: 0
            property: "opacity"
            duration: 200
            easing.type: Easing.InOutQuad
        }

        onFinished: () => {
            doAfter();
        }
    }

    function dismiss() {
        discardAnimation.doAfter = () => {
            if (root.modelData?.notification)
                root.modelData.notification.dismiss();
        };
        discardAnimation.running = true;
    }

    function hide() {
        if (!root.onlyVisible)
            return;
        discardAnimation.doAfter = () => {
            if (root.modelData)
                root.modelData.popup = false;
        };
        discardAnimation.running = true;
    }

    // Hide button (top right, silent dismiss)
    Rectangle {
        visible: root.onlyVisible
        width: 24
        height: 24
        radius: 12
        color: hideMouse.containsMouse ? Services.Theme.colorSurface1 : "transparent"
        anchors {
            top: root.top
            right: root.right
            topMargin: 10
            rightMargin: 35
        }

        Behavior on color { ColorAnimation { duration: Services.Theme.animDurationFast } }

        Text {
            anchors.centerIn: parent
            text: "󰈉"
            font.family: Services.Theme.fontFamilyMono
            font.pixelSize: 16
            color: Services.Theme.colorText
        }

        MouseArea {
            id: hideMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.hide()
        }
    }

    // Close button (top right corner)
    Rectangle {
        width: 24
        height: 24
        radius: 12
        color: closeMouse.containsMouse ? Services.Theme.colorRed : "transparent"
        anchors {
            top: root.top
            right: root.right
            topMargin: 10
            rightMargin: 10
        }

        Behavior on color { ColorAnimation { duration: Services.Theme.animDurationFast } }

        Text {
            anchors.centerIn: parent
            text: ""
            font.family: Services.Theme.fontFamilyMono
            font.pixelSize: 16
            color: Services.Theme.colorText
        }

        MouseArea {
            id: closeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.dismiss()
        }
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Services.Theme.spacingMedium
        width: parent.width - 20

        // Icon area
        Rectangle {
            id: iconBackground
            anchors.verticalCenter: parent.verticalCenter
            implicitHeight: 36
            implicitWidth: 36
            radius: Services.Theme.spacingSmall
            color: Services.Theme.colorSurface0
            clip: true

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.hide()
            }

            // Image (highest priority)
            Image {
                id: notifImage
                anchors.fill: parent
                source: root.modelData?.image ?? ""
                fillMode: Image.PreserveAspectCrop
                visible: source.toString().length > 0 && status === Image.Ready
                asynchronous: true
                cache: false
                onStatusChanged: {
                    if (status === Image.Error) {
                        // Silently handle broken image paths (temp files may be deleted)
                        visible = false
                    }
                }
            }

            // App icon (medium priority)
            IconImage {
                id: appIconImage
                anchors.fill: parent
                source: {
                    const iconName = root.modelData?.appIcon ?? ""
                    return iconName.length > 0 ? Quickshell.iconPath(iconName) : ""
                }
                visible: !notifImage.visible && source.toString().length > 0
                asynchronous: true
            }

            // Fallback icon (lowest priority)
            Text {
                anchors.centerIn: parent
                text: "󰂚"
                font.family: Services.Theme.fontFamilyMono
                font.pixelSize: 24
                color: Services.Theme.colorText
                opacity: Services.Theme.opacityMuted
                visible: !notifImage.visible && !appIconImage.visible
            }
        }

        // Text content
        Column {
            id: textColumn
            width: contentRow.width - iconBackground.width - Services.Theme.spacingMedium - 10
            spacing: Services.Theme.spacingSmall

            property bool collapsed: true
            property int maxLength: 50

            Text {
                width: parent.width
                text: root.modelData?.summary ?? "Notification"
                font.family: Services.Theme.fontFamilyMono
                font.pixelSize: Services.Theme.fontSizeNormal
                font.weight: Font.Medium
                color: Services.Theme.colorText
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                maximumLineCount: 2
            }

            Text {
                width: parent.width
                text: {
                    const body = root.modelData?.body ?? ""
                    if (!textColumn.collapsed || body.length <= textColumn.maxLength)
                        return body
                    return body.substring(0, textColumn.maxLength) + "..."
                }
                font.family: Services.Theme.fontFamilyMono
                font.pixelSize: Services.Theme.fontSizeSmall
                color: Services.Theme.colorSubtext0
                wrapMode: Text.Wrap
                maximumLineCount: textColumn.collapsed ? 3 : 10
                visible: text.length > 0

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        textColumn.collapsed = !textColumn.collapsed
                        if (textColumn.collapsed && root.modelData?.timer)
                            root.modelData.timer.restart()
                        else if (root.modelData?.timer)
                            root.modelData.timer.stop()
                    }
                }
            }
        }
    }
}
