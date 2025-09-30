import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../config" as Config
import "../../../../utils" as Utils
import "../../../../widgets" as Widgets

Rectangle {
    id: root

    property var notificationData

    signal dismissRequested

    width: parent.width
    height: Math.max(72, contentLayout.implicitHeight + 16)

    color: Qt.alpha(Config.Colours.m3surfaceContainer, 0.6)
    radius: 12

    border.width: 1
    border.color: Qt.alpha(Config.Colours.m3outlineVariant, 0.3)

    // Hover effect
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked:
        // Expand/collapse functionality could go here
        {}
    }

    // Simple hover overlay
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Qt.alpha(Config.Colours.m3primary, mouseArea.containsMouse ? 0.08 : 0)

        Behavior on color {
            ColorAnimation {
                duration: Config.Appearance.anim.durations.small
                easing.type: Easing.OutQuad
            }
        }
    }

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // App icon
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignTop

            color: "transparent"
            radius: 20

            clip: true

            Image {
                id: appIcon
                anchors.fill: parent
                source: {
                    if (!root.notificationData || !root.notificationData.appName) {
                        return "";
                    }
                    return Utils.Icons.getAppIcon(root.notificationData.appName);
                }
                fillMode: Image.PreserveAspectFit
                smooth: true

                visible: source !== ""
            }

            // Fallback to first letter of app name
            Widgets.StyledText {
                anchors.centerIn: parent
                text: {
                    if (appIcon.visible || !root.notificationData || !root.notificationData.appName) {
                        return "";
                    }
                    return root.notificationData.appName.charAt(0).toUpperCase();
                }
                font.pixelSize: 16
                font.weight: Font.Medium
                color: Config.Colours.m3onSurface
                visible: !appIcon.visible && text !== ""
            }
        }

        // Content area
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 4

            // Header with app name and time
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Widgets.StyledText {
                    Layout.fillWidth: true
                    text: root.notificationData ? (root.notificationData.appName || "Unknown") : "Unknown"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: Config.Colours.m3onSurface
                    elide: Text.ElideRight
                }

                Widgets.StyledText {
                    text: {
                        if (!root.notificationData || !root.notificationData.timestamp) {
                            return "";
                        }
                        const date = new Date(root.notificationData.timestamp);
                        return Qt.formatTime(date, "HH:mm");
                    }
                    font.pixelSize: 12
                    color: Config.Colours.m3onSurfaceVariant
                }
            }

            // Notification summary
            Widgets.StyledText {
                Layout.fillWidth: true
                text: root.notificationData ? (root.notificationData.summary || "") : ""
                font.pixelSize: 13
                color: Config.Colours.m3onSurface
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                visible: text !== ""
            }

            // Notification body
            Widgets.StyledText {
                Layout.fillWidth: true
                text: root.notificationData ? (root.notificationData.body || "") : ""
                font.pixelSize: 12
                color: Config.Colours.m3onSurfaceVariant
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
                visible: text !== ""
            }
        }

        // Dismiss button
        Button {
            id: dismissButton
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignTop

            background: Rectangle {
                radius: 16
                color: dismissButton.hovered ? Qt.alpha(Config.Colours.m3surfaceContainerHighest, 0.8) : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: Config.Appearance.anim.durations.small
                        easing.type: Easing.OutQuad
                    }
                }
            }

            contentItem: Text {
                text: "✕"
                font.pixelSize: 12
                color: Config.Colours.m3onSurfaceVariant
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                root.dismissRequested();
            }

            ToolTip.visible: hovered
            ToolTip.text: "Dismiss"
            ToolTip.delay: 1000
        }
    }

    // Subtle animation when appearing
    opacity: 0
    scale: 0.95

    Component.onCompleted: {
        // Animate in
        opacityAnimation.start();
        scaleAnimation.start();
    }

    NumberAnimation {
        id: opacityAnimation
        target: root
        property: "opacity"
        from: 0
        to: 1
        duration: Config.Appearance.anim.durations.small
        easing.type: Easing.OutQuad
    }

    NumberAnimation {
        id: scaleAnimation
        target: root
        property: "scale"
        from: 0.95
        to: 1.0
        duration: Config.Appearance.anim.durations.small
        easing.type: Easing.OutExpo
    }
}
