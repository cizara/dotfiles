import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services as Services

Item {
    id: root

    implicitHeight: Services.Theme.moduleHeight
    implicitWidth: bg.implicitWidth

    // Colors
    property color normalFillColor: Services.Theme.colorLavender
    property color lowFillColor: Services.Theme.colorRed
    property color chargingFillColor: Services.Theme.colorGreen
    property color bgColor: Services.Theme.colorSurface0
    property color textColor: Services.Theme.colorOverlay0

    // Battery values from singleton
    property int batteryPercent: Services.BatteryMonitor.batteryPercent
    property string batteryStatus: Services.BatteryMonitor.batteryStatus
    property string lastStatus: "Unknown"

    // Startup animation control
    property bool startupDone: false
    property real animatedPercent: 100.0

    onBatteryPercentChanged: {
        if (!startupDone) {
            animPercent.from = 100
            animPercent.to = batteryPercent
            animPercent.running = true
            startupDone = true
        } else {
            animatedPercent = batteryPercent
        }
    }

    onBatteryStatusChanged: {
        if (lastStatus !== batteryStatus) {
            icon.scale = 0.7
            iconPop.from = 0.7
            iconPop.to = 1.0
            iconPop.running = true
        }
        lastStatus = batteryStatus
    }

    NumberAnimation {
        id: animPercent
        target: root
        property: "animatedPercent"
        duration: 700
        easing.type: Easing.InOutQuad
    }

    NumberAnimation {
        id: iconPop
        target: icon
        property: "scale"
        duration: Services.Theme.animDurationVerySlow
        easing.type: Easing.OutBack
    }

    // BACKGROUND PILL (with proper implicit size for layout engines)
    ClippingRectangle {
        id: bg
        anchors.centerIn: parent
        height: Services.Theme.moduleHeight
        radius: height / 2
        color: bgColor

        width: contentRow.implicitWidth + Services.Theme.paddingMedium
        implicitWidth: width

        // FILL BAR
        Rectangle {
            id: fill
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: parent.width * (animatedPercent / 100.0)

            radius: 0
            color: batteryStatus === "Charging"
                   ? chargingFillColor
                   : (batteryPercent <= 20 ? lowFillColor : normalFillColor)

            Behavior on width {
                NumberAnimation { duration: 450; easing.type: Easing.InOutQuad }
            }

            Behavior on color {
                ColorAnimation { duration: Services.Theme.animDurationBounce; easing.type: Easing.InOutQuad }
            }
        }

        // CONTENT
        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: Services.Theme.spacingNormal

            Text {
                id: icon
                text: batteryStatus === "Charging" ? "󰺥" : "󰁹"
                font.family: Services.Theme.fontFamilyMono
                font.pixelSize: Services.Theme.iconSizeNormal
                color: textColor
            }

            Text {
                text: batteryPercent + "%"
                font.family: Services.Theme.fontFamily
                font.pixelSize: Services.Theme.fontSizeNormal
                color: textColor
            }
        }
    }
}