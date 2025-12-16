// modules/NotificationPopupManager.qml
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services as Services
import qs.modules

Scope {
    id: root

    LazyLoader {
        active: (Services.Notifications?.popups.length ?? 0) > 0

        PanelWindow {
            id: popupTray
            implicitWidth: 350
            color: "transparent"
            focusable: false

            WlrLayershell.namespace: "quickshell:notificationPopups"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: 0

            anchors.top: true
            anchors.right: true
            anchors.bottom: true
            margins.top: 6
            margins.right: 6
            margins.bottom: 6

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
