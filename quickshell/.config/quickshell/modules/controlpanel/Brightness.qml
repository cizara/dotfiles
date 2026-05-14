import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import qs.services as Services

import "../../services" as ServicesUI   // StyledSlider.qml lives in /services

Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: 56

    // ---- colors (match your volume palette) ----
    property color textColor: Services.Theme.colorText
    property color colPrimary: Services.Theme.colorAccent
    property color colSecondaryContainer: Services.Theme.colorSurface1
    property color handleBorderColor: Services.Theme.colorSurface0
    property int handleBorderWidth: 1

    // ---- slider geometry ----
    property real trackHeightDiff: 15
    property real handleGap: 6
    property real trackNearHandleRadius: 2
    property bool useAnim: true

    // UI state
    property int uiValue: 0
    property bool dragging: false

    function clamp(n, lo, hi) { return Math.max(lo, Math.min(hi, n)) }
    function brightToUi(b) { return clamp(Math.round(clamp(b, 0.0, 1.0) * 100), 0, 100) }
    function uiToBright(u) { return clamp(u, 0, 100) / 100.0 }

    function currentMonitor() {
        const name = Hyprland.focusedMonitor?.name
        if (!name || !Services.Brightness?.monitors) return null
        // Services.Brightness.monitors is a list<BrightnessMonitor> with screen.name
        for (let i = 0; i < Services.Brightness.monitors.length; i++) {
            const m = Services.Brightness.monitors[i]
            if (m?.screen?.name === name) return m
        }
        return null
    }

    function syncFromService() {
        if (dragging) return
        const m = currentMonitor()
        if (!m || !m.ready) return
        // use multipliedBrightness so the UI matches what you actually see
        uiValue = brightToUi(m.multipliedBrightness)
    }

    // keep it updated (focused monitor can change)
    Timer {
        interval: 200
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.syncFromService()
    }

    // small grace period so sync doesn't instantly fight a release
    Timer {
        id: releaseTimer
        interval: 150
        repeat: false
        onTriggered: root.dragging = false
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Services.Theme.spacingSmall

        RowLayout {
            Layout.fillWidth: true
            spacing: Services.Theme.spacingLarge

            Text {
                text: "󰃠  Brightness"
                font.family: Services.Theme.fontFamilyMono
                font.pixelSize: Services.Theme.fontSizeNormal
                color: root.textColor
                opacity: Services.Theme.opacityNormal
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Text {
                text: root.uiValue + "%"
                font.pixelSize: Services.Theme.fontSizeNormal
                color: root.textColor
                opacity: Services.Theme.opacityNormal
                Layout.alignment: Qt.AlignVCenter
            }
        }

        ServicesUI.StyledSlider {
            id: slider
            Layout.fillWidth: true
            implicitHeight: 35

            from: 0
            to: 100
            stepSize: 1
            snapMode: Slider.SnapAlways

            colPrimary: root.colPrimary
            colSecondaryContainer: root.colSecondaryContainer
            handleBorderColor: root.handleBorderColor
            handleBorderWidth: root.handleBorderWidth
            trackHeightDiff: root.trackHeightDiff
            handleGap: root.handleGap
            trackNearHandleRadius: root.trackNearHandleRadius
            useAnim: root.useAnim

            // IMPORTANT: don't bind value directly while dragging
            onUserMoved: (v) => {
                root.dragging = true
                root.uiValue = Math.round(v)

                const m = root.currentMonitor()
                if (m && m.ready) m.setBrightness(root.uiToBright(root.uiValue))
            }

            onUserReleased: (v) => {
                root.uiValue = Math.round(v)

                const m = root.currentMonitor()
                if (m && m.ready) m.setBrightness(root.uiToBright(root.uiValue))

                releaseTimer.restart()
            }
        }

        // keep slider following uiValue only when not dragging
        Binding {
            target: slider
            property: "value"
            value: root.uiValue
            when: !root.dragging
        }
    }
}
