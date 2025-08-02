pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../utils"

Singleton {
    id: root

    // Audio IPC Handler
    IpcHandler {
        target: "audio"
        enabled: true

        function volumeUp(): void {
            DebugUtils.log("IPC: Volume Up called");
            Audio.setVolume(Audio.volume + 0.05);
            OSDManager.show();
        }

        function volumeDown(): void {
            DebugUtils.log("IPC: Volume Down called");
            Audio.setVolume(Audio.volume - 0.05);
            OSDManager.show();
        }

        function volumeMute(): void {
            DebugUtils.log("IPC: Volume Mute called");
            Audio.toggleMute();
            OSDManager.show();
        }
    }

    // Brightness IPC Handler
    IpcHandler {
        target: "brightness"
        enabled: true

        function brightnessUp(): void {
            DebugUtils.log("IPC: Brightness Up called");
            Brightness.increaseBrightness();
            OSDManager.show();
        }

        function brightnessDown(): void {
            DebugUtils.log("IPC: Brightness Down called");
            Brightness.decreaseBrightness();
            OSDManager.show();
        }
    }

    // Media Player IPC Handler
    IpcHandler {
        target: "players"
        enabled: true

        function mediaToggle(): void {
            DebugUtils.log("IPC: Media Toggle called");
            const active = Players.active;
            if (active && active.canTogglePlaying)
                active.togglePlaying();
        }

        function mediaPrev(): void {
            DebugUtils.log("IPC: Media Previous called");
            const active = Players.active;
            if (active && active.canGoPrevious)
                active.previous();
        }

        function mediaNext(): void {
            DebugUtils.log("IPC: Media Next called");
            const active = Players.active;
            if (active && active.canGoNext)
                active.next();
        }

        function mediaStop(): void {
            DebugUtils.log("IPC: Media Stop called");
            Players.active?.stop();
        }
    }
}
