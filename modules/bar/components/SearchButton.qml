import QtQuick
import QtQuick.Effects
import "../../../widgets"
import "../../../config"
import "../../../services"

Rectangle {
    id: searchButton

    width: 36
    height: 36
    radius: Appearance.rounding.large
    color: mouseArea.containsMouse ? Qt.alpha(Colours.m3primary, 0.12) : Qt.alpha(Colours.m3primary, 0.08)
    border.width: 1
    border.color: Qt.alpha(Colours.m3primary, 0.2)

    // Hover effect
    Behavior on color {
        ColorAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    // Search icon
    MaterialIcon {
        anchors.centerIn: parent
        text: "search"
        font.pointSize: Appearance.font.size.title
        color: Colours.m3primary
    }

    // Mouse interaction
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            SearchManager.toggleSearch();
        }
    }
}
