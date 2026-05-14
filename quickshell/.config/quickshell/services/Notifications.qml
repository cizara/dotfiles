pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import qs.services as Services

// from github.com/end-4/dots-hyprland with modifications

Singleton {
    id: root

    property list<Notif> data: []
    property list<Notif> popups: data.filter(n => n.popup && !n.tracked && !root.doNotDisturb)
    property list<Notif> history: data
    property bool doNotDisturb: false
    
    Process { id: soundProcess }
    
    function clearAll() {
        for (var i = data.length - 1; i >= 0; i--) {
            if (data[i] && data[i].notification) {
                data[i].notification.dismiss();
            }
        }
        data = [];
    }

    NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: notif => {
            notif.tracked = true;

            root.data.push(notifComp.createObject(root, {
                popup: true,
                notification: notif,
                shown: false
            }));

            // Play notification sound if not in DND mode
            if (!root.doNotDisturb) {
                const soundName = notif.hints["sound-name"] || notif.hints["sound-file"];
                const suppressSound = notif.hints["suppress-sound"];
                
                // Don't play sound if explicitly suppressed or if it's a low urgency notification
                if (suppressSound === true || suppressSound === 1) {
                    // Sound suppressed
                } else if (soundName) {
                    soundProcess.command = ["canberra-gtk-play", "-i", soundName];
                    soundProcess.startDetached();
                } else {
                    // Play default notification sound based on urgency
                    // const defaultSound = notif.urgency === 2 ? "dialog-warning" : "message-new-instant";
                    // soundProcess.command = ["canberra-gtk-play", "-i", defaultSound];
                    // soundProcess.startDetached();
                    console.log("No sound specified for notification.");
                }
            }
        }
    }
    function removeById(id) {
        const i = data.findIndex(n => n.notification.id === id);
        if (i >= 0) {
            data.splice(i, 1);
        }
    }


    component Notif: QtObject {
        id: notif

        property bool popup
        readonly property date time: new Date()
        readonly property string timeStr: {
            const now = new Date();
            const diff = now.getTime() - time.getTime();
            const m = Math.floor(diff / 60000);
            const h = Math.floor(m / 60);

            if (h < 1 && m < 1)
                return "now";
            if (h < 1)
                return `${m}m`;
            return `${h}h`;
        }

        property bool shown: false
        required property Notification notification
        readonly property string summary: notification.summary
        readonly property string body: notification.body
        readonly property string appIcon: notification.appIcon
        readonly property string appName: notification.appName
        readonly property string image: notification.image
        readonly property int urgency: notification.urgency
        readonly property list<NotificationAction> actions: notification.actions

        readonly property Timer timer: Timer {
            running: notif.actions.length >= 0
            interval: notif.notification.expireTimeout > 0 ? notif.notification.expireTimeout : 3000
            onTriggered: {
                if (true)
                    notif.popup = false;
            }
        }

        property Timer removalTimer: Timer {
            interval: 300000  // Keep in history for 60 seconds
            repeat: false
            onTriggered: {
                const idx = root.data.indexOf(notif);
                if (idx >= 0) {
                    root.data.splice(idx, 1);
                }
            }
        }

        readonly property Connections conn: Connections {
            target: notif.notification.Retainable

            function onDropped(): void {
                notif.removalTimer.start();
            }

            function onAboutToDestroy(): void {
                notif.destroy();
            }
        }
        readonly property Connections conn2: Connections {
            target: notif.notification

            function onClosed(reason) {
                root.data.splice(root.data.indexOf(notif), 1)
            }
        }

    }

    Component {
        id: notifComp

        Notif {}
    }
}