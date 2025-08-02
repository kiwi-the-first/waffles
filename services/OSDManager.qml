pragma Singleton

import Quickshell
import QtQuick
import "../utils"

Singleton {
    id: root

    property bool osdVisible: false
    property real hideDelay: 2000
    property bool hovered: false

    readonly property Timer hideTimer: Timer {
        interval: root.hideDelay
        onTriggered: {
            if (!root.hovered)
                root.osdVisible = false;
        }
    }

    function show(): void {
        DebugUtils.log("OSDManager: Showing OSD");
        root.osdVisible = true;
        hideTimer.restart();
    }

    function hide(): void {
        DebugUtils.log("OSDManager: Hiding OSD");
        root.osdVisible = false;
        hideTimer.stop();
    }

    // Monitor Audio service for changes
    Connections {
        target: Audio

        function onMutedChanged(): void {
            DebugUtils.log("OSDManager: Audio muted changed to", Audio.muted);
            root.show();
        }

        function onVolumeChanged(): void {
            DebugUtils.log("OSDManager: Audio volume changed to", Audio.volume);
            root.show();
        }
    }
}
