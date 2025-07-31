pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Io
import "../../widgets" as Widgets

Rectangle {
    id: root

    implicitWidth: 44
    implicitHeight: iconsColumn.implicitHeight + 16
    radius: 17

    color: Qt.alpha("#d0bcff", 0.05)
    border.width: 1
    border.color: Qt.alpha("#938f99", 0.08)

    // Subtle background gradient
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Qt.alpha("#d0bcff", 0.02)
            }
            GradientStop {
                position: 1.0
                color: "transparent"
            }
        }
    }

    Column {
        id: iconsColumn
        anchors.centerIn: parent
        spacing: 12

        // Network Icon (icon only, no text)
        Rectangle {
            id: networkRect
            width: 36
            height: 36
            radius: 12
            anchors.horizontalCenter: parent.horizontalCenter
            color: networkHover.containsMouse ? Qt.alpha("#d0bcff", 0.12) : "transparent"

            property string connectionStatus: "disconnected"
            property string ssid: ""
            property int signalStrength: 0
            property bool isConnected: connectionStatus === "connected"

            // Network monitoring
            Timer {
                interval: 10000
                running: true
                repeat: true
                onTriggered: networkRect.checkNetworkStatus()
            }

            Process {
                id: networkProcess
                command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi"]
                running: false

                stdout: StdioCollector {
                    onStreamFinished: networkRect.parseNetworkOutput(text)
                }
            }

            function checkNetworkStatus() {
                networkProcess.running = true;
            }

            function parseNetworkOutput(output) {
                const lines = output.trim().split('\n');
                let connected = false;
                let activeSSID = "";
                let signal = 0;

                for (let line of lines) {
                    const parts = line.split(':');
                    if (parts.length >= 3 && parts[0] === 'yes') {
                        connected = true;
                        activeSSID = parts[1];
                        signal = parseInt(parts[2]) || 0;
                        break;
                    }
                }

                connectionStatus = connected ? "connected" : "disconnected";
                ssid = activeSSID;
                signalStrength = signal;
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }

            MouseArea {
                id: networkHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }

            Widgets.MaterialIcon {
                anchors.centerIn: parent
                animate: true

                text: {
                    if (!parent.isConnected)
                        return "wifi_off";
                    if (parent.signalStrength >= 75)
                        return "signal_wifi_4_bar";
                    if (parent.signalStrength >= 50)
                        return "network_wifi_3_bar";
                    if (parent.signalStrength >= 25)
                        return "network_wifi_2_bar";
                    return "network_wifi_1_bar";
                }
                color: parent.isConnected ? "#e6e0e9" : "#f2b8b5"
                font.pointSize: 15
                fill: networkHover.containsMouse ? 1 : 0
            }

            Component.onCompleted: checkNetworkStatus()
        }

        // Battery Icon (icon only, no text)
        Rectangle {
            id: batteryRect
            width: 36
            height: 36
            radius: 12
            anchors.horizontalCenter: parent.horizontalCenter
            color: batteryHover.containsMouse ? Qt.alpha("#d0bcff", 0.12) : "transparent"

            property var battery: UPower.displayDevice
            property bool isCharging: !UPower.onBattery
            property int percentage: battery ? Math.round(battery.percentage * 100) : 0
            property bool isLowBattery: percentage < 20 && !isCharging

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }

            MouseArea {
                id: batteryHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }

            Widgets.MaterialIcon {
                id: batteryIcon
                anchors.centerIn: parent
                animate: true

                color: parent.isLowBattery ? "#f2b8b5" : parent.isCharging ? "#a6d4a9" : "#e6e0e9"
                font.pointSize: 18
                fill: batteryHover.containsMouse ? 1 : 0

                text: {
                    if (!parent.battery || !parent.battery.isLaptopBattery)
                        return "battery_unknown";

                    if (parent.isCharging) {
                        if (parent.percentage >= 95)
                            return "battery_charging_full";
                        if (parent.percentage >= 80)
                            return "battery_charging_90";
                        if (parent.percentage >= 60)
                            return "battery_charging_80";
                        if (parent.percentage >= 50)
                            return "battery_charging_60";
                        if (parent.percentage >= 30)
                            return "battery_charging_50";
                        if (parent.percentage >= 20)
                            return "battery_charging_30";
                        return "battery_charging_20";
                    } else {
                        if (parent.percentage >= 95)
                            return "battery_full";
                        if (parent.percentage >= 80)
                            return "battery_6_bar";
                        if (parent.percentage >= 65)
                            return "battery_5_bar";
                        if (parent.percentage >= 50)
                            return "battery_4_bar";
                        if (parent.percentage >= 35)
                            return "battery_3_bar";
                        if (parent.percentage >= 20)
                            return "battery_2_bar";
                        if (parent.percentage >= 10)
                            return "battery_1_bar";
                        return "battery_0_bar";
                    }
                }
            }

            // Low battery warning animation
            SequentialAnimation {
                running: batteryRect.isLowBattery
                loops: Animation.Infinite

                NumberAnimation {
                    target: batteryIcon
                    property: "opacity"
                    from: 1.0
                    to: 0.3
                    duration: 1000
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    target: batteryIcon
                    property: "opacity"
                    from: 0.3
                    to: 1.0
                    duration: 1000
                    easing.type: Easing.InOutSine
                }
            }
        }

        // Volume Icon (icon only, no text)
        Rectangle {
            width: 36
            height: 36
            radius: 12
            anchors.horizontalCenter: parent.horizontalCenter
            color: volumeHover.containsMouse ? Qt.alpha("#d0bcff", 0.12) : "transparent"

            readonly property PwNode sink: Pipewire.defaultAudioSink
            readonly property bool muted: sink?.audio?.muted ?? false
            readonly property real volume: sink?.audio?.volume ?? 0

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }

            MouseArea {
                id: volumeHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (parent.sink?.ready && parent.sink?.audio) {
                        parent.sink.audio.muted = !parent.muted;
                    }
                }
            }

            Widgets.MaterialIcon {
                anchors.centerIn: parent
                animate: true

                text: parent.muted ? "volume_off" : parent.volume >= 0.66 ? "volume_up" : parent.volume >= 0.33 ? "volume_down" : "volume_mute"
                color: parent.muted ? "#f2b8b5" : "#e6e0e9"
                font.pointSize: 18
                fill: volumeHover.containsMouse ? 1 : 0
            }

            // Audio service tracking
            PwObjectTracker {
                objects: [Pipewire.defaultAudioSink]
            }
        }
    }
}
