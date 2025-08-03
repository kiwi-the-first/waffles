pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../../../../services"
import "../../../../utils"
import "../../../../widgets" as Widgets
import "../../../../config"

PopupWindow {
    id: networkSelectorWindow

    // Debug: Test NetworkManager availability on component creation
    Component.onCompleted: {
        DebugUtils.debug("NetworkSelectorWindow created");
        DebugUtils.log("NetworkManager available:", typeof NetworkManager);
        DebugUtils.log("NetworkManager.scanNetworks:", typeof NetworkManager.scanNetworks);
        DebugUtils.log("NetworkManager.isScanning:", NetworkManager.isScanning);
    }

    implicitWidth: 300
    implicitHeight: Math.max(280, Math.min(400, networkList.contentHeight + 120))
    visible: NetworkManager.networkSelectorVisible
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Colours.m3surface
        radius: Appearance.rounding.large
        border.color: Qt.alpha("#938f99", 0.2)
        border.width: 1

        // HoverHandler to detect hover and prevent closing
        HoverHandler {
            id: networkSelectorHover

            onHoveredChanged: {
                if (NetworkManager.hoverMode && !passwordDialog.visible) {
                    if (hovered) {
                        NetworkManager.networkSelectorHovered = true;
                        NetworkManager.stopHideTimer();
                    } else {
                        NetworkManager.networkSelectorHovered = false;
                        NetworkManager.startHideTimer();
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
            shadowColor: Colours.alpha(Colours.m3shadow, 0.25)
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Widgets.MaterialIcon {
                    text: "wifi"
                    color: Colours.m3primary
                    font.pointSize: Appearance.font.size.larger
                }

                Widgets.StyledText {
                    text: "Wi-Fi Networks"
                    font.pointSize: Appearance.font.size.medium
                    font.weight: Font.Medium
                    color: Colours.m3onSurface
                    Layout.fillWidth: true
                }

                // Refresh button
                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: Appearance.rounding.normal
                    color: refreshButton.containsMouse ? Colours.alpha(Colours.m3primary, 0.12) : "transparent"
                    border.color: refreshButton.containsMouse ? Colours.m3primary : "transparent"  // Debug border
                    border.width: 1

                    // Try multiple icon approaches
                    Item {
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        z: 1  // Lower z-index than MouseArea

                        // Primary icon attempt
                        Widgets.MaterialIcon {
                            id: refreshIcon
                            anchors.centerIn: parent
                            text: "refresh"  // Back to standard name
                            color: Colours.m3primary
                            font.pointSize: Appearance.font.size.larger
                            visible: text.length > 0

                            // Ensure the icon has a fixed size for proper rotation
                            width: 20
                            height: 20

                            // Use rotation property directly instead of transform
                            property real rotationAngle: 0
                            rotation: rotationAngle

                            // Simple and reliable rotation animation
                            RotationAnimator {
                                id: refreshAnimation
                                target: refreshIcon
                                from: 0
                                to: 360
                                duration: 2000  // Slower animation to see it better
                                running: NetworkManager.isScanning
                                loops: Animation.Infinite

                                onRunningChanged: {
                                    DebugUtils.log("RotationAnimator running changed to:", running);
                                    DebugUtils.log("Current rotation:", refreshIcon.rotation);
                                }

                                onStarted: {
                                    DebugUtils.log("Animation started!");
                                }

                                onStopped: {
                                    DebugUtils.log("Animation stopped!");
                                }
                            }
                        }

                        // Fallback text if icon fails
                        Text {
                            id: fallbackIcon
                            anchors.centerIn: parent
                            text: "⟳"  // Unicode refresh symbol
                            color: Colours.m3primary
                            font.pointSize: Appearance.font.size.larger
                            visible: !refreshIcon.visible || refreshIcon.text.length === 0

                            width: 20
                            height: 20

                            RotationAnimator {
                                target: fallbackIcon
                                from: 0
                                to: 360
                                duration: 2000
                                running: NetworkManager.isScanning && fallbackIcon.visible
                                loops: Animation.Infinite
                            }
                        }

                        // Debug: log when scanning state changes
                        Connections {
                            target: NetworkManager
                            function onIsScanningChanged() {
                                DebugUtils.log("NetworkManager.isScanning changed to:", NetworkManager.isScanning);
                                DebugUtils.log("Refresh animation running:", refreshAnimation.running);
                            }
                        }
                    }

                    MouseArea {
                        id: refreshButton
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        z: 10  // Ensure it's on top

                        onClicked: {
                            DebugUtils.log("=== REFRESH BUTTON CLICKED ===");
                            DebugUtils.log("Before scan - isScanning:", NetworkManager.isScanning);
                            DebugUtils.log("NetworkManager object:", NetworkManager);
                            NetworkManager.scanNetworks();
                            DebugUtils.log("After scan call - isScanning:", NetworkManager.isScanning);
                        }

                        onPressed: {
                            DebugUtils.log("Refresh button pressed!");
                        }

                        onEntered: {
                            DebugUtils.log("Mouse entered refresh button");
                        }

                        onExited: {
                            DebugUtils.log("Mouse exited refresh button");
                        }
                    }
                }
            }

            // Network list
            ScrollView {
                id: scrollView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: networkList
                    model: NetworkManager.availableNetworks
                    spacing: 4

                    delegate: Rectangle {
                        id: networkDelegate
                        width: networkList.width
                        height: 48
                        radius: Appearance.rounding.normal
                        color: {
                            if (networkDelegate.networkData.isActive) {
                                return Colours.alpha(Colours.m3primary, 0.15);
                            } else if (networkMouseArea.containsMouse) {
                                return Colours.alpha(Colours.m3primary, 0.08);
                            } else {
                                return "transparent";
                            }
                        }
                        border.color: "transparent"
                        border.width: 0

                        required property var modelData
                        property var networkData: modelData

                        MouseArea {
                            id: networkMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                if (networkDelegate.networkData.isSecure && !networkDelegate.networkData.isActive && !networkDelegate.networkData.hasSavedCredentials) {
                                    // Show password dialog only for secure networks without saved credentials
                                    passwordDialog.ssid = networkDelegate.networkData.ssid;
                                    passwordDialog.visible = true;
                                } else {
                                    // Connect directly to:
                                    // - Open networks
                                    // - Networks that are already active
                                    // - Secure networks with saved credentials
                                    NetworkManager.connectToNetwork(networkDelegate.networkData.ssid, "");
                                }
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            // Network name
                            Widgets.StyledText {
                                text: networkDelegate.networkData.ssid
                                font.pointSize: Appearance.font.size.normal
                                color: networkDelegate.networkData.isActive ? Colours.m3primary : Colours.m3onSurface
                                font.weight: networkDelegate.networkData.isActive ? Font.Medium : Font.Normal
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            // Connected indicator (moved to leftmost position)
                            Widgets.MaterialIcon {
                                text: "check_circle"
                                color: Colours.m3primary
                                font.pointSize: Appearance.font.size.normal
                                visible: networkDelegate.networkData.isActive
                            }

                            // Security icon
                            Widgets.MaterialIcon {
                                text: networkDelegate.networkData.isSecure ? "lock" : "lock_open"
                                color: networkDelegate.networkData.isSecure ? Colours.m3onSurfaceVariant : Colours.alpha(Colours.m3onSurfaceVariant, 0.6)
                                font.pointSize: Appearance.font.size.normal
                                visible: true
                            }

                            // Saved credentials indicator
                            Widgets.MaterialIcon {
                                text: "bookmark"
                                color: Colours.m3primary
                                font.pointSize: Appearance.font.size.small
                                visible: networkDelegate.networkData.hasSavedCredentials && !networkDelegate.networkData.isActive
                            }

                            // Signal strength icon
                            Widgets.MaterialIcon {
                                text: {
                                    if (networkDelegate.networkData.signal >= 75)
                                        return "signal_wifi_4_bar";
                                    if (networkDelegate.networkData.signal >= 50)
                                        return "network_wifi_3_bar";
                                    if (networkDelegate.networkData.signal >= 25)
                                        return "network_wifi_2_bar";
                                    return "network_wifi_1_bar";
                                }
                                color: networkDelegate.networkData.isActive ? Colours.m3primary : Colours.m3onSurfaceVariant
                                font.pointSize: Appearance.font.size.normal
                            }
                        }
                    }
                }
            }

            // Empty state
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: NetworkManager.availableNetworks.length === 0 && !NetworkManager.isScanning

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Widgets.MaterialIcon {
                        text: "wifi_off"
                        color: Colours.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.larger
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Widgets.StyledText {
                        text: "No networks found"
                        color: Colours.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.normal
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Loading state
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: NetworkManager.isScanning && NetworkManager.availableNetworks.length === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Widgets.MaterialIcon {
                        id: loadingIcon
                        text: "wifi"
                        color: Colours.m3primary
                        font.pointSize: Appearance.font.size.larger
                        Layout.alignment: Qt.AlignHCenter

                        SequentialAnimation {
                            running: loadingIcon.parent.parent.visible
                            loops: Animation.Infinite
                            PropertyAnimation {
                                target: loadingIcon
                                property: "opacity"
                                from: 1.0
                                to: 0.3
                                duration: 1000
                            }
                            PropertyAnimation {
                                target: loadingIcon
                                property: "opacity"
                                from: 0.3
                                to: 1.0
                                duration: 1000
                            }
                        }
                    }

                    Widgets.StyledText {
                        text: "Scanning for networks..."
                        color: Colours.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.normal
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }

    // Password dialog for secure networks
    Rectangle {
        id: passwordDialog
        anchors.fill: parent
        color: Colours.alpha(Colours.m3surface, 0.9)
        radius: Appearance.rounding.large
        visible: false

        property string ssid: ""

        // When password dialog becomes visible, stop any hide timers
        onVisibleChanged: {
            if (visible) {
                NetworkManager.stopHideTimer();
                NetworkManager.networkSelectorHovered = true;
                NetworkManager.passwordDialogVisible = true;
            } else {
                NetworkManager.passwordDialogVisible = false;
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: passwordDialog.visible = false
        }

        Rectangle {
            anchors.centerIn: parent
            width: Math.min(250, parent.width - 40)
            height: 160
            color: Colours.m3surface
            radius: Appearance.rounding.normal
            border.color: Qt.alpha("#938f99", 0.2)
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                Widgets.StyledText {
                    text: "Connect to " + passwordDialog.ssid
                    font.pointSize: Appearance.font.size.medium
                    font.weight: Font.Medium
                    color: Colours.m3onSurface
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    placeholderText: "Password"
                    echoMode: TextInput.Password
                    font.pointSize: Appearance.font.size.normal
                    color: Colours.m3onSurface

                    background: Rectangle {
                        color: Colours.alpha(Colours.m3onSurface, 0.04)
                        radius: Appearance.rounding.small
                        border.color: passwordField.activeFocus ? Colours.m3primary : Colours.alpha(Colours.m3onSurface, 0.2)
                        border.width: 1
                    }

                    Keys.onReturnPressed: connectButton.clicked()

                    // When the parent dialog becomes visible, this field should get focus
                    Connections {
                        target: passwordDialog
                        function onVisibleChanged() {
                            if (passwordDialog.visible) {
                                // Use a timer to ensure the dialog is fully rendered before requesting focus
                                Qt.callLater(() => passwordField.forceActiveFocus());
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 32
                        radius: Appearance.rounding.small
                        color: cancelButton.containsMouse ? Colours.alpha(Colours.m3error, 0.12) : "transparent"

                        MouseArea {
                            id: cancelButton
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                passwordField.text = "";
                                passwordDialog.visible = false;
                            }
                        }

                        Widgets.StyledText {
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: Colours.m3error
                            font.pointSize: Appearance.font.size.small
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 32
                        radius: Appearance.rounding.small
                        color: connectButton.containsMouse ? Colours.alpha(Colours.m3primary, 0.12) : Colours.alpha(Colours.m3primary, 0.08)

                        MouseArea {
                            id: connectButton
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                NetworkManager.connectToNetwork(passwordDialog.ssid, passwordField.text);
                                passwordField.text = "";
                                passwordDialog.visible = false;
                                NetworkManager.networkSelectorVisible = false;
                            }
                        }

                        Widgets.StyledText {
                            anchors.centerIn: parent
                            text: "Connect"
                            color: Colours.m3primary
                            font.pointSize: Appearance.font.size.small
                            font.weight: Font.Medium
                        }
                    }
                }
            }
        }
    }
}
