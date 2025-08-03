import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import "../../../../widgets"
import "../../../../services"
import "../../../../config"

PopupWindow {
    id: osdWindow

    implicitWidth: 240  // 25% smaller (320 * 0.75)
    implicitHeight: 66
    visible: false
    color: "transparent"

    Rectangle {
        id: content
        anchors.fill: parent
        color: Colours.semantic.backgroundElevated  // Material Design 3 Surface Container High
        radius: 33  // Pill shape (half of height: 66/2)
        // border removed for cleaner look

        scale: osdWindow.visible ? 1.0 : 0.95
        opacity: osdWindow.visible ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation {
                duration: Appearance.anim.durations.small
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.anim.durations.small
                easing.type: Easing.OutCubic
            }
        }

        // Simple shadow effect using a background rectangle
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            color: "transparent"
            radius: parent.radius + 2
            border.color: Qt.alpha("#000000", 0.1)
            border.width: 2
            z: -1
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: OSDManager.hovered = true
            onExited: OSDManager.hovered = false
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Appearance.padding.large
            anchors.topMargin: Appearance.padding.large
            anchors.bottomMargin: Appearance.padding.large
            anchors.rightMargin: Appearance.padding.large + 8  // Extra padding on the right
            spacing: Appearance.spacing.normal

            // Volume indicator (shown when volume changes)
            Item {
                id: volumeIndicator
                visible: OSDManager.osdVisible && OSDManager.currentType === "volume"
                Layout.fillWidth: true
                Layout.fillHeight: true

                RowLayout {
                    anchors.fill: parent
                    spacing: Appearance.spacing.normal

                    // Volume icon using Material Design icons
                    MaterialIcon {
                        Layout.alignment: Qt.AlignVCenter
                        text: {
                            if (Audio.muted)
                                return "volume_off";
                            if (Audio.volume >= 0.7)
                                return "volume_up";
                            if (Audio.volume > 0.3)
                                return "volume_down";
                            return "volume_mute";
                        }
                        font.pointSize: Appearance.font.size.iconXLarge
                        color: Colours.semantic.textPrimary  // Material Design 3 On Surface
                        fill: 1.0
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.spacing.small

                        RowLayout {
                            Layout.fillWidth: true

                            StyledText {
                                text: "Volume"
                                font.pointSize: Appearance.font.size.normal
                                color: Colours.semantic.textPrimary  // Material Design 3 On Surface
                                Layout.fillWidth: true
                            }

                            StyledText {
                                text: Math.round(Audio.volume * 100)
                                font.pointSize: Appearance.font.size.normal
                                font.weight: Font.Medium
                                color: Colours.semantic.textPrimary  // Material Design 3 On Surface
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 4
                            radius: Appearance.rounding.tiny
                            color: Colours.semantic.backgroundSurface  // Material Design 3 Surface Variant

                            Rectangle {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width * Audio.volume
                                height: parent.height
                                radius: parent.radius
                                color: Colours.semantic.accent  // Material Design 3 Primary

                                Behavior on width {
                                    NumberAnimation {
                                        duration: Appearance.anim.durations.normal
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Brightness indicator (shown when brightness changes)
            Item {
                id: brightnessIndicator
                visible: OSDManager.osdVisible && OSDManager.currentType === "brightness"
                Layout.fillWidth: true
                Layout.fillHeight: true

                RowLayout {
                    anchors.fill: parent
                    spacing: Appearance.spacing.normal

                    // Brightness icon using Material Design icons
                    MaterialIcon {
                        Layout.alignment: Qt.AlignVCenter
                        text: "light_mode"
                        font.pointSize: Appearance.font.size.iconXLarge
                        color: Colours.semantic.textPrimary  // Material Design 3 On Surface
                        fill: 1.0
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.spacing.small

                        RowLayout {
                            Layout.fillWidth: true

                            StyledText {
                                text: "Brightness"
                                font.pointSize: Appearance.font.size.normal
                                color: Colours.semantic.textPrimary  // Material Design 3 On Surface
                                Layout.fillWidth: true
                            }

                            StyledText {
                                text: Brightness.monitors[0] ? Math.round(Brightness.monitors[0].brightness * 100) : "50"
                                font.pointSize: Appearance.font.size.normal
                                font.weight: Font.Medium
                                color: Colours.semantic.textPrimary  // Material Design 3 On Surface
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 4
                            radius: Appearance.rounding.tiny
                            color: Colours.semantic.backgroundSurface  // Material Design 3 Surface Variant

                            Rectangle {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width * (Brightness.monitors[0] ? Brightness.monitors[0].brightness : 0.5)
                                height: parent.height
                                radius: parent.radius
                                color: Colours.m3tertiary  // Material Design 3 Tertiary

                                Behavior on width {
                                    NumberAnimation {
                                        duration: Appearance.anim.durations.normal
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
