pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../../services"
import "../../../widgets" as Widgets
import "../../common"
import "../../../config"

Rectangle {
    id: root
    width: 36
    height: 36
    radius: Appearance.rounding.large

    property int currentWorkspace: Hyprland.focusedMonitor?.activeWorkspace?.id ?? 1

    color: Colours.alpha(Colours.m3primary, 0.1)
    border.width: 1
    border.color: Colours.alpha(Colours.m3outline, 0.2)

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

        onPressed: root.scale = 0.95
        onReleased: root.scale = 1.0
        onCanceled: root.scale = 1.0

        onClicked: {
            if (!InteractionSettings.hoverMode) {
                WorkspaceManager.toggleWorkspaceWindow();
            }
        }

        onEntered: {
            parent.color = Colours.alpha(Colours.m3primary, 0.15);
            if (InteractionSettings.hoverMode) {
                WorkspaceManager.stopHideTimer(); // Cancel any pending hide
                WorkspaceManager.showWorkspaceWindow();
            }
        }

        onExited: {
            parent.color = Colours.alpha(Colours.m3primary, 0.1);
            if (InteractionSettings.hoverMode) {
                WorkspaceManager.startHideTimer(); // Start delay before hiding
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.currentWorkspace.toString()
        font.family: Appearance.font.family.display
        font.pointSize: Appearance.font.size.body
        font.weight: Font.Medium
        color: Colours.semantic.accent

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
    }
}
