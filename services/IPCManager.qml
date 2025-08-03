pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../utils"
import "../config"

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
            OSDManager.showBrightness();
        }

        function brightnessDown(): void {
            DebugUtils.log("IPC: Brightness Down called");
            Brightness.decreaseBrightness();
            OSDManager.showBrightness();
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

    // Theme IPC Handler
    IpcHandler {
        target: "theme"
        enabled: true

        function setTheme(theme: string): void {
            DebugUtils.log("IPC: Set Theme called with:", theme);
            if (theme === "light" || theme === "dark" || theme === "auto") {
                Colours.currentTheme = theme === "auto" ? "dynamic" : theme;
                DebugUtils.log("IPC: Theme changed to:", Colours.currentTheme);
            } else {
                DebugUtils.log("IPC: Invalid theme specified:", theme);
            }
        }

        function toggleTheme(): void {
            DebugUtils.log("IPC: Toggle Theme called");
            if (Colours.currentTheme === "light") {
                Colours.currentTheme = "dark";
            } else {
                Colours.currentTheme = "light";
            }
            DebugUtils.log("IPC: Theme toggled to:", Colours.currentTheme);
        }

        function getTheme(): string {
            DebugUtils.log("IPC: Get Theme called");
            const theme = Colours.currentTheme === "dynamic" ? "auto" : Colours.currentTheme;
            DebugUtils.log("IPC: Current theme:", theme);
            return theme;
        }
    }
}
