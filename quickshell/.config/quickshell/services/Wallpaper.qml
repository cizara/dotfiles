import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

// Wallpaper service using swaybg for better Hyprland compatibility
Item {
    id: root

    property string imagePath: ""
    property var swaybgProcess: null
    
    Component.onCompleted: {
        loadRandomWallpaper()
    }
    
    Timer {
        interval: 300000  // 5 minutes in milliseconds
        running: true
        repeat: true
        onTriggered: loadRandomWallpaper()
    }
    
    // Reroll on request. This replaces polling `stat` on a ~/.cache signal file
    // twice a second, which cost two subprocesses per second for the entire
    // session just to notice a keypress.
    //   qs ipc call wallpaper next
    IpcHandler {
        target: "wallpaper"

        function next(): string {
            root.loadRandomWallpaper()
            return "ok"
        }

        function set(path: string): string {
            if (path.length === 0)
                return "no path given"
            root.imagePath = path
            root.setWallpaper()
            return "ok"
        }

        function current(): string {
            return root.imagePath
        }
    }

    function loadRandomWallpaper() {
        wallpaperProc.running = true
    }
    
    Process {
        id: wallpaperProc
        command: ["bash", "-c", "find " + Quickshell.env("HOME") + "/Pictures/wallpapers/ -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \\) | shuf -n 1"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.trim()
                if (path.length > 0) {
                    imagePath = path
                    setWallpaper()
                }
            }
        }
    }
    
    function setWallpaper() {
        // Kill existing swaybg process
        killProc.running = true
    }
    
    // Kill existing swaybg
    Process {
        id: killProc
        command: ["bash", "-c", "pkill swaybg"]
        onExited: {
            // Start new swaybg with the new wallpaper
            startSwaybg()
        }
    }
    
    function startSwaybg() {
        swaybgProc.running = true
    }
    
    // Start swaybg with wallpaper
    Process {
        id: swaybgProc
        running: false
        command: ["swaybg", "-i", imagePath, "-m", "fill"]
    }
}
