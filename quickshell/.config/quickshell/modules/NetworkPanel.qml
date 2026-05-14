// modules/NetworkPanel.qml
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.services as Services

Item {
    id: root
    
    // Signal to go back to main view
    signal back()

    implicitWidth: 300
    implicitHeight: 400

    // Properties to hold network list
    ListModel {
        id: wifiNetworksModel
    }

    property var knownNetworks: []
    property string pendingSsid: ""
    property bool showPasswordPrompt: false

    // Fetch known networks
    Process {
        id: knownNetworksProc
        command: ["bash", "-c", "iwctl known-networks list | sed 's/\\x1b\\[[0-9;]*m//g'"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                var known = []
                
                // Skip header (usually 4 lines or starts with ----)
                var startIndex = 0
                for (var i = 0; i < lines.length; i++) {
                    if (lines[i].includes("----")) {
                        startIndex = i + 1
                    }
                }

                for (var i = startIndex; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (line.length === 0) continue

                    // Split by 2 or more spaces to separate columns
                    var parts = line.split(/\s{2,}/)
                    if (parts.length >= 1) {
                        var ssid = parts[0].trim()
                        if (ssid.length > 0) {
                            known.push(ssid)
                        }
                    }
                }
                root.knownNetworks = known
            }
        }
    }

    // Refresh networks process
    Process {
        id: scanProc
        // Use sed to strip ANSI escape codes before parsing
        command: ["bash", "-c", "iwctl station wlan0 get-networks | sed 's/\\x1b\\[[0-9;]*m//g'"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                wifiNetworksModel.clear()
                
                var startIndex = 0
                for (var i = 0; i < lines.length; i++) {
                    if (lines[i].includes("----")) {
                        startIndex = i + 1
                    }
                }

                for (var i = startIndex; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (line.length === 0) continue

                    // Parse right to left: Signal, Security, SSID
                    var parts = line.split(/\s+/)
                    
                    if (parts.length >= 3) {
                        var signal = parts[parts.length - 1]
                        var security = parts[parts.length - 2]
                        
                        // Remaining parts are the SSID (and possibly the '>' indicator)
                        var ssidParts = parts.slice(0, parts.length - 2)
                        
                        var isCurrent = false
                        // Check for '>' indicator
                        if (line.trim().startsWith(">")) {
                            isCurrent = true
                            // If the first part was indeed '>', remove it from ssid parts
                            if (ssidParts.length > 0 && ssidParts[0] === ">") {
                                ssidParts.shift()
                            }
                        }
                        
                        // Also check if line starts with '>' directly (in case split separated it as empty string or something)
                        if (line.trim().startsWith(">")) {
                            isCurrent = true
                            // If parts[0] was '>' it is handled above. 
                            // If parts[0] was something else but line started with >, we need to be careful.
                            // But usually iwctl output is aligned.
                        }
                        
                        // Reconstruct SSID
                        var ssid = ssidParts.join(" ")
                        
                        // Basic validation
                        if (ssid.length > 0) { // Removed security check as it might be empty for open networks or parsing issue
                             wifiNetworksModel.append({
                                 "ssid": ssid,
                                 "security": security || "Unknown",
                                 "signal": signal || "N/A",
                                 "isCurrent": isCurrent
                             })
                        }
                    }
                }
            }
        }
    }

    // Connect process
    Process {
        id: connectProc
        command: [] // Set dynamically
    }

    // Active Scan Process
    Process {
        id: performScanProc
        command: ["iwctl", "station", "wlan0", "scan"]
        onExited: scanDelayTimer.start()
    }

    Timer {
        id: scanDelayTimer
        interval: 2000
        repeat: false
        onTriggered: {
            scanProc.running = false
            scanProc.running = true
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            scanProc.running = false
            scanProc.running = true
            knownNetworksProc.running = false
            knownNetworksProc.running = true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Services.Theme.spacingMedium

        // Header
        RowLayout {
            Layout.fillWidth: true
            
            // Back button
            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: backMouse.containsMouse ? Services.Theme.colorSurface1 : "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: "󰁮" // Back arrow icon
                    font.family: Services.Theme.fontFamilyMono
                    font.pixelSize: Services.Theme.iconSizeNormal
                    color: Services.Theme.colorText
                }
                
                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.back()
                }
            }

            Text {
                text: "Wi-Fi Networks"
                font.family: Services.Theme.fontFamilyMono
                font.pixelSize: Services.Theme.fontSizeLarge
                font.weight: Font.Bold
                color: Services.Theme.colorText
                Layout.fillWidth: true
            }

            // WiFi Toggle Button
            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: wifiBtnMouse.pressed ? Services.Theme.colorButtonPress : (wifiBtnMouse.containsMouse ? Services.Theme.colorButtonHover : Services.Theme.colorSurface0)
                border.width: 1
                border.color: Services.Theme.colorSurface1
                Layout.alignment: Qt.AlignVCenter
                opacity: Services.Network?.wifiEnabled ? 1.0 : Services.Theme.opacityMuted

                Behavior on color { ColorAnimation { duration: Services.Theme.animDurationNormal } }
                Behavior on opacity { NumberAnimation { duration: Services.Theme.animDurationNormal } }

                Text {
                    anchors.centerIn: parent
                    text: Services.Network?.wifiEnabled ? "󰤨" : "󰤭"
                    font.family: Services.Theme.fontFamilyMono
                    font.pixelSize: Services.Theme.iconSizeNormal
                    color: Services.Theme.colorText
                }

                MouseArea {
                    id: wifiBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (Services.Network) Services.Network.toggleWifi()
                    }
                }
            }

            // Scan button (manual refresh)
            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: refreshMouse.containsMouse ? Services.Theme.colorSurface1 : "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: "󰑐" // Refresh icon
                    font.family: Services.Theme.fontFamilyMono
                    font.pixelSize: Services.Theme.iconSizeNormal
                    color: Services.Theme.colorText
                }
                
                MouseArea {
                    id: refreshMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        performScanProc.running = false
                        performScanProc.running = true
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Services.Theme.colorSurface1
        }

        // List
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                model: wifiNetworksModel
                spacing: Services.Theme.spacingSmall
                
                delegate: Rectangle {
                    id: networkItem
                    required property var model
                    
                    width: ListView.view.width
                    height: 50
                    radius: Services.Theme.moduleRadius
                    // Simplify color logic to debug
                    color: {
                        if (model.isCurrent) return Services.Theme.colorSurface1
                        if (itemMouse.containsMouse) return Services.Theme.colorSurface0
                        return Services.Theme.colorMantle
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Services.Theme.spacingMedium
                        spacing: Services.Theme.spacingMedium

                        Text {
                            text: "󰤨" 
                            font.family: Services.Theme.fontFamilyMono
                            font.pixelSize: Services.Theme.iconSizeNormal
                            color: (model.isCurrent === true) ? Services.Theme.colorBlue : Services.Theme.colorText
                            visible: true
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            
                            Text {
                                text: model.ssid || "Unknown SSID"
                                font.family: Services.Theme.fontFamilyMono
                                font.pixelSize: Services.Theme.fontSizeNormal
                                font.weight: Font.Medium
                                color: Services.Theme.colorText
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                visible: true
                            }
                            
                            Text {
                                text: (model.security || "") + " • " + (model.signal || "")
                                font.family: Services.Theme.fontFamilyMono
                                font.pixelSize: Services.Theme.fontSizeSmall
                                color: Services.Theme.colorSubtext0
                                visible: true
                            }
                        }
                        
                        Text {
                            visible: (model.isCurrent === true)
                            text: ""
                            font.family: Services.Theme.fontFamilyMono
                            font.pixelSize: Services.Theme.iconSizeNormal
                            color: Services.Theme.colorGreen
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (!model.isCurrent) {
                                var ssid = model.ssid
                                var sec = (model.security || "").toLowerCase()

                                console.log("Checking SSID: " + ssid + " Security: " + sec)

                                if (sec === "open" || root.knownNetworks.includes(ssid)) {
                                    // Connect directly
                                    console.log("Connecting directly to " + ssid)
                                    connectProc.command = ["iwctl", "station", "wlan0", "connect", ssid]
                                    connectProc.running = false
                                    connectProc.running = true
                                } else {
                                    // Prompt for password
                                    console.log("Prompting password for " + ssid)
                                    root.pendingSsid = ssid
                                    root.showPasswordPrompt = true
                                    passwordField.text = ""
                                    passwordField.forceActiveFocus()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Password Dialog Overlay
    Rectangle {
        id: passwordOverlay
        anchors.fill: parent
        color: "#AA000000" // Dimmed background
        z: 999
        visible: root.showPasswordPrompt

        // Prevent clicks outside dialog
        MouseArea {
            anchors.fill: parent
        }

        Rectangle {
            id: dialogBox
            width: parent.width * 0.9
            height: 200
            anchors.centerIn: parent
            radius: Services.Theme.moduleRadius
            color: Services.Theme.colorBase
            border.width: 1
            border.color: Services.Theme.colorSurface1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Services.Theme.spacingLarge
                spacing: Services.Theme.spacingMedium

                Text {
                    text: "Password for " + root.pendingSsid
                    font.family: Services.Theme.fontFamilyMono
                    font.pixelSize: Services.Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Services.Theme.colorText
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    placeholderText: "Enter password"
                    echoMode: TextInput.Password
                    font.family: Services.Theme.fontFamilyMono
                    font.pixelSize: Services.Theme.fontSizeNormal
                    color: Services.Theme.colorText
                    
                    background: Rectangle {
                        color: Services.Theme.colorSurface0
                        radius: Services.Theme.moduleRadius / 2
                        border.width: 1
                        border.color: passwordField.activeFocus ? Services.Theme.colorBlue : Services.Theme.colorSurface1
                    }
                    
                    onAccepted: connectBtn.clicked()
                }

                Item { Layout.fillHeight: true } // Spacer

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Services.Theme.spacingMedium

                    // Cancel Button
                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: Services.Theme.moduleRadius / 2
                        color: cancelMouse.containsMouse ? Services.Theme.colorSurface1 : Services.Theme.colorSurface0
                        border.width: 1
                        border.color: Services.Theme.colorSurface1

                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.family: Services.Theme.fontFamilyMono
                            color: Services.Theme.colorText
                        }

                        MouseArea {
                            id: cancelMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.showPasswordPrompt = false
                                root.pendingSsid = ""
                                passwordField.text = ""
                            }
                        }
                    }

                    // Connect Button
                    Rectangle {
                        id: connectBtn
                        Layout.fillWidth: true
                        height: 36
                        radius: Services.Theme.moduleRadius / 2
                        color: connectMouse.containsMouse ? Services.Theme.colorBlue : Services.Theme.colorBlue // Always blue but maybe darker on hover?
                        opacity: connectMouse.containsMouse ? 0.9 : 1.0

                        signal clicked()

                        onClicked: {
                            if (passwordField.text.length > 0) {
                                connectProc.command = ["iwctl", "--passphrase", passwordField.text, "station", "wlan0", "connect", root.pendingSsid]
                                connectProc.running = false
                                connectProc.running = true
                                root.showPasswordPrompt = false
                                root.pendingSsid = ""
                                passwordField.text = ""
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Connect"
                            font.family: Services.Theme.fontFamilyMono
                            font.weight: Font.Bold
                            color: Services.Theme.colorBase // Text on blue background
                        }

                        MouseArea {
                            id: connectMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: connectBtn.clicked()
                        }
                    }
                }
            }
        }
    }
}
