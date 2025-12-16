import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

// Wallpaper service using swaybg for better Hyprland compatibility
Item {
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
    
    // Watch for reload signal file
    property string signalFile: Quickshell.env("HOME") + "/.cache/quickshell-reload-wallpaper"
    property string lastModTime: ""
    
    Timer {
        interval: 500  // Check every 500ms
        running: true
        repeat: true
        onTriggered: checkSignalFile()
    }
    
    Process {
        id: statProc
        command: ["stat", "-c", "%Y", signalFile]
        stdout: StdioCollector {
            onStreamFinished: {
                const modTime = text.trim()
                if (modTime.length > 0 && modTime !== lastModTime) {
                    lastModTime = modTime
                    if (lastModTime.length > 0) {  // Skip first check
                        loadRandomWallpaper()
                    }
                }
            }
        }
    }
    
    function checkSignalFile() {
        statProc.running = false
        statProc.running = true
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
