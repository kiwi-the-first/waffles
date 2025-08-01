import QtQuick
import "../../config"

Rectangle {
    id: debugPanel
    width: parent.width
    height: 80
    radius: 12
    color: Qt.alpha("#938f99", 0.05)
    border.width: 1
    border.color: Qt.alpha("#938f99", 0.1)

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "Debug Mode"
            font.family: "JetBrains Mono"
            font.pointSize: 12
            font.weight: Font.Medium
            color: "#e6e0e9"
        }

        Rectangle {
            width: 120
            height: 32
            radius: 8
            color: Appearance.debug.enabled ? "#d0bcff" : Qt.alpha("#938f99", 0.1)
            border.width: 1
            border.color: Appearance.debug.enabled ? "#d0bcff" : Qt.alpha("#938f99", 0.2)

            Text {
                anchors.centerIn: parent
                text: Appearance.debug.enabled ? "Enabled" : "Disabled"
                font.family: "JetBrains Mono"
                font.pointSize: 10
                color: Appearance.debug.enabled ? "#1c1b1f" : "#e6e0e9"
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Appearance.debug.enabled = !Appearance.debug.enabled;
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }
    }
}
