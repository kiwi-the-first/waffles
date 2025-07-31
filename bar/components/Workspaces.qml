pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Hyprland
import "../../widgets" as Widgets

Rectangle {
    id: root
    width: 36
    height: 36
    radius: 18

    property int currentWorkspace: Hyprland.focusedMonitor?.activeWorkspace?.id ?? 1

    color: Qt.alpha("#d0bcff", 0.1)
    border.width: 1
    border.color: Qt.alpha("#938f99", 0.2)

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            parent.color = Qt.alpha("#d0bcff", 0.15);
        }

        onExited: {
            parent.color = Qt.alpha("#d0bcff", 0.1);
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.currentWorkspace.toString()
        font.family: "JetBrains Mono"
        font.pointSize: 12
        font.weight: Font.Medium
        color: "#d0bcff"

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
    }
}
