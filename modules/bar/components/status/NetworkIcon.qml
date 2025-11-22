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

    // Direct property bindings to NetworkManager computed properties
    readonly property bool isConnected: NetworkManager.isConnected
    readonly property string ssid: NetworkManager.activeSSID
    readonly property int signalStrength: NetworkManager.signalStrength

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
}
