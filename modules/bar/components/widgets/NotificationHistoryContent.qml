pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../widgets" as Widgets
import "../../../../config" as Config
import "../../../../services"

// Reusable notification history content component
// Can be embedded in Action Center, standalone windows, or other containers
ColumnLayout {
    id: historyContent

    property alias maxHeight: scrollView.implicitHeight
    property bool showHeader: true
    property bool compactMode: false

    spacing: Config.Appearance.spacing.normal

    // Header (optional)
    RowLayout {
        Layout.fillWidth: true
        spacing: Config.Appearance.spacing.normal
        visible: historyContent.showHeader

        Widgets.MaterialIcon {
            text: "notifications"
            font.pointSize: historyContent.compactMode ? Config.Appearance.font.size.normal : Config.Appearance.font.size.larger
            color: Config.Colours.m3primary
        }

        Text {
            text: "Notifications"
            font.family: Config.Appearance.font.family.display
            font.pointSize: historyContent.compactMode ? Config.Appearance.font.size.normal : Config.Appearance.font.size.larger
            font.weight: Font.Medium
            color: Config.Colours.m3onSurface
            Layout.fillWidth: true
        }

        // Clear all button
        Rectangle {
            Layout.preferredWidth: historyContent.compactMode ? 60 : 80
            Layout.preferredHeight: historyContent.compactMode ? 24 : 28
            radius: Config.Appearance.rounding.normal
            color: clearButtonArea.containsMouse ? Config.Colours.m3errorContainer : "transparent"
            border.color: Config.Colours.m3error
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "Clear"
                font.pointSize: historyContent.compactMode ? Config.Appearance.font.size.smaller : Config.Appearance.font.size.small
                color: Config.Colours.m3error
            }

            MouseArea {
                id: clearButtonArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: NotificationService.clearHistory()
            }
        }
    }

    // Separator (when header is shown)
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Config.Colours.m3outline
        visible: historyContent.showHeader
    }

    // Notification list
    ScrollView {
        id: scrollView
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: historyContent.compactMode ? 200 : 300
        implicitHeight: Layout.preferredHeight
        clip: true

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ListView {
            id: notificationsList
            model: NotificationService.historyList
            spacing: historyContent.compactMode ? Config.Appearance.spacing.small : Config.Appearance.spacing.normal

            delegate: Component {
                NotificationHistoryItem {
                    required property var model
                    width: notificationsList.width
                    notificationData: model

                    // Scale down for compact mode
                    transform: Scale {
                        xScale: historyContent.compactMode ? 0.95 : 1.0
                        yScale: historyContent.compactMode ? 0.95 : 1.0
                    }

                    onDismissRequested: {
                        NotificationService.removeFromHistory(model.id);
                    }
                }
            }

            // Empty state
            Item {
                anchors.centerIn: parent
                width: parent.width
                height: historyContent.compactMode ? 80 : 100
                visible: notificationsList.count === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Config.Appearance.spacing.small

                    Widgets.MaterialIcon {
                        text: "notifications_off"
                        font.pointSize: historyContent.compactMode ? 24 : 32
                        color: Config.Colours.m3onSurfaceVariant
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "No notifications"
                        font.pointSize: historyContent.compactMode ? Config.Appearance.font.size.small : Config.Appearance.font.size.normal
                        color: Config.Colours.m3onSurfaceVariant
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }

    // Footer with notification count (optional in compact mode)
    Text {
        text: `${NotificationService.historyList.count} notifications`
        font.pointSize: Config.Appearance.font.size.smaller
        color: Config.Colours.m3onSurfaceVariant
        Layout.alignment: Qt.AlignHCenter
        visible: !historyContent.compactMode || NotificationService.historyList.count > 0
    }
}
