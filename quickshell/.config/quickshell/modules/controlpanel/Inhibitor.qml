// qs/modules/controlpanel/Inhibitor.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services as Services

Item {
    id: root
    implicitHeight: 60
    Layout.fillWidth: true

    readonly property bool isActive: Services.Inhibitor?.active ?? false

    // Color palette (similar to DnD but with different accent color)
    readonly property color cBg:        Services.Theme.colorPeach
    readonly property color cBorder:    Services.Theme.colorSurface1
    readonly property color cIcon:      Services.Theme.colorBase
    readonly property color cTitle:     Services.Theme.colorBase
    readonly property color cSubtitle:  Services.Theme.colorSurface0

    readonly property color dBg:        Services.Theme.colorSurface0
    readonly property color dBorder:    Services.Theme.colorSurface1
    readonly property color dIcon:      Services.Theme.colorText
    readonly property color dTitle:     Services.Theme.colorText
    readonly property color dSubtitle:  Services.Theme.colorSubtext0

    // ON/OFF colors based on inhibitor state
    readonly property color bgColor:       isActive ? cBg : dBg
    readonly property color borderColor:   isActive ? cBorder : dBorder
    readonly property color iconColor:     isActive ? cIcon : dIcon
    readonly property color titleColor:    isActive ? cTitle : dTitle
    readonly property color subtitleColor: isActive ? cSubtitle : dSubtitle

    function inhibitorIcon() {
        return isActive ? "󰾪" : "󰾫"  // mug-hot : mug (coffee filled : empty)
    }

    function subtitleText() {
        return isActive ? "Active" : "Inactive"
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
                text: inhibitorIcon()
                color: iconColor
                font.pixelSize: Services.Theme.iconSizeLarge
                Layout.alignment: Qt.AlignVCenter

                Behavior on color { ColorAnimation { duration: Services.Theme.animDurationNormal } }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Services.Theme.spacingTiny

                Text {
                    text: "Keep Awake"
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
                if (Services.Inhibitor) {
                    Services.Inhibitor.toggle()
                }
            }
        }
    }
}
