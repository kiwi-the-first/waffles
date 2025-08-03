pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import "../../../../widgets" as Widgets
import "../../../../utils"
import "../../../../config"

Rectangle {
    id: networkRect
    width: 36
    height: 36
    radius: Appearance.rounding.larger
    color: networkHover.containsMouse ? Colours.alpha(Colours.m3primary, 0.12) : "transparent"

    property string connectionStatus: "disconnected"
    property string ssid: ""
    property int signalStrength: 0
    property bool isConnected: connectionStatus === "connected"

    // Network monitoring
    Timer {
        interval: 60000  // Check every minute
        running: true
        repeat: true
        onTriggered: networkRect.checkNetworkStatus()
    }

    property var networkProcess: null

    function checkNetworkStatus() {
        DebugUtils.log("NetworkIcon: Checking network status");

        if (networkProcess) {
            networkProcess.destroy();
        }

        networkProcess = Qt.createQmlObject(`
            import QtQuick
            import Quickshell.Io
            Process {
                command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        networkRect.parseNetworkOutput(text);
                    }
                }

                stderr: StdioCollector {
                    onStreamFinished: {
                        if (text.length > 0) {
                            DebugUtils.error("NetworkIcon: Network error:", text);
                        }
                    }
                }
            }
        `, networkRect);
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

        DebugUtils.log("NetworkIcon:", connectionStatus === "connected" ? `Connected to ${ssid} (${signalStrength}%)` : "Disconnected");
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
        color: parent.isConnected ? Colours.m3onSurface : Colours.m3error
        font.pointSize: Appearance.font.size.larger
        fill: networkHover.containsMouse ? 1 : 0
    }

    Component.onCompleted: checkNetworkStatus()
}
