// qs/modules/controlpanel/Dnd.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services as Services

Item {
    id: root
    implicitHeight: 60
    Layout.fillWidth: true

    readonly property bool isDndOn: Services.Notifications?.doNotDisturb ?? false

    // Color palette (same pattern as Bluetooth)
    readonly property color cBg:        Services.Theme.colorMauve
    readonly property color cBorder:    Services.Theme.colorSurface1
    readonly property color cIcon:      Services.Theme.colorBase
    readonly property color cTitle:     Services.Theme.colorBase
    readonly property color cSubtitle:  Services.Theme.colorSurface0

    readonly property color dBg:        Services.Theme.colorSurface0
    readonly property color dBorder:    Services.Theme.colorSurface1
    readonly property color dIcon:      Services.Theme.colorText
    readonly property color dTitle:     Services.Theme.colorText
    readonly property color dSubtitle:  Services.Theme.colorSubtext0

    // ON/OFF colors based on DnD state
    readonly property color bgColor:       isDndOn ? cBg : dBg
    readonly property color borderColor:   isDndOn ? cBorder : dBorder
    readonly property color iconColor:     isDndOn ? cIcon : dIcon
    readonly property color titleColor:    isDndOn ? cTitle : dTitle
    readonly property color subtitleColor: isDndOn ? cSubtitle : dSubtitle

    function dndIcon() {
        return isDndOn ? "󰂛" : "󰂚"  // bell-off : bell
    }

    function subtitleText() {
        return isDndOn ? "On" : "Off"
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Services.Theme.moduleRadius
        color: bgColor
        border.width: 1
        border.color: borderColor

        property bool hovered: false
        property bool pressed: false
        scale: pressed ? Services.Theme.scalePressSmall : (hovered ? Services.Theme.scaleHoverSmall : 1.0)

        Behavior on scale { NumberAnimation { duration: Services.Theme.animDurationFast; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: Services.Theme.animDurationNormal } }
        Behavior on border.color { ColorAnimation { duration: Services.Theme.animDurationNormal } }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Services.Theme.paddingLarge
            spacing: Services.Theme.spacingLarge

            Text {
                text: dndIcon()
                color: iconColor
                font.pixelSize: Services.Theme.iconSizeLarge
                Layout.alignment: Qt.AlignVCenter

                Behavior on color { ColorAnimation { duration: Services.Theme.animDurationNormal } }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Services.Theme.spacingTiny

                Text {
                    text: "Do Not Disturb"
                    font.pixelSize: Services.Theme.fontSizeLarge
                    font.weight: Services.Theme.fontWeightBold
                    color: titleColor
                    elide: Text.ElideRight
                    Layout.fillWidth: true

                    Behavior on color { ColorAnimation { duration: Services.Theme.animDurationNormal } }
                }

                Text {
                    text: subtitleText()
                    font.pixelSize: Services.Theme.fontSizeSmall
                    color: subtitleColor
                    opacity: Services.Theme.opacityNormal
                    elide: Text.ElideRight
                    Layout.fillWidth: true

                    Behavior on color { ColorAnimation { duration: Services.Theme.animDurationNormal } }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: card.hovered = true
            onExited:  card.hovered = false
            onPressed: card.pressed = true
            onReleased: card.pressed = false
            onClicked: {
                if (Services.Notifications) {
                    Services.Notifications.doNotDisturb = !Services.Notifications.doNotDisturb
                }
            }
        }
    }
}

