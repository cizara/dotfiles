import QtQuick
import Quickshell
import qs.bar
import qs.bar.placeholders
import qs.services

Scope {
    id: root

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