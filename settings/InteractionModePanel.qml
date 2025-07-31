import QtQuick
import QtQuick.Controls
import "../widgets" as Widgets
import ".." as Root

Rectangle {
    id: settingsPanel
    width: parent.width
    height: 120
    radius: 12
    color: Qt.alpha("#938f99", 0.05)
    border.width: 1
    border.color: Qt.alpha("#938f99", 0.1)

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "Interaction Mode"
            font.family: "JetBrains Mono"
            font.pointSize: 12
            font.weight: Font.Medium
            color: "#e6e0e9"
        }

        Row {
            spacing: 16

            Rectangle {
                width: 100
                height: 32
                radius: 8
                color: Root.InteractionSettings.hoverMode ? "#d0bcff" : Qt.alpha("#938f99", 0.1)
                border.width: 1
                border.color: Root.InteractionSettings.hoverMode ? "#d0bcff" : Qt.alpha("#938f99", 0.2)

                Text {
                    anchors.centerIn: parent
                    text: "Hover"
                    font.family: "JetBrains Mono"
                    font.pointSize: 10
                    color: Root.InteractionSettings.hoverMode ? "#1c1b1f" : "#e6e0e9"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Root.InteractionSettings.setGlobalHoverMode(true);
                    }
                }
            }

            Rectangle {
                width: 100
                height: 32
                radius: 8
                color: !Root.InteractionSettings.hoverMode ? "#d0bcff" : Qt.alpha("#938f99", 0.1)
                border.width: 1
                border.color: !Root.InteractionSettings.hoverMode ? "#d0bcff" : Qt.alpha("#938f99", 0.2)

                Text {
                    anchors.centerIn: parent
                    text: "Click"
                    font.family: "JetBrains Mono"
                    font.pointSize: 10
                    color: !Root.InteractionSettings.hoverMode ? "#1c1b1f" : "#e6e0e9"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Root.InteractionSettings.setGlobalHoverMode(false);
                    }
                }
            }
        }

        Text {
            text: Root.InteractionSettings.hoverMode ? "Widgets open on mouse hover" : "Widgets open on mouse click"
            font.family: "JetBrains Mono"
            font.pointSize: 9
            color: Qt.alpha("#938f99", 0.8)
        }
    }
}
