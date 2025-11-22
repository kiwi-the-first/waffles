pragma ComponentBehavior: Bound
import QtQuick
import "status" as Status
import "../../../config"

Rectangle {
    id: root

    implicitWidth: 44
    implicitHeight: iconsColumn.implicitHeight + 16
    radius: Appearance.rounding.large

    color: Qt.alpha(Colours.m3primary, 0.05)
    border.width: 1
    border.color: Qt.alpha(Colours.m3outline, 0.08)

    // Subtle background gradient
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Qt.alpha(Colours.m3primary, 0.02)
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

        Status.NetworkIcon {
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Status.VolumeIcon {
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Status.BatteryIcon {
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Status.PowerProfileIcon {
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
