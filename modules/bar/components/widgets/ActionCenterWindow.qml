import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../../../../services"
import "../../../settings" as Settings
import "../../../../utils"
import "../../../../widgets" as Widgets
import "../../../../config"

PanelWindow {
    id: actionCenterWindow

    anchors {
        top: true
        bottom: true
        right: true
    }

    margins {
        top: 10
        bottom: 10
        right: 10
    }

    implicitWidth: 380
    visible: false
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.exclusiveZone: -1

    // Process for wlogout command
    Process {
        id: wlogoutProcess
        command: ["wlogout", "-b", "3", "-T", "250", "-B", "250", "-L", "500", "-R", "500", "-c", "40", "-r", "40", "--protocol", "layer-shell"]
        running: false
    }

    // Handle visibility changes and focus
    onVisibleChanged: {
        if (visible) {
            focusScope.forceActiveFocus();
        }
    }

    // Function to close the action center
    function closeActionCenter() {
        ActionCenterManager.closeActionCenter();
    }

    // Focus scope for keyboard handling
    FocusScope {
        id: focusScope
        anchors.fill: parent
        focus: actionCenterWindow.visible

        // Global keyboard handler for escape key
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                closeActionCenter();
                event.accepted = true;
            }
        }

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

                        // Header button row
                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            // Power button
                            Rectangle {
                                width: 32
                                height: 32
                                radius: Appearance.rounding.normal
                                color: powerMouseArea.containsMouse ? Qt.alpha("#938f99", 0.15) : "transparent"

                                Widgets.MaterialIcon {
                                    anchors.centerIn: parent
                                    text: "power_settings_new"
                                    font.pointSize: Appearance.font.size.iconMedium
                                    color: Colours.semantic.textPrimary
                                }

                                MouseArea {
                                    id: powerMouseArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        wlogoutProcess.running = true;
                                    }
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 200
                                        easing.type: Easing.OutQuad
                                    }
                                }
                            }

                            // Settings button
                            Rectangle {
                                width: 32
                                height: 32
                                radius: Appearance.rounding.normal
                                color: settingsIconMouseArea.containsMouse ? Qt.alpha("#938f99", 0.15) : "transparent"

                                Widgets.MaterialIcon {
                                    anchors.centerIn: parent
                                    text: "settings"
                                    font.pointSize: Appearance.font.size.iconMedium
                                    color: Colours.semantic.textPrimary
                                }

                                MouseArea {
                                    id: settingsIconMouseArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        SettingsManager.showSettingsWindow();
                                    }
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 200
                                        easing.type: Easing.OutQuad
                                    }
                                }
                            }

                            // Close button
                            Rectangle {
                                width: 32
                                height: 32
                                radius: Appearance.rounding.normal
                                color: closeButtonMouseArea.containsMouse ? Qt.alpha("#938f99", 0.15) : "transparent"

                                Widgets.MaterialIcon {
                                    anchors.centerIn: parent
                                    text: "close"
                                    font.pointSize: Appearance.font.size.iconMedium
                                    color: Colours.semantic.textPrimary
                                }

                                MouseArea {
                                    id: closeButtonMouseArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        closeActionCenter();
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

                    // Separator
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Qt.alpha("#938f99", 0.3)
                    }

                    // Notifications Section
                    Rectangle {
                        width: parent.width
                        height: 480
                        color: Qt.alpha("#938f99", 0.05)
                        radius: Appearance.rounding.larger
                        border.width: 1
                        border.color: Qt.alpha("#938f99", 0.1)

                        NotificationHistoryContent {
                            anchors.fill: parent
                            anchors.margins: 16
                            showHeader: false  // Don't show header since we're in Action Center
                            compactMode: true  // Use compact mode for Action Center
                        }
                    }
                }
            }
        }
    }
}
