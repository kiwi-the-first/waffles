import QtQuick
import QtQuick.Controls
import "../common"
import "../../widgets" as Widgets
import "../../config"

Rectangle {
    id: settingsPanel
    width: parent.width
    height: 120
    radius: Appearance.rounding.larger
    color: Colours.alpha(Colours.m3outline, 0.05)
    border.width: 1
    border.color: Colours.alpha(Colours.m3outline, 0.1)

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "Interaction Mode"
            font.family: Appearance.font.family.display
            font.pointSize: Appearance.font.size.body
            font.weight: Font.Medium
            color: Colours.semantic.textPrimary
        }

        Row {
            spacing: 16

            Rectangle {
                width: 100
                height: 32
                radius: Appearance.rounding.normal
                color: InteractionSettings.hoverMode ? Colours.m3primary : Colours.alpha(Colours.m3outline, 0.1)
                border.width: 1
                border.color: InteractionSettings.hoverMode ? Colours.m3primary : Colours.alpha(Colours.m3outline, 0.2)

                Text {
                    anchors.centerIn: parent
                    text: "Hover"
                    font.family: Appearance.font.family.display
                    font.pointSize: Appearance.font.size.smaller
                    color: InteractionSettings.hoverMode ? Colours.m3surface : Colours.m3onSurface
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        InteractionSettings.setGlobalHoverMode(true);
                    }
                }
            }

            Rectangle {
                width: 100
                height: 32
                radius: Appearance.rounding.normal
                color: !InteractionSettings.hoverMode ? Colours.m3primary : Colours.alpha(Colours.m3outline, 0.1)
                border.width: 1
                border.color: !InteractionSettings.hoverMode ? Colours.m3primary : Colours.alpha(Colours.m3outline, 0.2)

                Text {
                    anchors.centerIn: parent
                    text: "Click"
                    font.family: Appearance.font.family.display
                    font.pointSize: Appearance.font.size.smaller
                    color: !InteractionSettings.hoverMode ? Colours.m3surface : Colours.m3onSurface
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        InteractionSettings.setGlobalHoverMode(false);
                    }
                }
            }
        }

        Text {
            text: InteractionSettings.hoverMode ? "Widgets open on mouse hover" : "Widgets open on mouse click"
            font.family: Appearance.font.family.display
            font.pointSize: Appearance.font.size.small
            color: Colours.alpha(Colours.m3outline, 0.8)
        }
    }
}
