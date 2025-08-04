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
    property bool startupComplete: false  // Track if initial startup is complete

    readonly property Timer hideTimer: Timer {
        interval: root.hideDelay
        onTriggered: {
            if (!root.hovered)
                root.osdVisible = false;
        }
    }

    // Startup delay timer to prevent OSD from showing during initial audio service setup
    readonly property Timer startupTimer: Timer {
        interval: 1000  // Wait 1 second after startup before allowing OSD to show
        running: true
        onTriggered: {
            root.startupComplete = true;
            DebugUtils.log("OSDManager: Startup complete, OSD now available");
        }
    }

    function show(): void {
        DebugUtils.log("OSDManager: Showing OSD");
        root.osdVisible = true;
        hideTimer.restart();
    }

    function showVolume(): void {
        if (!root.startupComplete) {
            DebugUtils.log("OSDManager: Ignoring volume change during startup");
            return;
        }
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
            if (!root.startupComplete) {
                DebugUtils.log("OSDManager: Ignoring mute change during startup");
                return;
            }
            DebugUtils.log("OSDManager: Audio muted changed to", Audio.muted);
            root.showVolume();
        }

        function onVolumeChanged(): void {
            if (!root.startupComplete) {
                DebugUtils.log("OSDManager: Ignoring volume change during startup");
                return;
            }
            DebugUtils.log("OSDManager: Audio volume changed to", Audio.volume);
            root.showVolume();
        }
    }

    // Monitor brightness changes via the increase/decrease functions
    // Since we don't have direct brightness property access, we'll rely on IPC calls to trigger OSD
}
