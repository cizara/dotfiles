import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.services as Services

Item {
    id: root
    implicitHeight: 28
    implicitWidth: Math.min(510, Math.max(150, contentRow.implicitWidth + 20))
    Layout.preferredWidth: implicitWidth
    Layout.alignment: Qt.AlignVCenter

    // theme
    property color bg: "#313244"
    property color text: "#66cc99"
    property color btnBg: "#313244"
    property color btnHover: "#2f3042"
    property color btnPress: "#2a2b3a"

    // whole-module button feedback
    property color cardHover: "#2f3042"
    property color cardPress: "#2a2b3a"

    readonly property var mpris: Services.Mpris
    readonly property string line: {
        var artist = (mpris && mpris.albumArtist) ? mpris.albumArtist : "No Artist"
        var title = (mpris && mpris.albumTitle) ? mpris.albumTitle : "No Media"
        return artist + " - " + title
    }

    readonly property bool isPlaying: mpris ? mpris.isPlaying : false

    // popup toggle state
    property bool detailsOpen: false

    // click hook (whole card uses this)
    property var onOpen: function() { detailsOpen = !detailsOpen }


    Process { id: playPauseProc; command: ["playerctl", "-p", root.mpris.players, "play-pause"] }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 14
        antialiasing: true
        transformOrigin: Item.Center

        // hover expand + press squish
        scale: cardMouse.pressed ? 0.985 : (cardMouse.containsMouse ? 1.03 : 1.0)

        // color reacts to whole-card mouse, but NOT when clicking play/pause
        color: cardMouse.pressed
               ? root.cardPress
               : (cardMouse.containsMouse ? root.cardHover : root.bg)

        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on scale {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }

        // subtle lift shadow (optional but nice)
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: false
            shadowOpacity: cardMouse.containsMouse ? 0.35 : 0.0
            shadowBlur: 0.9
            shadowVerticalOffset: cardMouse.containsMouse ? 2 : 0
        }

        // Whole-module click target (behind the play/pause button)
        MouseArea {
            id: cardMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            z: 0
            onClicked: root.onOpen()
        }

        RowLayout {
            id: contentRow
            anchors.fill: parent
            anchors.margins: 4
            spacing: 8
            z: 1 // content above the background mousearea

            // play/pause button (should NOT trigger card click)
            Rectangle {
                id: btn
                width: 20
                height: 20
                radius: 20
                color: btnMouse.pressed ? root.btnPress : (btnMouse.containsMouse ? root.btnHover : root.btnBg)
                border.width: 1
                border.color: "#45475a"
                Layout.alignment: Qt.AlignVCenter
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: root.isPlaying ? "󰏤" : "󰐊"
                    font.family: "Hack Nerd Font"
                    font.pixelSize: 14
                    lineHeightMode: Text.FixedHeight
                    lineHeight: btn.height
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    x: Math.round(-0.5)
                    y: root.isPlaying ? Math.round(-0.5) : 0
                    color: root.text
                    opacity: 0.95
                }

                MouseArea {
                    id: btnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    preventStealing: true
                    propagateComposedEvents: false
                    onClicked: {
                        playPauseProc.running = false
                        playPauseProc.running = true
                        statusProc.running = false
                        statusProc.running = true
                    }
                }
            }

            // Simple text with ellipsis (no animation)
            Text {
                id: mediaText
                Layout.maximumWidth: 510 - 4 - 8 - 20 - 8 - 4  // maxWidth - margins - spacing - button - spacing - margins
                Layout.alignment: Qt.AlignVCenter
                text: root.line
                color: root.text
                font.pixelSize: 13
                font.weight: 600
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
    MediaPopup {
        id: mediaPop
        open: root.detailsOpen
        anchorItem: root
        onRequestClose: root.detailsOpen = false
    }
}