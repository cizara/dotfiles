import QtQuick
import Quickshell
import qs.services as Services

Item {
    id: root
    implicitHeight: Services.Theme.moduleHeight
    implicitWidth: contentRow.implicitWidth + (Services.Theme.paddingLarge * 2)
    
    readonly property var windowService: Services.HyprlandWindow
    
    // theme
    property color bgColor: Services.Theme.colorBase
    property color textColor: Services.Theme.colorText
    property color iconColor: Services.Theme.colorBlue
    
    // data
    readonly property string title: windowService.title
    readonly property string class_: windowService.class_
    
    // Maximum width before truncating
    property int maxWidth: 700
    
    Rectangle {
        anchors.fill: parent
        color: root.bgColor
        radius: Services.Theme.moduleRadius
        
        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: Services.Theme.spacingMedium
            
            // Window icon
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "󰌯"
                font.family: Services.Theme.fontFamilyMono
                font.pixelSize: Services.Theme.iconSizeNormal
                color: root.iconColor
                visible: root.title.length > 0
            }
            
            // Window title
            Text {
                id: titleText
                anchors.verticalCenter: parent.verticalCenter
                text: root.title || "Desktop"
                color: root.textColor
                font.pixelSize: Services.Theme.fontSizeNormal
                font.weight: Services.Theme.fontWeightNormal
                font.family: Services.Theme.fontFamily
                elide: Text.ElideRight
                maximumLineCount: 1
                
                width: Math.min(implicitWidth, root.maxWidth - 40)
            }
        }
    }
}
