import QtQuick
import Quickshell
import qs.services as Services

Item {
    id: root
    implicitWidth: Services.Theme.moduleHeight
    implicitHeight: Services.Theme.moduleHeight

    readonly property var temperatureService: Services.Temperature

    // theme
    property color ringBg: Services.Theme.colorRingBg
    property color ringFg: {
        if (tempC < 80) return Services.Theme.colorRingFgLow
        if (tempC < 90) return Services.Theme.colorRingFgMedium
        return Services.Theme.colorRingFgHigh
    }
    property color iconColor: Services.Theme.colorText

    // ring tuning
    property int ringWidth: Services.Theme.ringWidth
    property real ringInset: Services.Theme.ringInset

    // temperature tuning
    property int tempYOffset: 1

    // data from service
    readonly property real tempC: temperatureService.tempC
    readonly property real usedFrac: temperatureService.usedFrac
    readonly property int tempRounded: temperatureService.tempRounded

    property var onActivate: function() {}

    // hover/press
    property bool hovered: false
    property bool pressed: false
    scale: pressed ? Services.Theme.scalePress : (hovered ? Services.Theme.scaleHover : 1.0)
    Behavior on scale { NumberAnimation { duration: Services.Theme.animDurationNormal; easing.type: Easing.OutCubic } }

    // ---------- RING ----------
    Canvas {
        id: ring
        anchors.fill: parent
        antialiasing: true

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Component.onCompleted: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            const w = width
            const h = height
            if (w <= 0 || h <= 0) return

            const cx = w / 2
            const cy = h / 2

            const r = Math.max(
                0,
                Math.min(w, h) / 2 - (root.ringWidth / 2) - root.ringInset
            )

            const start = -Math.PI / 2
            const span  = Math.PI * 2
            const eps   = 0.001

            // background track
            ctx.beginPath()
            ctx.lineWidth = root.ringWidth
            ctx.lineCap = "butt"
            ctx.strokeStyle = root.ringBg
            ctx.globalAlpha = Services.Theme.opacityRingBg
            ctx.arc(cx, cy, r, start, start + span, false)
            ctx.stroke()

            // progress arc
            const p = Math.max(0, Math.min(1, root.usedFrac))
            if (p > 0) {
                let end = start + (span * p)
                if (p >= 0.9999) end = start + span - eps

                ctx.beginPath()
                ctx.globalAlpha = 1.0
                ctx.lineWidth = root.ringWidth
                ctx.lineCap = "round"
                ctx.strokeStyle = root.ringFg
                ctx.shadowBlur = 0
                ctx.arc(cx, cy, r, start, end, false)
                ctx.stroke()
            }

            ctx.globalAlpha = 1.0
        }

        Connections {
            target: root
            function onUsedFracChanged() { ring.requestPaint() }
            function onRingWidthChanged() { ring.requestPaint() }
            function onRingInsetChanged() { ring.requestPaint() }
        }
    }

    // ---------- CENTER CONTENT (ICON -> TEMP ON HOVER) ----------
    Item {
        id: center
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        property real swap: root.hovered ? 1.0 : 0.0
        Behavior on swap { NumberAnimation { duration: Services.Theme.animDurationVerySlow; easing.type: Easing.OutCubic } }

        Text {
            id: iconText
            anchors.centerIn: parent
            text: ""
            font.family: Services.Theme.fontFamilyMono
            font.pixelSize: Services.Theme.iconSizeSmall
            color: root.iconColor
            opacity: Services.Theme.opacityNormal * (1.0 - center.swap)

            transform: [
                Translate { y: -3 * center.swap },
                Scale {
                    origin.x: iconText.width / 2
                    origin.y: iconText.height / 2
                    xScale: 1.0 - 0.08 * center.swap
                    yScale: 1.0 - 0.08 * center.swap
                }
            ]
        }

        Text {
            id: tempText
            anchors.centerIn: parent
            anchors.verticalCenterOffset: root.tempYOffset
            text: root.tempRounded + "°"
            color: root.iconColor
            font.pixelSize: Services.Theme.fontSizeMedium - 1
            font.weight: Services.Theme.fontWeightBold
            font.family: Services.Theme.fontFamily
            renderType: Text.NativeRendering

            opacity: center.swap
            transform: [
                Translate { y: 3 * (1.0 - center.swap) },
                Scale {
                    origin.x: tempText.width / 2
                    origin.y: tempText.height / 2
                    xScale: 0.92 + 0.08 * center.swap
                    yScale: 0.92 + 0.08 * center.swap
                }
            ]
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
        onClicked: root.onActivate()
    }
}
