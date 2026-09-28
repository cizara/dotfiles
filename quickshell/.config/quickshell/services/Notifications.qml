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

    // Nothing in the protocol stops an app from sending an unbounded number of
    // non-expiring notifications, and every retained one costs timers plus a
    // delegate in the history panel.
    readonly property int maxNotifications: 100
    readonly property int maxPopups: 5

    // timeStr is a binding, and a new Date() inside one registers no dependency, so
    // it evaluated once per notification and every row read "now" forever. Entries
    // used to disappear as soon as they closed, which hid it.
    property double nowMs: Date.now()

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.nowMs = Date.now()
    }

    property list<Notif> data: []
    property list<Notif> popups: data.filter(n => n.popup && !n.tracked && !root.doNotDisturb).slice(0, root.maxPopups)
    property list<Notif> history: data
    property bool doNotDisturb: false
    
    Process { id: soundProcess }

    // qs ipc call notifications toggleDnd
    IpcHandler {
        target: "notifications"

        function toggleDnd(): string {
            root.doNotDisturb = !root.doNotDisturb
            return root.doNotDisturb ? "on" : "off"
        }

        function dndState(): string {
            return root.doNotDisturb ? "on" : "off"
        }

        function setDnd(state: string): string {
            root.doNotDisturb = (state === "on" || state === "true")
            return root.doNotDisturb ? "on" : "off"
        }

        function dismissAll(): string {
            root.clearAll()
            return "ok"
        }

        function count(): string {
            return String(root.data.length)
        }
    }

    // Senders read GetCapabilities once at startup and cache it forever, so anything
    // already running when markup support was withdrawn still sends escaped HTML —
    // and some senders ignore capabilities outright. Rendering is PlainText, so this
    // is cosmetic only: a miss shows a stray tag instead of letting markup through.
    // Tags go before entities, or an escaped &lt;b&gt; would decode into a real tag
    // and then get stripped as one.
    function plainBody(body) {
        if (!body)
            return "";
        return body.replace(/<br\s*\/?>/gi, "\n")
            .replace(/<\/p\s*>/gi, "\n")
            .replace(/<[^>]*>/g, "")
            .replace(/&lt;/g, "<")
            .replace(/&gt;/g, ">")
            .replace(/&quot;/g, "\"")
            .replace(/&apos;/g, "'")
            .replace(/&#39;/g, "'")
            .replace(/&nbsp;/g, " ")
            .replace(/&amp;/g, "&")
            .trim();
    }

    // app_icon is either a themed icon name or a file:// URI per the spec, and
    // Chromium sends the latter — iconPath() cannot resolve a path and logs
    // "Could not load icon". Anything that is not a local path still goes through
    // iconPath, so a sender cannot aim an Image at a http:// URL.
    function appIconSource(appIcon) {
        if (!appIcon || appIcon.length === 0)
            return "";
        if (appIcon.startsWith("file:") || appIcon.startsWith("/"))
            return appIcon;
        return Quickshell.iconPath(appIcon);
    }

    // Explicit removal is the only thing that takes a notification out of the panel.
    // Releasing the lock lets quickshell destroy the notification, which fires
    // aboutToDestroy and tears down the wrapper.
    function remove(notif) {
        if (!notif)
            return;
        const idx = data.indexOf(notif);
        if (idx >= 0)
            data.splice(idx, 1);
        if (notif.lock)
            notif.lock.locked = false;
    }

    function clearAll() {
        const all = [];
        for (var i = 0; i < data.length; i++)
            all.push(data[i]);

        data = [];

        for (const notif of all) {
            if (notif?.notification)
                notif.notification.dismiss();
            if (notif?.lock)
                notif.lock.locked = false;
        }
    }

    NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        // Both the popup and the history render notification text as plain text, so
        // advertising markup would be a lie senders act on: Chromium only escapes "<"
        // in the body when the server claims body-markup. imageSupported is a separate
        // capability ("icon-static") for the image-data/image-path hint that carries
        // album art, and stays on.
        bodyHyperlinksSupported: false
        bodyImagesSupported: false
        bodyMarkupSupported: false
        imageSupported: true

        onNotification: notif => {
            notif.tracked = true;

            while (root.data.length >= root.maxNotifications) {
                const oldest = root.data[0];
                if (oldest?.notification)
                    oldest.notification.dismiss();
                root.remove(oldest);
            }

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
            const diff = root.nowMs - notif.time.getTime();
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

        // Without this the notification is destroyed the moment the sender closes it,
        // so it could never survive in the panel.
        readonly property RetainableLock lock: RetainableLock {
            object: notif.notification
            locked: true
        }

        // Senders delete their per-notification temp image file when they close the
        // notification, and Qt purges unreferenced pixmaps on a timer, so a row a few
        // minutes old would re-request a path that no longer exists and fall back to
        // the glyph. This never renders; it exists to hold a reference to the decoded
        // pixmap for as long as the row lives. sourceSize must match the panel's, or
        // it keeps a different cache entry alive than the one the panel asks for.
        readonly property Image imageHolder: Image {
            source: notif.notification.image
            sourceSize.width: 64
            sourceSize.height: 64
            cache: true
            asynchronous: true
        }

        readonly property Timer timer: Timer {
            running: notif.actions.length >= 0
            // expireTimeout is sender-controlled: unclamped, a large value pins the
            // popup on the overlay layer indefinitely.
            interval: Math.min(Math.max(notif.notification.expireTimeout, 3000), 15000)
            onTriggered: {
                if (true)
                    notif.popup = false;
            }
        }

        readonly property Connections conn: Connections {
            target: notif.notification.Retainable

            function onAboutToDestroy(): void {
                notif.destroy();
            }
        }
        readonly property Connections conn2: Connections {
            target: notif.notification

            function onClosed(reason) {
                // The panel is a history, so closing only retires the popup — the
                // entry stays until Clear all or its own dismiss button removes it.
                notif.popup = false;
            }
        }

    }

    Component {
        id: notifComp

        Notif {}
    }
}