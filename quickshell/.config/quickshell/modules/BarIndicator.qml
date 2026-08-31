// modules/BarIndicator.qml
//
// A single status glyph for a mode that is either on or off (do-not-disturb,
// stay-awake, ...). Base component: subclasses/instances only supply `active`,
// the glyphs, and what a click does.
//
// Visibility rules, which are the whole point of the design:
//   active                 -> fully opaque, always visible
//   inactive + revealed    -> dimmed, so hovering the cluster shows you the modes
//                             you could turn on, and lets you click one without
//                             knowing its hotkey
//   inactive + not revealed-> zero width, contributing nothing to the bar
pragma ComponentBehavior: Bound

import QtQuick
import qs.services as Services

Item {
    id: root

    property bool active: false
    property string activeText: ""
    property string inactiveText: ""
    // Driven by the containing cluster, not by this item's own hover state: the
    // whole group reveals together.
    property bool revealed: false

    signal triggered

    readonly property string glyph: active ? activeText : inactiveText
    readonly property bool shown: active || revealed

    // Collapsing to zero width (rather than just going transparent) is what keeps
    // an inactive indicator from reserving space in the bar.
    implicitWidth: shown ? Math.ceil(metrics.tightBoundingRect.width) + Services.Theme.spacingNormal : 0
    implicitHeight: Services.Theme.moduleHeight
    clip: true

    opacity: active ? 1 : (revealed ? Services.Theme.opacityDisabled : 0)

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Services.Theme.animDurationNormal
            easing.type: Easing.OutQuad
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: Services.Theme.animDurationNormal
        }
    }

    TextMetrics {
        id: metrics
        font.family: Services.Theme.fontFamily
        font.pixelSize: Services.Theme.fontSizeSmall
        text: root.glyph
    }

    Text {
        anchors.centerIn: parent
        text: root.glyph
        color: root.active ? Services.Theme.colorAccent : Services.Theme.colorSubtext0
        font.family: Services.Theme.fontFamily
        font.pixelSize: Services.Theme.fontSizeSmall
        renderType: Text.NativeRendering
    }

    MouseArea {
        anchors.fill: parent
        // Only clickable once it can actually be seen, so an invisible zero-width
        // indicator can never swallow a click meant for a neighbour.
        enabled: root.shown
        cursorShape: Qt.PointingHandCursor
        onClicked: root.triggered()
    }
}
