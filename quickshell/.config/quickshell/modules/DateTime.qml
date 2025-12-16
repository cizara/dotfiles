import QtQuick
import Quickshell
import qs.services as Services

Rectangle {
    id: root
    readonly property var dateTimeService: Services.DateTime
    height: Services.Theme.moduleHeight
    radius: height / 2
    color: Services.Theme.colorSurface0
    border.width: 1
    border.color: Services.Theme.colorSurface0
    antialiasing: true

    implicitWidth: timeRow.implicitWidth + Services.Theme.paddingModule

    property bool hovered: false
    property bool pressed: false

    property var panelWin: null

    scale: pressed ? Services.Theme.scalePressSmall : (hovered ? Services.Theme.scaleHover : 1.0)
    Behavior on scale {
        NumberAnimation { duration: Services.Theme.animDurationFast; easing.type: Easing.OutQuad }
    }

    function ensurePanel() {
        if (panelWin) return true

        const cmp = Qt.createComponent(Qt.resolvedUrl("WidgetPanel.qml"))
        if (cmp.status !== Component.Ready) {
            console.log("WidgetPanel load failed:", cmp.errorString())
            return false
        }

        panelWin = cmp.createObject(null)
        if (!panelWin) {
            console.log("WidgetPanel createObject failed")
            return false
        }

        return true
    }

    function togglePanel() {
        if (!ensurePanel()) return
        panelWin.visible = !panelWin.visible
    }

    Row {
        id: timeRow
        anchors.centerIn: parent
        spacing: Services.Theme.spacingLarge
        
        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: Services.Theme.colorBlue
            font.pixelSize: Services.Theme.fontSizeNormal
            font.family: Services.Theme.fontFamily
            text: "Arg " + root.dateTimeService.argTime
        }
        
        Text {
            id: timeText
            anchors.verticalCenter: parent.verticalCenter
            color: Services.Theme.colorTextBright
            font.pixelSize: Services.Theme.fontSizeNormal
            font.family: Services.Theme.fontFamily
            text: root.dateTimeService.currentTime
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
        onClicked: root.togglePanel()
    }
}
