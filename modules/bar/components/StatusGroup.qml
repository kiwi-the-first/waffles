pragma ComponentBehavior: Bound
import QtQuick
import "status" as Status

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

        Status.NetworkIcon {
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Status.BatteryIcon {
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Status.VolumeIcon {
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
