import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.services as Services

Popup {
    id: menu
    width: 340
    modal: false
    focus: true
    padding: Services.Theme.paddingNormal
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // Theme
    property color bg: Services.Theme.colorMantle
    property color border: Services.Theme.colorSurface0
    property color text: Services.Theme.colorText
    property color subtext: Services.Theme.colorSubtext0
    property color btnBg: Services.Theme.colorSurface0
    property color btnHover: Services.Theme.colorButtonHover
    property color btnPress: Services.Theme.colorButtonPress

    property string statusText: ""
    property bool busy: false

    // device row fields:
    // name, mac, connected, paired, trusted
    ListModel { id: devModel }

    function openFrom(anchorItem, relativeItem) {
        menu.open()
        Qt.callLater(function() {
            const p = menu.parent ? menu.parent : (relativeItem || anchorItem)
            if (!p) return

            const anchor = anchorItem.mapToItem(p, anchorItem.width/2, anchorItem.height)
            menu.x = Math.round(anchor.x - menu.width/2)
            menu.y = Math.round(anchor.y + 8)

            if (p.width) menu.x = Math.max(6, Math.min(menu.x, Math.round(p.width - menu.width - 6)))
        })
    }

    function refresh() {
        statusText = ""
        devModel.clear()
        listProc.running = false
        listProc.running = true
    }

    function runBt(cmd) {
        // one-at-a-time to keep things sane
        busy = true
        statusText = "Working…"
        actionProc.command = ["bash", "-lc", cmd + " 2>/dev/null || true"]
        actionProc.running = false
        actionProc.running = true
    }

    function connectFlow(mac, paired, connected) {
        if (!mac || busy) return

        if (connected) {
            runBt("bluetoothctl disconnect " + mac)
            return
        }

        // If paired: connect
        if (paired) {
            runBt("bluetoothctl connect " + mac)
            return
        }

        // If not paired: pair + trust + connect (best-effort)
        runBt([
            "bluetoothctl pair " + mac,
            "bluetoothctl trust " + mac,
            "bluetoothctl connect " + mac
        ].join(" && "))
    }

    // List devices and their properties
    Process {
        id: listProc
        command: ["bash", "-lc",
            // Get paired devices list first; then for each, pull info (Connected/Paired/Trusted/Name)
            "bluetoothctl devices paired | awk '{print $2}' | while read mac; do " +
            "  info=$(bluetoothctl info $mac); " +
            "  name=$(echo \"$info\" | sed -n 's/^\\s*Name: //p' | head -n1); " +
            "  conn=$(echo \"$info\" | grep -q \"Connected: yes\" && echo yes || echo no); " +
            "  pair=$(echo \"$info\" | grep -q \"Paired: yes\" && echo yes || echo no); " +
            "  trust=$(echo \"$info\" | grep -q \"Trusted: yes\" && echo yes || echo no); " +
            "  echo \"$mac\\t${name:-Unknown}\\t$conn\\t$pair\\t$trust\"; " +
            "done"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").map(l => l.trim()).filter(l => l.length > 0)
                for (let i = 0; i < lines.length; i++) {
                    const parts = lines[i].split("\t")
                    const mac = (parts[0] || "").trim()
                    const name = (parts[1] || "Unknown").trim()
                    const connected = (parts[2] || "no").trim() === "yes"
                    const paired = (parts[3] || "no").trim() === "yes"
                    const trusted = (parts[4] || "no").trim() === "yes"

                    if (!mac) continue
                    devModel.append({ mac, name, connected, paired, trusted })
                }
                if (devModel.count === 0) statusText = "No paired devices."
            }
        }
    }

    // Action runner (connect/disconnect/pair)
    Process {
        id: actionProc
        stdout: StdioCollector {
            onStreamFinished: {
                const msg = text.trim()
                // bluetoothctl often prints nothing on success; keep it short
                if (msg) statusText = msg
            }
        }
        onExited: {
            busy = false
            statusText = ""
            refresh()
        }
    }

    onOpened: refresh()

    background: Rectangle {
        radius: Services.Theme.moduleRadius
        color: menu.bg
        border.width: 1
        border.color: menu.border
    }

    contentItem: ColumnLayout {
        spacing: Services.Theme.spacingLarge

        RowLayout {
            Layout.fillWidth: true
            spacing: Services.Theme.spacingMedium

            Text {
                text: "Bluetooth"
                color: menu.text
                font.pixelSize: Services.Theme.fontSizeNormal
                font.weight: Services.Theme.fontWeightExtraBold
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: Services.Theme.pillHeight
                height: Services.Theme.pillHeight
                radius: Services.Theme.spacingLarge
                color: refreshMouse.pressed ? menu.btnPress : (refreshMouse.containsMouse ? menu.btnHover : menu.btnBg)
                border.width: 1
                border.color: Services.Theme.colorSurface1
                Behavior on color { ColorAnimation { duration: Services.Theme.animDurationNormal } }

                Text {
                    anchors.centerIn: parent
                    text: "󰅓"
                    font.family: Services.Theme.fontFamilyMono
                    font.pixelSize: Services.Theme.fontSizeNormal
                    color: menu.text
                    opacity: Services.Theme.opacityNormal
                }

                MouseArea {
                    id: refreshMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: menu.refresh()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            radius: 1
            color: menu.border
            opacity: Services.Theme.opacityNormal
        }

        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: 240
            clip: true
            contentWidth: width
            contentHeight: listCol.implicitHeight

            Column {
                id: listCol
                width: parent.width
                spacing: Services.Theme.spacingNormal

                Repeater {
                    model: devModel

                    Rectangle {
                        width: parent.width
                        height: 44
                        radius: Services.Theme.moduleRadius
                        color: rowMouse.pressed ? menu.btnPress : (rowMouse.containsMouse ? menu.btnHover : menu.btnBg)
                        border.width: 1
                        border.color: Services.Theme.colorSurface1
                        Behavior on color { ColorAnimation { duration: Services.Theme.animDurationNormal } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Services.Theme.spacingLarge
                            spacing: Services.Theme.spacingLarge

                            Text {
                                text: model.connected ? "󰂱" : "󰂯"
                                font.family: Services.Theme.fontFamilyMono
                                font.pixelSize: Services.Theme.iconSizeLarge
                                color: menu.text
                                Layout.alignment: Qt.AlignVCenter
                                opacity: model.connected ? Services.Theme.opacityFull : Services.Theme.opacityNormal
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: -Services.Theme.spacingTiny

                                Text {
                                    text: model.name
                                    color: menu.text
                                    font.pixelSize: Services.Theme.fontSizeSmall
                                    font.weight: model.connected ? Services.Theme.fontWeightExtraBold : Services.Theme.fontWeightBold
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: model.connected ? "Connected" : (model.paired ? "Paired" : "Not paired")
                                    color: menu.subtext
                                    font.pixelSize: Services.Theme.fontSizeSmall
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            Text {
                                text: model.connected ? "Disconnect" : "Connect"
                                color: menu.subtext
                                font.pixelSize: Services.Theme.fontSizeSmall
                                opacity: Services.Theme.opacityNormal
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: !menu.busy
                            onClicked: menu.connectFlow(model.mac, model.paired, model.connected)
                        }
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: menu.statusText
            color: menu.subtext
            font.pixelSize: Services.Theme.fontSizeSmall
            opacity: Services.Theme.opacityNormal
            visible: menu.statusText.length > 0
            elide: Text.ElideRight
        }
    }
}
