import QtQuick
import Quickshell
import Quickshell.Wayland
pragma Singleton

PanelWindow {
    property string imagePath: ""

    visible: true
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    focusable: false
    anchors { top: true; bottom: true; left: true; right: true }

    Image {
        anchors.fill: parent
        source: imagePath ? ("file://" + imagePath) : ""
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }
}
