import QtQuick
import Quickshell
import qs.services as Services

Item {
    id: root
    implicitWidth: Services.Theme.moduleHeight
    implicitHeight: Services.Theme.moduleHeight
    z: 110

    readonly property var memoryService: Services.Memory

    // theme
    property color ringBg: Services.Theme.colorRingBg
    property color ringFg: {
        if (percent < 80) return Services.Theme.colorRingFgLow
        if (percent < 90) return Services.Theme.colorRingFgMedium
        return Services.Theme.colorRingFgHigh
    }
    property color iconColor: Services.Theme.colorText

    // slideout theme
    property color tipBg: Services.Theme.colorWhite
    property color tipText: Services.Theme.colorBlack

    // ring tuning
    property int ringWidth: Services.Theme.ringWidth
    property real ringInset: Services.Theme.ringInset

    // data from service
    readonly property real usedFrac: memoryService.usedFrac
    readonly property real usedGiB: memoryService.usedGiB
    readonly property real totalGiB: memoryService.totalGiB
    readonly property int percent: memoryService.percent

    // optional click hook
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
        renderTarget: Canvas.FramebufferObject

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Component.onCompleted: requestPaint()

        onPaint: {
            const ctx = getContext("2d")

            const w = width
            const h = height
            if (w <= 0 || h <= 0) return

            ctx.clearRect(0, 0, w, h)

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

    // center icon
    Text {
        anchors.centerIn: parent
        text: "󰍛"
        font.family: Services.Theme.fontFamilyMono
        font.pixelSize: Services.Theme.iconSizeSmall
        color: root.iconColor
        opacity: Services.Theme.opacityFull
    }

    // ---------- SLIDEOUT TIP (RIGHT SIDE, NO FLICKER) ----------
    Rectangle {
        id: tipWrap
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.right
        z: 10000

        property int gap: Services.Theme.tooltipGap
        property int hiddenOffset: Services.Theme.tooltipHiddenOffset
        property int minClosedWidth: Services.Theme.tooltipMinClosedWidth

        anchors.leftMargin: root.hovered ? gap : (gap - hiddenOffset)

        width: root.hovered ? tipTextItem.implicitWidth + Services.Theme.paddingContent : minClosedWidth
        height: Services.Theme.pillHeight
        radius: Services.Theme.pillRadius
        color: root.tipBg
        border.width: 1
        border.color: Services.Theme.colorSurface1
        antialiasing: true
        clip: true

        Behavior on anchors.leftMargin { NumberAnimation { duration: Services.Theme.animDurationSlow; easing.type: Easing.OutCubic } }
        Behavior on width              { NumberAnimation { duration: Services.Theme.animDurationSlow; easing.type: Easing.OutCubic } }

        Text {
            id: tipTextItem
            anchors.centerIn: parent

            text: "Mem: " + root.percent + "% - " + root.usedGiB.toFixed(1) + "GiB Used"
            color: root.tipText
            font.pixelSize: Services.Theme.fontSizeNormal
            font.weight: Services.Theme.fontWeightBold
            font.family: Services.Theme.fontFamily
            elide: Text.ElideRight
            visible: root.hovered
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