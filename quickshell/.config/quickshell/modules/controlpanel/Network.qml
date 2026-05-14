import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.services as Services

Item {
    id: root
    implicitHeight: 60
    Layout.fillWidth: true

    property var onActivate: function() {}

    // ---- state ----
    readonly property bool isConnected: Services.Network?.connected ?? false
    readonly property bool wifiEnabled: Services.Network?.wifiEnabled ?? true   // updated from Service

    // ---- palettes ----
    // ON palette (same vibe as your Bluetooth change)
    readonly property color cBg:        Services.Theme.colorLavender
    readonly property color cBorder:    Services.Theme.colorSurface1
    readonly property color cIcon:      Services.Theme.colorBase
    readonly property color cTitle:     Services.Theme.colorBase
    readonly property color cSubtitle:  Services.Theme.colorSurface0

    // OFF palette
    readonly property color dBg:        Services.Theme.colorSurface0
    readonly property color dBorder:    Services.Theme.colorSurface1
    readonly property color dIcon:      Services.Theme.colorText
    readonly property color dTitle:     Services.Theme.colorText
    readonly property color dSubtitle:  Services.Theme.colorSubtext0

    // ✅ OFF palette when NOT connected (ignores wifiEnabled for coloring)
    readonly property color bgColor:       isConnected ? cBg : dBg
    readonly property color borderColor:   isConnected ? cBorder : dBorder
    readonly property color iconColor:     isConnected ? cIcon : dIcon
    readonly property color titleColor:    isConnected ? cTitle : dTitle
    readonly property color subtitleColor: isConnected ? cSubtitle : dSubtitle


    function wifiIcon(enabled, connected, strength) {
        if (!enabled) return "󰤭"          // wifi off
        if (!connected) return "󰤮"        // disconnected
        if (strength >= 75) return "󰤨"
        if (strength >= 50) return "󰤥"
        if (strength >= 25) return "󰤢"
        return "󰤟"
    }

    function subtitleText() {
        if (!wifiEnabled) return "Off"
        return isConnected ? "Connected" : "Disconnected"
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
                text: wifiIcon(root.wifiEnabled, root.isConnected, Services.Network?.signalStrength ?? 0)
                color: iconColor
                font.pixelSize: Services.Theme.iconSizeLarge
                font.family: Services.Theme.fontFamilyMono
                opacity: root.wifiEnabled ? Services.Theme.opacityFull : Services.Theme.opacitySubtle
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: -Services.Theme.spacingSmall
                Layout.alignment: Qt.AlignVCenter

                Text {
                    Layout.fillWidth: true
                    text: root.wifiEnabled
                          ? (Services.Network?.connectedSsid || "Wi-Fi")
                          : "Wi-Fi"
                    color: titleColor
                    font.pixelSize: Services.Theme.fontSizeNormal
                    font.weight: Services.Theme.fontWeightBold
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: subtitleText()
                    color: subtitleColor
                    opacity: Services.Theme.opacityNormal
                    font.pixelSize: Services.Theme.fontSizeSmall
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: card.hovered = true
            onExited: card.hovered = false
            onPressed: card.pressed = true
            onReleased: card.pressed = false
            onClicked: {
                // Open the detailed view
                root.onActivate()
            }
        }
    }
}
