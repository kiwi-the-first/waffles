pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../../services"

// Notification popup manager based on noctalia-shell patterns
Variants {
    model: Quickshell.screens

    delegate: Loader {
        id: root

        required property ShellScreen modelData

        // Only show on screens where we have notifications and not disabled
        active: root.modelData && !NotificationService.popupsDisabled && NotificationService.visibleNotifications.length > 0

        sourceComponent: PanelWindow {
            id: overlay

            screen: root.modelData
            color: "transparent"

            // Use Wayland layer shell like noctalia-shell does
            WlrLayershell.namespace: "waffles-notifications"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            // Position in top-right corner
            anchors.top: true
            anchors.right: true

            implicitWidth: 380
            implicitHeight: stack.implicitHeight + 32

            // Notification stack container
            Column {
                id: stack
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 16  // Base margin from screen edge
                spacing: 8  // Tighter spacing between notifications (matching Noctalia's Style.marginS)
                width: 360

                Repeater {
                    model: NotificationService.visibleNotifications
                    delegate: NotificationPopup {
                        required property var modelData

                        width: 360
                        notificationData: modelData
                        onDismissRequested: NotificationService.removeFromVisibleNotifications(modelData)
                    }
                }
            }
        }
    }
}
