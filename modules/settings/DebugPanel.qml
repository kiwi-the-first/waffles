import QtQuick
import "../../config"

Rectangle {
    id: debugPanel
    width: parent.width
    height: 80
    radius: Appearance.rounding.larger
    color: Colours.alpha(Colours.m3outline, 0.05)
    border.width: 1
    border.color: Colours.alpha(Colours.m3outline, 0.1)

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "Debug Mode"
            font.family: Appearance.font.family.display
            font.pointSize: Appearance.font.size.body
            font.weight: Font.Medium
            color: Colours.semantic.textPrimary
        }

        Rectangle {
            width: 120
            height: 32
            radius: Appearance.rounding.normal
            color: Appearance.debug.enabled ? Colours.m3primary : Colours.alpha(Colours.m3outline, 0.1)
            border.width: 1
            border.color: Appearance.debug.enabled ? Colours.m3primary : Colours.alpha(Colours.m3outline, 0.2)

            Text {
                anchors.centerIn: parent
                text: Appearance.debug.enabled ? "Enabled" : "Disabled"
                font.family: Appearance.font.family.display
                font.pointSize: Appearance.font.size.smaller
                color: Appearance.debug.enabled ? Colours.m3surface : Colours.m3onSurface
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
