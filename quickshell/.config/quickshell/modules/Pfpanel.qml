import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.services as Services
import qs.modules as Modules

Rectangle {
    id: root
    height: Services.Theme.moduleHeight
    radius: Services.Theme.moduleRadius
    color: Services.Theme.colorSurface0
    border.width: 1
    border.color: Services.Theme.colorSurface0
    antialiasing: true

    // tighter padding for a 28px pill
    implicitWidth: row.implicitWidth + Services.Theme.paddingNormal * 2

    property bool hovered: false
    property bool pressed: false

    scale: pressed ? Services.Theme.scalePress : (hovered ? Services.Theme.scaleHoverSmall : 1.0)
    Behavior on scale { NumberAnimation { duration: Services.Theme.animDurationNormal; easing.type: Easing.OutCubic } }

    function wifiIcon(connected, strength) {
        if (!connected) return "󰤮"
        if (strength >= 75) return "󰤨"
        if (strength >= 50) return "󰤥"
        if (strength >= 25) return "󰤢"
        return "󰤟"
    }

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: Services.Theme.paddingMedium
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        spacing: Services.Theme.spacingTiny

        Text {
            text: wifiIcon(Services.Network?.connected ?? false, Services.Network?.signalStrength ?? 0)
            font.family: Services.Theme.fontFamilyMono
            font.pixelSize: Services.Theme.fontSizeNormal
            color: Services.Theme.colorText
            opacity: (Services.Network?.connected ?? false) ? Services.Theme.opacityFull : Services.Theme.opacityMuted
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: ""
            font.family: Services.Theme.fontFamilyMono
            font.pixelSize: Services.Theme.fontSizeNormal
            color: Services.Theme.colorText
            opacity: Services.Theme.opacityNormal
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: "󰃠 "
            font.family: Services.Theme.fontFamilyMono
            font.pixelSize: Services.Theme.fontSizeNormal
            color: Services.Theme.colorText
            opacity: Services.Theme.opacityNormal
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: { root.hovered = false; root.pressed = false }
        onPressed: root.pressed = true
        onReleased: root.pressed = false
        onClicked: Modules.Panel.toggle()
    }
}