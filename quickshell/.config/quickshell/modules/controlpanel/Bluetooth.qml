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
    property string fallbackTitle: "Bluetooth"

    readonly property bool isConnected: Services.Bluetooth?.connected ?? false
    readonly property bool isPowered: Services.Bluetooth?.powered ?? false

    // palette (same as your Wi-Fi button)
    readonly property color cBg:        Services.Theme.colorLavender
    readonly property color cBorder:    Services.Theme.colorSurface1
    readonly property color cIcon:      Services.Theme.colorBase
    readonly property color cTitle:     Services.Theme.colorBase
    readonly property color cSubtitle:  Services.Theme.colorSurface0

    readonly property color dBg:        Services.Theme.colorSurface0
    readonly property color dBorder:    Services.Theme.colorSurface1
    readonly property color dIcon:      Services.Theme.colorText
    readonly property color dTitle:     Services.Theme.colorText
    readonly property color dSubtitle:  Services.Theme.colorSubtext0

    // ✅ ON/OFF colors should follow POWER state, not connection state
    readonly property color bgColor:       isPowered ? cBg : dBg
    readonly property color borderColor:   isPowered ? cBorder : dBorder
    readonly property color iconColor:     isPowered ? cIcon : dIcon
    readonly property color titleColor:    isPowered ? cTitle : dTitle
    readonly property color subtitleColor: isPowered ? cSubtitle : dSubtitle

    function btIcon(powered, connected) {
        if (!powered) return "󰂲"     // off
        if (connected) return "󰂱"    // connected
        return "󰂯"                   // on (not connected)
    }

    function subtitleText() {
        if (!isPowered) return "Off"
        return isConnected ? "Connected" : "On"
    }

    // ✅ toggle Bluetooth power
    Process {
        id: btPowerProc
        command: ["bash", "-lc", "bluetoothctl power " + (root.isPowered ? "off" : "on")]
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
                text: btIcon(isPowered, isConnected)
                color: iconColor
                font.pixelSize: Services.Theme.iconSizeLarge
                font.family: Services.Theme.fontFamilyMono
                opacity: isPowered ? Services.Theme.opacityFull : Services.Theme.opacitySubtle
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: -Services.Theme.spacingSmall
                Layout.alignment: Qt.AlignVCenter

                Text {
                    Layout.fillWidth: true
                    text: isConnected ? Services.Bluetooth.deviceName : root.fallbackTitle
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
                // toggle power
                btPowerProc.running = false
                btPowerProc.running = true

                // keep your existing hook (open menu, etc.)
                root.onActivate()
            }
        }
    }
}
