// modules/NotificationPopupManager.qml
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services as Services
import qs.modules

Scope {
    id: root

    readonly property int notificationWidth: 420
    readonly property int windowPadding: 6

    LazyLoader {
        active: (Services.Notifications?.popups.length ?? 0) > 0

        PanelWindow {
            id: popupTray
            width: root.notificationWidth + (root.windowPadding * 2)
            height: notificationColumn.height + 12
            color: "transparent"
            focusable: false

            WlrLayershell.namespace: "quickshell:notificationPopups"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: 0

            anchors.top: true
            anchors.right: true
            margins.top: 6
            margins.right: root.windowPadding

            Column {
                id: notificationColumn
                anchors.right: parent.right
                spacing: 6
                width: parent.width

                Repeater {
                    model: Services.Notifications?.popups ?? []

                    delegate: NotificationPopup {
                        onlyVisible: true
                    }
                }
            }
        }
    }
}
