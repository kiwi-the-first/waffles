import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: background

    // Screen property for multi-monitor support
    property ShellScreen targetScreen: null
    screen: targetScreen

    WlrLayershell.namespace: "waffles-wallpaper-" + (targetScreen?.name || "unknown")
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    color: "black"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        opacity: 1
        source: "/home/kiwi/Pictures/kwiWallpaper/spenser-sembrat-unsplash.jpg"
    }
}
