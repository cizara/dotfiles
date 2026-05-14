import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Item {
    id: root
    
    property string title: ""
    property string class_: ""
    property string workspace: ""
    
    // Watch for window changes via Hyprland socket events
    Process {
        id: hyprSocket
        command: ["sh", "-c", "socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"]
        running: true
        
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const line = data.trim()
                // Listen for events that change active window
                // activewindow>> fires on focus change
                // closewindow>> fires when a window closes
                // openwindow>> fires when a window opens
                if (line.startsWith("activewindow>>") || 
                    line.startsWith("closewindow>>") ||
                    line.startsWith("openwindow>>") ||
                    line.startsWith("workspace>>") ||
                    line.startsWith("focusedmon>>")) {
                    root.updateActiveWindow()
                }
            }
        }
    }
    
    // Fetch current active window info
    Process {
        id: activeWindowProc
        command: ["hyprctl", "activewindow", "-j"]
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { activeWindowProc.buffer += data }
        }
        
        onRunningChanged: {
            if (running) return
            if (!activeWindowProc.buffer || activeWindowProc.buffer.trim() === "") {
                root.title = ""
                root.class_ = ""
                return
            }
            
            try {
                const obj = JSON.parse(activeWindowProc.buffer)
                root.title = obj.title || ""
                root.class_ = obj.class || ""
                root.workspace = obj.workspace ? String(obj.workspace.id || "") : ""
            } catch (e) {
                console.log("HyprlandWindow: Failed to parse window info:", e)
            }
        }
    }
    
    function updateActiveWindow() {
        if (activeWindowProc.running) return
        activeWindowProc.buffer = ""
        activeWindowProc.running = true
    }
    
    Component.onCompleted: {
        updateActiveWindow()
    }
}
