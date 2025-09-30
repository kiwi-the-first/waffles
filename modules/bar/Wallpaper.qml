import QtQuick
import Quickshell
import Quickshell.Wayland

// Variants {
//     model: Quickshell.screens

PanelWindow {
    id: background
    required property ShellScreen modelData
    screen: modelData
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
        source: "/home/kiwi/Pictures/kwiWallpaper/jake-blucker-YHNYQCxZ40s-unsplash.jpg"
    }
}
// }
