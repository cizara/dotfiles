import QtQuick
import QtQuick.Controls
import Quickshell.Services.Pipewire
import qs.services as Services

Popup {
    id: pop

    opacity: 0

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Services.Theme.animDurationMedium; easing.type: Easing.OutCubic }
    }

    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Services.Theme.animDurationNormal; easing.type: Easing.OutCubic }
    }

    // ===== config =====
    property int minWidth: 280
    property int maxWidth: 320
    property int maxListHeight: 240
    property int edgeMargin: Services.Theme.paddingNormal

    // theme
    property color bg: Services.Theme.colorMantle
    property color border: Services.Theme.colorSurface1
    property color hover: Services.Theme.colorSurface0
    property color text: Services.Theme.colorText
    property color subtext: Services.Theme.colorSubtext0
    property color accent: Services.Theme.colorAccent

    // internal
    property Item boundsItem: null

    padding: 10
    width: minWidth
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    readonly property real contentW: pop.width - pop.leftPadding - pop.rightPadding

    ListModel { id: sinkModel }

    TextMetrics {
        id: metrics
        font.pixelSize: Services.Theme.fontSizeSmall
    }

    function clamp(n, lo, hi) { return Math.max(lo, Math.min(hi, n)) }

    function nodeLabel(n) {
        if (!n) return "Unknown"
        return String(n.description || n.nick || n.name || n.id || "Unknown")
    }

    function isSink(n) {
        const t = String(PwNodeType.toString?.(n.type) || PwNodeType[n.type])
        return t === "AudioSink"
    }

    function rebuild() {
        sinkModel.clear()
        const sinks = Services.Volume.devices.filter(isSink)
        for (let i = 0; i < sinks.length; i++) {
            const n = sinks[i]
            sinkModel.append({ label: nodeLabel(n), node: n })
        }
        computeWidth()
    }

    function computeWidth() {
        // padding + delegate inner padding + dot + checkmark + spacing
        const chrome =
            (pop.leftPadding + pop.rightPadding) +
            (12 * 2) +    // delegate left/right padding
            8 + 10 +      // dot + spacing
            18 + 12       // checkmark + breathing room

        var w = pop.minWidth
        for (let i = 0; i < sinkModel.count; i++) {
            metrics.text = sinkModel.get(i).label
            w = Math.max(w, Math.ceil(metrics.width + chrome))
        }
        pop.width = clamp(w, pop.minWidth, pop.maxWidth)
    }

    function positionFrom(anchorItem) {
        if (!anchorItem || !pop.parent) return

        // anchor coords in popup parent coords
        var p = anchorItem.mapToItem(pop.parent, 0, anchorItem.height)

        // right align under anchor
        var desiredX = Math.round(p.x + anchorItem.width - pop.width)

        // clamp inside parent width
        var minX = pop.edgeMargin
        var maxX = Math.max(minX, Math.round(pop.parent.width - pop.width - pop.edgeMargin))
        pop.x = clamp(desiredX, minX, maxX)

        pop.y = Math.round(p.y + 6)
    }

    // ✅ Call this from Volume.qml:
    // audioMenu.openFrom(deviceBtn, root)
    function openFrom(anchorItem, bounds) {
        pop.boundsItem = bounds || anchorItem
        pop.parent = pop.boundsItem

        rebuild()
        positionFrom(anchorItem)
        pop.open()
    }

    background: Rectangle {
        radius: Services.Theme.moduleRadius
        color: pop.bg
        border.width: 1
        border.color: pop.border
    }

    // also works if you just call pop.open()
    onAboutToShow: rebuild()

    Column {
        width: pop.contentW
        spacing: Services.Theme.spacingMedium

        Text {
            text: "Audio Output"
            color: pop.text
            opacity: Services.Theme.opacityNormal
            font.pixelSize: Services.Theme.fontSizeSmall
        }

        Rectangle {
            width: parent.width
            height: 1
            radius: 1
            color: Services.Theme.colorSurface0
            opacity: Services.Theme.opacityNormal
        }

        ListView {
            id: list
            width: parent.width
            implicitHeight: Math.min(pop.maxListHeight, contentHeight)
            clip: true
            spacing: Services.Theme.spacingNormal
            model: sinkModel

            delegate: Rectangle {
                id: row
                required property string label
                required property var node

                width: list.width
                height: 38
                radius: Services.Theme.paddingLarge
                color: hoverArea.containsMouse ? pop.hover : "transparent"

                readonly property bool current: (
                    Services.Volume.defaultSpeaker && node
                    && Services.Volume.defaultSpeaker.id === node.id
                )

                // inner padding
                property int pad: 12

                Rectangle {
                    id: dot
                    width: 8
                    height: 8
                    radius: 4
                    color: row.current ? pop.accent : Services.Theme.colorSurface2
                    opacity: row.current ? Services.Theme.opacityFull : Services.Theme.opacitySubtle
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: row.pad
                }

                Text {
                    id: labelText
                    text: row.label
                    color: pop.text
                    font.pixelSize: Services.Theme.fontSizeSmall
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: dot.right
                    anchors.leftMargin: 10
                    anchors.right: check.left
                    anchors.rightMargin: 10
                }

                Text {
                    id: check
                    text: row.current ? "✓" : ""
                    color: pop.text
                    opacity: Services.Theme.opacityNormal
                    font.pixelSize: Services.Theme.fontSizeNormal
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: row.pad
                }

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (row.node) Services.Volume.setDefaultSpeaker(row.node)
                        pop.close()
                    }
                }
            }
        }

        Text {
            visible: sinkModel.count === 0
            text: "No outputs found"
            color: pop.subtext
            font.pixelSize: Services.Theme.fontSizeSmall
            opacity: Services.Theme.opacityNormal
        }
    }
}
