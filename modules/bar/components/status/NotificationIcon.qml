pragma ComponentBehavior: Bound
import QtQuick
import "../../../../widgets" as Widgets
import "../widgets" as BarWidgets
import "../../../../config"
import "../../../../services"

Rectangle {
    id: notificationRect
    width: 36
    height: 36
    radius: Appearance.rounding.larger
    color: notificationHover.containsMouse ? Colours.alpha(Colours.m3primary, 0.12) : "transparent"

    property int notificationCount: NotificationService.historyList.count
    property int unreadCount: {
        // Simple unread count - could be enhanced with timestamp tracking
        return NotificationService.historyList.count;
    }

    signal clicked

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    MouseArea {
        id: notificationHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            console.log("NotificationIcon MouseArea clicked - showing ActionCenter");
            ActionCenterManager.showActionCenter();
            parent.clicked();
        }
    }

    Widgets.MaterialIcon {
        anchors.centerIn: parent
        animate: true

        // Icon changes based on notification state
        text: {
            if (NotificationService.popupsDisabled) {
                return "notifications_off";
            } else if (parent.notificationCount > 0) {
                return "notifications";
            } else {
                return "notifications_none";
            }
        }

        color: NotificationService.popupsDisabled ? Colours.m3error : Colours.m3onSurface
        font.pointSize: Appearance.font.size.iconMedium

        // Hide the icon while hovered so the count Text is shown instead
        opacity: notificationHover.containsMouse ? 0 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
    }

    // Show notification count when hovered
    Text {
        anchors.centerIn: parent

        text: {
            if (!notificationHover.containsMouse)
                return "";

            if (NotificationService.popupsDisabled) {
                return "DND";
            } else if (parent.notificationCount > 0) {
                return parent.notificationCount.toString();
            } else {
                return "0";
            }
        }

        // Only visible when hovered
        opacity: notificationHover.containsMouse ? 1 : 0

        font.family: Appearance.font.family.display
        font.pointSize: Appearance.font.size.body
        font.weight: Font.Medium
        color: NotificationService.popupsDisabled ? Colours.m3error : Colours.m3onSurface

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
    }

    // Notification badge for unread count (similar to other status icons with indicators)
    Rectangle {
        id: notificationBadge
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 4
        anchors.topMargin: 4

        width: 8
        height: 8
        radius: 4

        color: Colours.m3error
        border.color: Colours.m3surface
        border.width: 1

        visible: parent.unreadCount > 0 && !NotificationService.popupsDisabled

        Behavior on visible {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }
}
