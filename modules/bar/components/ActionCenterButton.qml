import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import "../../../services"
import "../../../widgets" as Widgets
import "../../../config"

Rectangle {
    id: root

    implicitWidth: 44
    implicitHeight: 36
    radius: Appearance.rounding.larger

    color: buttonHover.containsMouse ? Qt.alpha(Colours.semantic.accent, 0.12) : "transparent"
    border.width: 1
    border.color: Qt.alpha("#938f99", 0.08)

    property bool expanded: ActionCenterManager.actionCenterVisible
    property int notificationCount: NotificationService.historyList.count

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    MouseArea {
        id: buttonHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            ActionCenterManager.toggleActionCenter();
        }

        onEntered: {
            if (ActionCenterManager.hoverMode) {
                ActionCenterManager.stopHideTimer(); // Cancel any pending hide
                ActionCenterManager.showActionCenter();
            }
        }

        onExited: {
            if (ActionCenterManager.hoverMode) {
                ActionCenterManager.startHideTimer(); // Start delay before hiding
            }
        }
    }

    Widgets.MaterialIcon {
        anchors.centerIn: parent
        animate: true

        // Icon changes based on notification state
        text: {
            if (NotificationService.popupsDisabled) {
                return "notifications_off";
            } else if (root.notificationCount > 0) {
                return "notifications";
            } else {
                return "notifications_none";
            }
        }

        color: NotificationService.popupsDisabled ? Colours.m3error : Colours.semantic.textPrimary
        font.pointSize: Appearance.font.size.iconMedium
        fill: buttonHover.containsMouse ? 1 : 0

        // Hide the icon while hovered so the count Text is shown instead
        opacity: buttonHover.containsMouse ? 0 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }

        Behavior on rotation {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }

    // Show notification count when hovered
    Text {
        anchors.centerIn: parent

        text: {
            if (!buttonHover.containsMouse)
                return "";

            if (NotificationService.popupsDisabled) {
                return "DND";
            } else if (root.notificationCount > 0) {
                return root.notificationCount.toString();
            } else {
                return "0";
            }
        }

        // Only visible when hovered
        opacity: buttonHover.containsMouse ? 1 : 0

        font.family: Appearance.font.family.display
        font.pointSize: Appearance.font.size.body
        font.weight: Font.Medium
        color: NotificationService.popupsDisabled ? Colours.m3error : Colours.semantic.textPrimary

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
    }
}
