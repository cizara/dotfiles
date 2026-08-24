//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import qs.bar
import qs.bar.placeholders
import qs.services
import qs.modules

Scope {
    id: root

    property var wallpaper: Wallpaper

    // Liveness probe for scripts: `qs ipc call shell ping` answers "ok" only once
    // the QML has actually loaded, which is the difference between "the shell is
    // running" and "the shell is ready".
    IpcHandler {
        target: "shell"

        function ping(): string {
            return "ok"
        }

        // The structural tokens Theme reads back out of Hyprland. Exposed because
        // otherwise there is no way to tell whether they actually resolved or are
        // still sitting on their defaults.
        function theme(): string {
            return JSON.stringify({
                cornerRadius: Theme.cornerRadius,
                gapsOut: Theme.gapsOut,
                fontFamily: Theme.fontFamily
            })
        }
    }

    NotificationPopupManager {}

    Loader {
        active: true
        sourceComponent: Bar {}
    }

    Loader {
        active: false
        sourceComponent: Bottombar {}
    }

    Loader {
        active: true
        sourceComponent: Rightbar {}
    }

    Loader {
        active: true
        sourceComponent: Leftbar {}
    }

    Variants {
        model: Quickshell.screens
        
        Mask {
            screen: modelData
        }
    }
}