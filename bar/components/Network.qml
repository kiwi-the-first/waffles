import Quickshell
import Quickshell.Io
import QtQuick
import "../../widgets" as Widgets

Rectangle {
    id: root

    implicitWidth: 44
    implicitHeight: content.implicitHeight + 16
    radius: 17

    color: hoverArea.containsMouse ? Qt.alpha("#d0bcff", 0.08) : "transparent"

    property string connectionStatus: "disconnected"
    property string ssid: ""
    property int signalStrength: 0
    property bool isConnected: connectionStatus === "connected"

    Behavior on color {
        ColorAnimation {
            duration: 400
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    // Timer to periodically check network status
    Timer {
        id: networkTimer
        interval: 60000 // Check every 60 seconds
        running: true
        repeat: true
        onTriggered: root.checkNetworkStatus()
    }

    // Process to check network status
    Process {
        id: networkProcess
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi"]
        running: false

        stdout: StdioCollector {
            id: networkCollector
            onStreamFinished: {
                root.parseNetworkOutput(networkCollector.text);
            }
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

        if (connected) {
            root.connectionStatus = "connected";
            root.ssid = activeSSID;
            root.signalStrength = signal;
        } else {
            root.connectionStatus = "disconnected";
            root.ssid = "";
            root.signalStrength = 0;
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: root.scale = 0.95
        onReleased: root.scale = 1.0
        onCanceled: root.scale = 1.0
    }

    Column {
        id: content
        anchors.centerIn: parent
        spacing: 4

        // WiFi icon based on status
        Widgets.MaterialIcon {
            id: wifiIcon
            anchors.horizontalCenter: parent.horizontalCenter
            animate: true

            text: {
                if (root.isConnected) {
                    if (root.signalStrength >= 75)
                        return "signal_wifi_4_bar";
                    else if (root.signalStrength >= 50)
                        return "network_wifi_3_bar";
                    else if (root.signalStrength >= 25)
                        return "network_wifi_2_bar";
                    else
                        return "network_wifi_1_bar";
                } else {
                    return "wifi_off";
                }
            }

            color: root.isConnected ? "#a6d4a9" : "#f2b8b5"
            font.pointSize: 22
            fill: hoverArea.containsMouse ? 1 : 0

            Behavior on color {
                ColorAnimation {
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                }
            }
        }

        // Connection status text
        Widgets.StyledText {
            id: statusText
            anchors.horizontalCenter: parent.horizontalCenter
            animate: true

            text: {
                if (root.isConnected) {
                    return root.ssid.length > 6 ? root.ssid.substring(0, 6) + "..." : root.ssid;
                } else {
                    return "No WiFi";
                }
            }

            color: root.isConnected ? "#cac4d0" : "#f2b8b5"
            font.pixelSize: 8
            font.family: "JetBrains Mono"
            font.weight: 500

            opacity: hoverArea.containsMouse ? 1.0 : 0.8

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                }
            }
        }
    }

    // Connection attempt animation
    SequentialAnimation {
        running: !root.isConnected
        loops: Animation.Infinite

        NumberAnimation {
            target: wifiIcon
            property: "opacity"
            from: 1.0
            to: 0.3
            duration: 1500
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: wifiIcon
            property: "opacity"
            from: 0.3
            to: 1.0
            duration: 1500
            easing.type: Easing.InOutSine
        }
    }

    Component.onCompleted: {
        root.checkNetworkStatus();
    }
}
