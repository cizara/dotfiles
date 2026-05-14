import Quickshell
import QtQuick
import Quickshell.Io
pragma Singleton

Item {
    id: root
    
    readonly property string players: "spotify,YoutubeMusic,chromium.instance2"
    
    property string albumArtist: ""
    property string artUrl: ""
    property string albumTitle: "No Media"

    property int positionSec: 0
    property int lengthSec: 0
    property bool isPlaying: false

    function formatTime(seconds) {
        const m = Math.floor(seconds / 60)
        const s = Math.floor(seconds % 60)
        return `${m.toString().padStart(2,"0")}:${s.toString().padStart(2,"0")}`
    }

    // Single process that gets ALL metadata at once
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            metadataProc.running = true
        }
    }

    Process {
        id: metadataProc
        command: ["playerctl", "-p", root.players, "metadata", "--format", "{{status}}|{{artist}}|{{title}}|{{mpris:artUrl}}|{{mpris:length}}|{{position}}"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split('|')
                if (parts.length >= 6) {
                    // status
                    root.isPlaying = (parts[0] === "Playing")
                    
                    // artist
                    root.albumArtist = parts[1] || "No Artist"
                    
                    // title
                    root.albumTitle = parts[2] || "No Media"
                    
                    // artUrl
                    root.artUrl = parts[3] || ""
                    
                    // length (microseconds to seconds)
                    const len = parseFloat(parts[4])
                    root.lengthSec = (!isNaN(len)) ? (len / 1000000) : 0
                    
                    // position (microseconds to seconds)
                    const pos = parseFloat(parts[5])
                    root.positionSec = (!isNaN(pos)) ? (pos / 1000000) : 0
                }
            }
        }
    }


    
    Process { id: playPauseProc; command: ["playerctl", "-p", root.players, "play-pause"] }
    
    function playPause() {
        playPauseProc.running = false
        playPauseProc.running = true
    }
}