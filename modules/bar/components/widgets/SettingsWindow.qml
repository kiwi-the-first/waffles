import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import "../../../../services"
import "../../../settings" as Settings
import "../../../../utils"
import "../../../../widgets" as Widgets

PopupWindow {
    id: settingsWindow

    implicitWidth: 350
    implicitHeight: 250
    visible: SettingsManager.settingsWindowVisible
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#1c1b1f"
        radius: 16
        border.color: Qt.alpha("#938f99", 0.2)
        border.width: 1

        // HoverHandler to detect hover and prevent closing
        HoverHandler {
            id: settingsHover

            onHoveredChanged: {
                SettingsManager.settingsWindowHovered = hovered;
            }
        }

        // Close button (X) in top-right corner
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 12
            anchors.rightMargin: 12
            width: 28
            height: 28
            radius: 14
            color: Qt.alpha("#938f99", 0.1)
            border.width: 1
            border.color: Qt.alpha("#938f99", 0.2)

            Widgets.MaterialIcon {
                anchors.centerIn: parent
                text: "close"
                font.pointSize: 16
                color: "#e6e0e9"
            }

            MouseArea {
                id: closeButtonMouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    SettingsManager.hideSettingsWindow();
                }
                onContainsMouseChanged: {
                    parent.color = closeButtonMouseArea.containsMouse ? Qt.alpha("#938f99", 0.2) : Qt.alpha("#938f99", 0.1);
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }

        ScrollView {
            anchors.fill: parent
            anchors.margins: 20
            anchors.topMargin: 50  // Extra margin for the close button
            contentWidth: availableWidth
            clip: true

            Column {
                width: parent.width
                spacing: 16

                // Title
                Text {
                    text: "Settings"
                    font.family: "JetBrains Mono"
                    font.pointSize: 16
                    font.weight: Font.Bold
                    color: "#e6e0e9"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Settings panels
                Settings.InteractionModePanel {}

                Settings.DebugPanel {}

                // Close button
                Rectangle {
                    width: parent.width
                    height: 40
                    radius: 8
                    color: Qt.alpha("#938f99", 0.1)
                    border.width: 1
                    border.color: Qt.alpha("#938f99", 0.2)
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "Close"
                        font.family: "JetBrains Mono"
                        font.pointSize: 12
                        color: "#e6e0e9"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SettingsManager.hideSettingsWindow();
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
    }

    // Close when clicking outside
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: {
            if (!settingsHover.hovered) {
                SettingsManager.hideSettingsWindow();
            }
        }
    }
}
