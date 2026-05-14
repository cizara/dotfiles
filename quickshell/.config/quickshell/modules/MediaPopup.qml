import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets
import qs.services as Services

PopupWindow {
    id: pop

    property bool open: false
    property Item anchorItem: null
    signal requestClose()
    readonly property var m: Services.Mpris

    color: "transparent"

    // --- theme ---
    property int cardRadius: 16
    property color cardColor: "#181825"

    // --- shadow (small + clean corners) ---
    property int shadowPad: 10
    property real shadowOpacity: 0.28
    property real shadowBlur: 0.55
    property int shadowOffsetY: 6

    // keep your original content size
    property int contentW: 350
    property int contentH: 96

    // window gets padding so shadow won't clip
    implicitWidth: contentW + shadowPad * 2
    implicitHeight: contentH + shadowPad * 2

    // keep visible while closing animation plays
    property bool closing: false
    visible: (open && anchorItem !== null) || closing

    // --- open/close animation state ---
    property real animY: 0
    property real animScale: 1
    property real animOpacity: 1

    function playOpenAnim() {
        // Snap to current MPRIS position immediately
        if (m) {
            basePositionSec = m.positionSec
            lastUpdateMs = Date.now()
        }
        closing = false
        animY = -14
        animScale = 0.975
        animOpacity = 0
        openAnim.restart()
    }

    function playCloseAnim() {
        if (closing) return
        closing = true

        // IMPORTANT: tell parent to flip open=false immediately (prevents 1-frame flicker)
        requestClose()

        // stop focus grab so it doesn't re-trigger during close
        focusGrab.active = false

        // cancel any in-progress open animation
        openAnim.stop()

        closeAnim.restart()
    }

    onVisibleChanged: {
        if (visible && open) playOpenAnim()
    }

    onOpenChanged: {
        // if parent toggles open=false, animate out (don't vanish instantly)
        if (!open && visible && !closing) playCloseAnim()
    }

    // ✅ REAL click-outside: fullscreen backdrop window behind the popup
    LazyLoader {
        id: backdropLoader
        activeAsync: pop.open || pop.closing

        PanelWindow {
            id: backdrop
            color: "transparent"
            visible: true
            exclusiveZone: -1
            anchors { top: true; bottom: true; left: true; right: true }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                hoverEnabled: true
                onPressed: pop.playCloseAnim()
            }
        }
    }

    // Click outside to close (Hyprland) - keep as extra fallback
    HyprlandFocusGrab {
        id: focusGrab
        windows: [ pop ]
        active: pop.visible && !pop.closing
        onCleared: pop.playCloseAnim()
    }

    // --- bounce IN ---
    ParallelAnimation {
        id: openAnim

        SequentialAnimation {
            NumberAnimation { target: pop; property: "animY"; from: -14; to: 3; duration: 140; easing.type: Easing.OutCubic }
            NumberAnimation { target: pop; property: "animY"; from: 3; to: 0; duration: 170; easing.type: Easing.OutBack; easing.overshoot: 1.35 }
        }

        SequentialAnimation {
            NumberAnimation { target: pop; property: "animScale"; from: 0.975; to: 1.03; duration: 140; easing.type: Easing.OutCubic }
            NumberAnimation { target: pop; property: "animScale"; from: 1.03; to: 1.0; duration: 190; easing.type: Easing.OutBack; easing.overshoot: 1.25 }
        }

        NumberAnimation { target: pop; property: "animOpacity"; from: 0; to: 1; duration: 160; easing.type: Easing.OutCubic }
    }

    // --- bounce OUT ---
    ParallelAnimation {
        id: closeAnim

        SequentialAnimation {
            NumberAnimation { target: pop; property: "animY"; from: 0; to: 2; duration: 70; easing.type: Easing.OutCubic }
            NumberAnimation { target: pop; property: "animY"; from: 2; to: -10; duration: 140; easing.type: Easing.InCubic }
        }

        NumberAnimation { target: pop; property: "animScale"; from: 1.0; to: 0.98; duration: 170; easing.type: Easing.InCubic }
        NumberAnimation { target: pop; property: "animOpacity"; from: 1; to: 0; duration: 150; easing.type: Easing.InCubic }

        onStopped: pop.closing = false
    }

    // ---- centered-under-button anchoring ----
    anchor.item: anchorItem
    Connections {
        target: pop.anchor
        function onAnchoring() {
            if (!pop.anchorItem) return
            pop.anchor.rect.x = Math.round(pop.anchorItem.width / 2 - pop.width / 2)
            // subtract shadowPad so the *card* starts at +8 (not the padded window)
            pop.anchor.rect.y = Math.round(pop.anchorItem.height + 8 - pop.shadowPad)
            pop.anchor.rect.width = 1
            pop.anchor.rect.height = 1
        }
    }

    // --- use Mpris service playing state ---
    readonly property bool isPlaying: m ? m.isPlaying : false

    Process { id: prevProc; command: ["playerctl", "-p", pop.m.players, "previous"] }
    Process { id: nextProc; command: ["playerctl", "-p", pop.m.players, "next"] }
    Process { id: seekProc }

    // --- repeat state ---
    property string loopMode: "None" // "None" | "Playlist" | "Track"
    Process { id: loopSetProc }

    Process {
        id: loopGetProc
        command: ["bash", "-lc", `playerctl -p '${pop.m.players}' loop 2>/dev/null || echo None`]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = text.trim()
                pop.loopMode = (v === "Track" || v === "Playlist" || v === "None") ? v : "None"
            }
        }
    }

    function cycleLoop() {
        const next = (loopMode === "None") ? "Playlist"
                   : (loopMode === "Playlist") ? "Track"
                   : "None"
        loopMode = next // optimistic UI
        loopSetProc.command = ["playerctl", "-p", pop.m.players, "loop", next]
        loopSetProc.running = false
        loopSetProc.running = true
        loopGetProc.running = false
        loopGetProc.running = true
    }

    Timer {
        interval: 5000
        repeat: true
        running: pop.visible
        triggeredOnStart: true
        onTriggered: { loopGetProc.running = false; loopGetProc.running = true }
    }

    // --- seek smoothing (prevents snap-back) ---
    property bool dragging: false
    property real dragFrac: 0.0

    property bool seekPending: false
    property real pendingSec: 0

    Timer {
        id: pendingTimer
        interval: 1500
        repeat: false
        onTriggered: pop.seekPending = false
    }

    // --- smooth position tracking (MPRIS is truth, we just interpolate) ---
    property real basePositionSec: 0
    property real lastUpdateMs: 0
    property int uiUpdateTick: 0  // Dummy property to trigger UI updates

    // Calculate live position with smooth interpolation
    function liveSec() {
        uiUpdateTick  // Reference to make this reactive
        if (!m || !isPlaying || dragging || seekPending) return basePositionSec
        const elapsed = (Date.now() - lastUpdateMs) / 1000
        const interpolated = basePositionSec + elapsed
        return (m.lengthSec > 0) ? Math.min(interpolated, m.lengthSec) : interpolated
    }

    // Timer to trigger UI updates for smooth display (doesn't own time)
    Timer {
        interval: 100  // Update display 10 times per second for smooth animation
        running: pop.visible && pop.isPlaying && !pop.dragging && !pop.seekPending
        repeat: true
        onTriggered: {
            // Trigger UI refresh by changing dummy property
            pop.uiUpdateTick++
        }
    }

    Component.onCompleted: {
        if (m) {
            basePositionSec = m.positionSec
            lastUpdateMs = Date.now()
        }
    }

    Connections {
        target: pop.m
        enabled: pop.m !== null && pop.m !== undefined
        function onPositionSecChanged() {
            // MPRIS updated - sync our base position
            if (pop.m && !pop.dragging && !pop.seekPending) {
                pop.basePositionSec = pop.m.positionSec
                pop.lastUpdateMs = Date.now()
            }
            
            // Check if seek completed
            if (pop.seekPending && pop.m) {
                if (Math.abs(pop.m.positionSec - pop.pendingSec) <= 1.5) {
                    pop.seekPending = false
                    pendingTimer.stop()
                }
            }
        }
    }

    function clamp01(x) { return Math.max(0, Math.min(1, x)) }

    function liveFrac() {
        if (!m || m.lengthSec <= 0) return 0
        return clamp01(liveSec() / m.lengthSec)
    }

    function displayedFrac() {
        if (dragging) return dragFrac
        if (seekPending && m && m.lengthSec > 0) return clamp01(pendingSec / m.lengthSec)
        return liveFrac()
    }

    function seekToFrac(f) {
        if (!m || m.lengthSec <= 0) return
        const sec = Math.max(0, Math.min(m.lengthSec, Math.round(f * m.lengthSec)))

        pendingSec = sec
        seekPending = true
        pendingTimer.restart()

        seekProc.command = ["playerctl", "-p", pop.m.players, "position", String(sec)]
        seekProc.running = false
        seekProc.running = true
    }

    // --- title marquee state ---
    property bool titleNeedsMarquee: false
    property int titleFadeW: 12

    // --- time formatting fallback ---
    function formatTimeFallback(seconds) {
        if (!seconds || seconds < 0) return "0:00"
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }

    // --- micro-interaction helper (scale for buttons/icons) ---
    component TapArea : MouseArea {
        id: tap
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        property Item targetItem
        property real hoverScale: 1.08
        property real pressScale: 0.92

        onPressedChanged: {
            if (!targetItem) return
            targetItem.scale = pressed ? pressScale : (containsMouse ? hoverScale : 1.0)
        }
        onContainsMouseChanged: {
            if (!targetItem || pressed) return
            targetItem.scale = containsMouse ? hoverScale : 1.0
        }
    }

    // animate the whole card (shadow + clip move together)
    Item {
        id: animWrap
        anchors.fill: parent
        anchors.margins: pop.shadowPad

        y: pop.animY
        scale: pop.animScale
        opacity: pop.animOpacity
        transformOrigin: Item.Top

        // Shadow + background (NO clip here)
        Rectangle {
            id: card
            anchors.fill: parent
            radius: pop.cardRadius
            antialiasing: true
            color: pop.cardColor
            border.width: 0

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: false
                shadowOpacity: pop.shadowOpacity
                shadowVerticalOffset: pop.shadowOffsetY
                shadowBlur: pop.shadowBlur
            }
        }

        // Content clip (rounded corners stay perfect)
        Rectangle {
            id: clipper
            anchors.fill: parent
            radius: pop.cardRadius
            color: "transparent"
            clip: true
            antialiasing: true

            // IMPORTANT: do NOT close on inside clicks.
            // This just eats clicks on empty card areas so they don't "fall through" to the backdrop.
            MouseArea {
                anchors.fill: parent
                z: 0
                acceptedButtons: Qt.AllButtons
                hoverEnabled: true
                propagateComposedEvents: false
                onPressed: mouse.accepted = true
                onClicked: mouse.accepted = true
            }

            RowLayout {
                z: 1
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12

                Item {
                    implicitWidth: 75
                    implicitHeight: 75
                    Layout.alignment: Qt.AlignVCenter

                    ClippingRectangle {
                        anchors.centerIn: parent
                        width: 75
                        height: 75
                        radius: 10
                        antialiasing: true
                        layer.enabled: true
                        layer.smooth: true

                        Rectangle { anchors.fill: parent; color: "#11111b" }

                        Image {
                            anchors.fill: parent
                            source: (m && m.artUrl) ? m.artUrl : ""
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            mipmap: true
                            visible: (m && m.artUrl && m.artUrl.length > 0)
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4

                    Item {
                        Layout.fillWidth: true
                        height: 18

                        Item {
                            id: titleViewport
                            anchors.left: parent.left
                            anchors.right: repeatBtn.left
                            anchors.rightMargin: 8
                            height: 18
                            clip: true

                            Row {
                                id: titleRow
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 22
                                x: 0

                                Text {
                                    id: titleA
                                    text: (m && m.albumTitle) ? m.albumTitle : "No Media"
                                    color: "#f1f5ff"
                                    font.pixelSize: 15
                                    font.weight: 700
                                    elide: Text.ElideNone
                                }

                                Text {
                                    id: titleB
                                    text: titleA.text
                                    color: "#f1f5ff"
                                    font.pixelSize: 15
                                    font.weight: 700
                                    elide: Text.ElideNone
                                    visible: pop.titleNeedsMarquee
                                }
                            }

                            Item {
                                z: 10
                                visible: pop.titleNeedsMarquee
                                width: pop.titleFadeW
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                clip: true
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.height
                                    height: parent.width
                                    rotation: -90
                                    transformOrigin: Item.Center
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: pop.cardColor }
                                        GradientStop { position: 1.0; color: "transparent" }
                                    }
                                }
                            }

                            Item {
                                z: 10
                                visible: pop.titleNeedsMarquee
                                width: pop.titleFadeW
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                clip: true
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.height
                                    height: parent.width
                                    rotation: -90
                                    transformOrigin: Item.Center
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "transparent" }
                                        GradientStop { position: 1.0; color: pop.cardColor }
                                    }
                                }
                            }

                            Timer {
                                id: titleDelay
                                interval: 900
                                repeat: false
                                onTriggered: { if (pop.titleNeedsMarquee) titleAnim.start() }
                            }

                            function recompute(reset) {
                                const usable = Math.max(0, titleViewport.width - pop.titleFadeW * 2)
                                pop.titleNeedsMarquee = (titleA.paintedWidth > usable)

                                titleAnim.stop()
                                titleDelay.stop()

                                if (reset || !pop.titleNeedsMarquee) titleRow.x = 0
                                // Only start marquee if text overflows AND popup is visible AND media is playing
                                if (pop.titleNeedsMarquee && pop.visible && pop.isPlaying) {
                                    titleAnim.from = 0
                                    titleAnim.to = -(titleA.paintedWidth + titleRow.spacing)
                                    titleDelay.start()
                                }
                            }

                            onWidthChanged: recompute(false)
                            Component.onCompleted: recompute(true)

                            Connections {
                                target: pop.m
                                enabled: pop.m !== null && pop.m !== undefined
                                function onAlbumTitleChanged() { titleViewport.recompute(true) }
                                function onIsPlayingChanged()  { titleViewport.recompute(false) }
                            }

                            Connections {
                                target: pop
                                function onVisibleChanged() { titleViewport.recompute(false) }
                            }

                            NumberAnimation {
                                id: titleAnim
                                target: titleRow
                                property: "x"
                                from: 0
                                to: -(titleA.paintedWidth + titleRow.spacing)
                                duration: Math.max(11000, titleA.paintedWidth * 20)
                                loops: Animation.Infinite
                                easing.type: Easing.Linear
                                running: false
                            }
                        }

                        Rectangle {
                            id: repeatBtn
                            width: 24
                            height: 24
                            radius: 8
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            z: 2

                            color: repeatTap.pressed ? "#2a2b3a"
                                 : (repeatTap.containsMouse ? "#2f3042" : "transparent")

                            border.width: (pop.loopMode === "None") ? 0 : 1
                            border.color: "#45475a"
                            Behavior on color { ColorAnimation { duration: 120 } }

                            transformOrigin: Item.Center
                            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                            Text {
                                anchors.centerIn: parent
                                font.family: "Hack Nerd Font"
                                font.pixelSize: 15
                                text: (pop.loopMode === "Track") ? "󰑘" : "󰑖"
                                color: "#f1f5ff"
                                opacity: (pop.loopMode === "None") ? 0.45 : 0.95
                            }

                            TapArea {
                                id: repeatTap
                                anchors.fill: parent
                                targetItem: repeatBtn
                                onClicked: pop.cycleLoop()
                            }
                        }
                    }

                    Text {
                        text: (m && m.albumArtist) ? m.albumArtist : "No Artist"
                        color: "#cdd6f4"
                        opacity: 0.9
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Item {
                        id: bar
                        Layout.fillWidth: true
                        height: 12

                        readonly property int pad: 6
                        readonly property real f: pop.displayedFrac()
                        readonly property real usableW: Math.max(1, width - pad * 2)
                        readonly property real lengthSec: (pop.m && pop.m.lengthSec) ? pop.m.lengthSec : 0

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            x: bar.pad
                            width: bar.usableW
                            height: 4
                            radius: 2
                            color: "#313244"
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            x: bar.pad
                            width: Math.max(6, bar.usableW * bar.f)
                            height: 4
                            radius: 2
                            color: "#b4befe"
                        }

                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: "#f1f5ff"
                            anchors.verticalCenter: parent.verticalCenter
                            x: Math.max(
                                   bar.pad,
                                   Math.min(
                                       bar.pad + bar.usableW - width,
                                       bar.pad + bar.usableW * bar.f - width / 2
                                   )
                               )
                            opacity: bar.lengthSec > 0 ? 0.9 : 0.25
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: bar.lengthSec > 0

                            function updateDrag(mx) { pop.dragFrac = pop.clamp01((mx - bar.pad) / bar.usableW) }

                            onPressed: { pop.dragging = true; updateDrag(mouse.x) }
                            onPositionChanged: { if (pop.dragging) updateDrag(mouse.x) }
                            onReleased: {
                                updateDrag(mouse.x)
                                pop.dragging = false
                                pop.seekToFrac(pop.dragFrac)
                            }
                            onCanceled: pop.dragging = false
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        height: 18

                        RowLayout {
                            anchors.fill: parent
                            spacing: 10

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                text: {
                                    if (!pop.m) return "0:00"
                                    var sec = pop.dragging ? (pop.dragFrac * (pop.m.lengthSec || 0))
                                                 : (pop.seekPending ? pop.pendingSec : pop.liveSec())
                                    return pop.m.formatTime ? pop.m.formatTime(sec) : formatTimeFallback(sec)
                                }
                                color: "#cdd6f4"
                                opacity: 0.85
                                font.pixelSize: 11
                            }

                            Item { Layout.fillWidth: true }

                            RowLayout {
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 16

                                Item {
                                    width: 18; height: 18
                                    Layout.alignment: Qt.AlignVCenter
                                    Text {
                                        id: prevIcon
                                        anchors.centerIn: parent
                                        text: "󰒮"
                                        font.family: "Hack Nerd Font"
                                        font.pixelSize: 16
                                        color: "#f1f5ff"
                                        opacity: 0.9
                                        transformOrigin: Item.Center
                                        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                                    }
                                    TapArea {
                                        anchors.fill: parent
                                        targetItem: prevIcon
                                        onClicked: { prevProc.running = false; prevProc.running = true }
                                    }
                                }

                                Item {
                                    width: 20; height: 18
                                    Layout.alignment: Qt.AlignVCenter
                                    Text {
                                        id: playIcon
                                        anchors.centerIn: parent
                                        text: pop.isPlaying ? "󰏤" : "󰐊"
                                        font.family: "Hack Nerd Font"
                                        font.pixelSize: 18
                                        color: "#f1f5ff"
                                        opacity: 0.95
                                        transformOrigin: Item.Center
                                        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                                    }
                                    TapArea {
                                        anchors.fill: parent
                                        targetItem: playIcon
                                        onClicked: {
                                            if (pop.m && pop.m.playPause) pop.m.playPause()
                                        }
                                    }
                                }

                                Item {
                                    width: 18; height: 18
                                    Layout.alignment: Qt.AlignVCenter
                                    Text {
                                        id: nextIcon
                                        anchors.centerIn: parent
                                        text: "󰒭"
                                        font.family: "Hack Nerd Font"
                                        font.pixelSize: 16
                                        color: "#f1f5ff"
                                        opacity: 0.9
                                        transformOrigin: Item.Center
                                        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                                    }
                                    TapArea {
                                        anchors.fill: parent
                                        targetItem: nextIcon
                                        onClicked: { nextProc.running = false; nextProc.running = true }
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                text: {
                                    if (!pop.m) return "0:00"
                                    var sec = pop.m.lengthSec || 0
                                    return pop.m.formatTime ? pop.m.formatTime(sec) : formatTimeFallback(sec)
                                }
                                color: "#cdd6f4"
                                opacity: 0.85
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }
        }
    }
}