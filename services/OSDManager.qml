pragma Singleton

import Quickshell
import QtQuick
import "../utils"

Singleton {
    id: root

    property bool osdVisible: false
    property real hideDelay: 1500  // Reduced from 2000ms to 1.5s for better UX
    property bool hovered: false
    property string currentType: "volume" // "volume" or "brightness"

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

    function showVolume(): void {
        DebugUtils.log("OSDManager: Showing Volume OSD");
        root.currentType = "volume";
        root.osdVisible = true;
        hideTimer.restart();
    }

    function showBrightness(): void {
        DebugUtils.log("OSDManager: Showing Brightness OSD");
        root.currentType = "brightness";
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
            root.showVolume();
        }

        function onVolumeChanged(): void {
            DebugUtils.log("OSDManager: Audio volume changed to", Audio.volume);
            root.showVolume();
        }
    }

    // Monitor brightness changes via the increase/decrease functions
    // Since we don't have direct brightness property access, we'll rely on IPC calls to trigger OSD
}
