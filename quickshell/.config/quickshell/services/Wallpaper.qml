import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
pragma Singleton

Item {
    property string imagePath: ""
    
    Component.onCompleted: {
        loadRandomWallpaper()
    }
    
    Timer {
        interval: 300000  // 5 minutes in milliseconds
        running: true
        repeat: true
        onTriggered: loadRandomWallpaper()
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
                }
            }
        }
    }
    
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            required property var modelData
            
            screen: modelData
            visible: true
            color: "black"
            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            focusable: false
            anchors { top: true; bottom: true; left: true; right: true }

            Image {
                anchors.fill: parent
                source: "file://" + imagePath
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
            }
        }
    }
}
