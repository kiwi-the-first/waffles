pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property list<MprisPlayer> list: Mpris.players.values
    readonly property MprisPlayer active: manualActive ?? list.find(p => p.identity === "Spotify") ?? list[0] ?? null
    property MprisPlayer manualActive
}
