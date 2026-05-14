//@ pragma UseQApplication

import QtQuick
import Quickshell
import qs.bar
import qs.bar.placeholders
import qs.services
import qs.modules

Scope {
    id: root
    
    property var wallpaper: Wallpaper

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