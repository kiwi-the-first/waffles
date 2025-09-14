import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.config

PanelWindow {
    id: root
    color: "transparent"
    implicitWidth: 250

    WlrLayershell.namespace: "waffles-clock"
    WlrLayershell.layer: WlrLayer.Bottom

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    Text {
        anchors.centerIn: parent
        font.pointSize: 90
        font.family: Appearance.font.family.sans
        font.weight: Font.Bold
        text: Qt.formatDateTime(systemClock.date, "HH:mm")
        color: Colours.m3onSurface
    }
}
