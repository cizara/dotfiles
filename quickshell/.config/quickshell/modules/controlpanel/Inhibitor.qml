// qs/modules/FillerTile.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.services as Services

Item {
    id: root
    implicitHeight: 60
    Layout.fillWidth: true

    property string title: "Filler"
    property string subtitle: "Sample module"
    property string icon: "󰒲"
    signal clicked()

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Services.Theme.moduleRadius
        color: Services.Theme.colorBase
        border.width: 1
        border.color: Services.Theme.colorSurface0

        property bool hovered: false
        property bool pressed: false

        scale: pressed ? Services.Theme.scalePressSmall : (hovered ? Services.Theme.scaleHoverSmall : 1.0)

        Behavior on scale { NumberAnimation { duration: Services.Theme.animDurationNormal; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: Services.Theme.animDurationNormal } }
        color: pressed ? Services.Theme.colorMantle : Services.Theme.colorBase

        RowLayout {
            anchors.fill: parent
            anchors.margins: Services.Theme.paddingLarge
            spacing: Services.Theme.spacingLarge

            // Icon bubble
            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: Services.Theme.colorSurface0
                Layout.alignment: Qt.AlignVCenter

                Text {
                    anchors.centerIn: parent
                    text: root.icon
                    font.pixelSize: Services.Theme.iconSizeNormal
                    color: Services.Theme.colorText
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Services.Theme.spacingTiny

                Text {
                    Layout.fillWidth: true
                    text: root.title
                    font.pixelSize: Services.Theme.fontSizeLarge
                    font.weight: Services.Theme.fontWeightBold
                    color: Services.Theme.colorText
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: root.subtitle
                    font.pixelSize: Services.Theme.fontSizeSmall
                    color: Services.Theme.colorSubtext0
                    opacity: Services.Theme.opacityNormal
                    elide: Text.ElideRight
                }
            }

            // Right-side chevron-ish hint
            Text {
                text: "›"
                font.pixelSize: Services.Theme.fontSizeTitle
                color: Services.Theme.colorSubtext0
                opacity: Services.Theme.opacityMuted
                Layout.alignment: Qt.AlignVCenter
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
            onClicked: root.clicked()
        }
    }
}
