pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import "../../../../widgets" as Widgets
import "../../../../utils"
import "../../../../config"
import "../../../../services"
import "../widgets" as StatusWidgets

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

    // Get network status from NetworkManager instead of scanning separately
    function updateFromNetworkManager() {
        let connected = false;
        let activeSSID = "";
        let signal = 0;

        // Find the active network from NetworkManager's data
        for (let network of NetworkManager.availableNetworks) {
            if (network.isActive) {
                connected = true;
                activeSSID = network.ssid;
                signal = network.signal;
                break;
            }
        }

        connectionStatus = connected ? "connected" : "disconnected";
        ssid = activeSSID;
        signalStrength = signal;
    }

    // Listen for changes in NetworkManager's network list
    Connections {
        target: NetworkManager
        function onAvailableNetworksChanged() {
            networkRect.updateFromNetworkManager();
        }
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

        onEntered: {
            if (NetworkManager.hoverMode) {
                NetworkManager.showNetworkSelector();
            }
        }

        onExited: {
            if (NetworkManager.hoverMode) {
                NetworkManager.startHideTimer();
            }
        }

        onClicked: {
            if (!NetworkManager.hoverMode) {
                NetworkManager.networkSelectorVisible = !NetworkManager.networkSelectorVisible;
            }
        }
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

    Component.onCompleted: networkRect.updateFromNetworkManager()
}
