import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import "../../../../services"
import "../../../settings" as Settings
import "../../../../utils"
import "../../../../widgets" as Widgets
import "../../../../config"

PopupWindow {
    id: actionCenterWindow

    implicitWidth: 300
    implicitHeight: 420
    visible: false
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Colours.semantic.backgroundMain
        radius: Appearance.rounding.large
        border.color: Qt.alpha("#938f99", 0.2)
        border.width: 1

        // HoverHandler to detect hover and prevent closing
        HoverHandler {
            id: actionCenterHover

            onHoveredChanged: {
                if (ActionCenterManager.hoverMode) {
                    if (hovered) {
                        ActionCenterManager.actionCenterHovered = true;
                        ActionCenterManager.stopHideTimer();
                    } else {
                        ActionCenterManager.actionCenterHovered = false;
                        ActionCenterManager.startHideTimer();
                    }
                }
            }
        }

        // Subtle shadow effect
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.8
            shadowHorizontalOffset: 4
            shadowVerticalOffset: 4
            shadowColor: Qt.alpha("#000000", 0.4)
        }

        ScrollView {
            anchors.fill: parent
            anchors.margins: 20
            contentWidth: availableWidth
            clip: true

            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
                width: parent.width
                spacing: 16

                // Header
                Rectangle {
                    width: parent.width
                    height: 40
                    color: "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Action Center"
                        font.family: Appearance.font.family.display
                        font.pointSize: Appearance.font.size.title
                        font.weight: Font.Medium
                        color: Colours.semantic.textPrimary
                    }
                }

                // Separator
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Qt.alpha("#938f99", 0.3)
                }

                // Quick Settings Section
                Rectangle {
                    width: parent.width
                    height: 120
                    color: Qt.alpha(Colours.semantic.accent, 0.05)
                    radius: Appearance.rounding.larger
                    border.width: 1
                    border.color: Qt.alpha("#938f99", 0.1)

                    Column {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8

                        Text {
                            text: "Quick Settings"
                            font.family: Appearance.font.family.display
                            font.pointSize: Appearance.font.size.body
                            font.weight: Font.Medium
                            color: Colours.semantic.accent
                        }

                        Text {
                            text: "• WiFi controls"
                            font.family: Appearance.font.family.display
                            font.pointSize: Appearance.font.size.smaller
                            color: Colours.semantic.borderStrong
                        }

                        Text {
                            text: "• Volume mixer"
                            font.family: Appearance.font.family.display
                            font.pointSize: Appearance.font.size.smaller
                            color: Colours.semantic.borderStrong
                        }

                        Text {
                            text: "• Bluetooth settings"
                            font.family: Appearance.font.family.display
                            font.pointSize: Appearance.font.size.smaller
                            color: Colours.semantic.borderStrong
                        }
                    }
                }

                // Settings Button
                Rectangle {
                    width: parent.width
                    height: 50
                    color: Qt.alpha("#938f99", 0.05)
                    radius: Appearance.rounding.larger
                    border.width: 1
                    border.color: Qt.alpha("#938f99", 0.1)

                    Row {
                        anchors.centerIn: parent
                        spacing: 12

                        Widgets.MaterialIcon {
                            text: "settings"
                            font.pointSize: Appearance.font.size.iconMedium
                            color: Colours.semantic.textPrimary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Settings"
                            font.family: Appearance.font.family.display
                            font.pointSize: Appearance.font.size.body
                            font.weight: Font.Medium
                            color: Colours.semantic.textPrimary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: settingsMouseArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            SettingsManager.showSettingsWindow();
                        }
                        onContainsMouseChanged: {
                            parent.color = settingsMouseArea.containsMouse ? Qt.alpha("#938f99", 0.15) : Qt.alpha("#938f99", 0.05);
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }
                }

                // Notifications Section
                Rectangle {
                    width: parent.width
                    height: 160
                    color: Qt.alpha("#938f99", 0.05)
                    radius: Appearance.rounding.larger
                    border.width: 1
                    border.color: Qt.alpha("#938f99", 0.1)

                    Column {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8

                        Text {
                            text: "Notifications"
                            font.family: Appearance.font.family.display
                            font.pointSize: Appearance.font.size.body
                            font.weight: Font.Medium
                            color: Colours.semantic.accent
                        }

                        Text {
                            text: "No new notifications"
                            font.family: Appearance.font.family.display
                            font.pointSize: Appearance.font.size.smaller
                            color: Colours.semantic.borderStrong
                            opacity: 0.7
                        }
                    }
                }

                // Actions Section
                Rectangle {
                    width: parent.width
                    height: 80
                    color: Qt.alpha(Colours.semantic.accent, 0.03)
                    radius: Appearance.rounding.larger
                    border.width: 1
                    border.color: Qt.alpha("#938f99", 0.1)

                    Row {
                        anchors.centerIn: parent
                        spacing: 12

                        Rectangle {
                            width: 60
                            height: 40
                            radius: Appearance.rounding.normal
                            color: mouseArea1.containsMouse ? Qt.alpha(Colours.semantic.accent, 0.12) : Qt.alpha(Colours.semantic.accent, 0.08)
                            border.width: 1
                            border.color: Qt.alpha(Colours.semantic.accent, 0.2)

                            Text {
                                anchors.centerIn: parent
                                text: "Settings"
                                font.family: Appearance.font.family.display
                                font.pointSize: Appearance.font.size.small
                                color: Colours.semantic.accent
                            }

                            MouseArea {
                                id: mouseArea1
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    DebugUtils.log("Settings clicked");
                                }
                            }
                        }

                        Rectangle {
                            width: 60
                            height: 40
                            radius: Appearance.rounding.normal
                            color: mouseArea2.containsMouse ? Qt.alpha(Colours.semantic.accent, 0.12) : Qt.alpha(Colours.semantic.accent, 0.08)
                            border.width: 1
                            border.color: Qt.alpha(Colours.semantic.accent, 0.2)

                            Text {
                                anchors.centerIn: parent
                                text: "Power"
                                font.family: Appearance.font.family.display
                                font.pointSize: Appearance.font.size.small
                                color: Colours.semantic.accent
                            }

                            MouseArea {
                                id: mouseArea2
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    DebugUtils.log("Power clicked");
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
