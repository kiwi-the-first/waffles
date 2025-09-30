import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Effects
import "components"
import "../../config"

PanelWindow {
    id: panel
    WlrLayershell.namespace: "waffles-bar"

    anchors {
        left: true
        top: true
        bottom: true
    }

    margins {
        top: 10
        bottom: 10
    }

    implicitWidth: 60
    color: "transparent"

    // Main container with rounded background and shadow
    Rectangle {
        id: background
        anchors.fill: parent
        color: Colours.semantic.backgroundMain
        radius: Appearance.rounding.extraLarge  // This will create rounded corners on all sides, but left ones are hidden
        topLeftRadius: Appearance.rounding.none
        bottomLeftRadius: Appearance.rounding.none

        // Subtle shadow effect
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.6
            shadowHorizontalOffset: 2
            shadowVerticalOffset: 0
            shadowColor: Colours.alpha(Colours.m3shadow, 0.3)
        }

        // Workspace indicator at the top
        Workspaces {
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: 20
            }
        }

        // Search button below workspaces
        SearchButton {
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: 80  // Position below workspace indicator
            }
        }

        // Clock centered vertically
        Clock {
            anchors.centerIn: parent
        }

        // System Tray above status components
        SystemTray {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: statusColumn.top
                bottomMargin: 16
            }
        }

        // Status components at the bottom
        Column {
            id: statusColumn
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 20
            }
            spacing: 12

            StatusGroup {}

            Rectangle {
                width: 32
                height: 1
                color: Colours.alpha(Colours.m3outline, 0.3)
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 0.5
            }

            ActionCenterButton {}
        }

        // Subtle inner border for glass effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: 0.5
            color: "transparent"
            border.width: 0.5
            border.color: Colours.alpha(Colours.m3outline, 0.1)
        }
    }
}
