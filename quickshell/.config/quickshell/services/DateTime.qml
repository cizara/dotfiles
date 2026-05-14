import QtQuick
pragma Singleton

Item {
    id: root
    
    property string currentTime: ""
    property string argTime: ""

    function updateDateTime() {
        const d = new Date()
        currentTime = Qt.formatDateTime(d, "ddd, MMM dd • HH:mm:ss")
        
        // Argentina is UTC-3
        const argOffset = -3 * 60 // minutes
        const localOffset = d.getTimezoneOffset() // minutes from UTC
        const argDate = new Date(d.getTime() + (localOffset + argOffset) * 60000)
        argTime = Qt.formatDateTime(argDate, "HH:mm  •")
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateDateTime()
    }
}
