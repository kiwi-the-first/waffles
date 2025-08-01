import QtQuick
import QtQuick.Effects
import "../../../widgets"
import "../../../services"

Rectangle {
    id: searchButton

    width: 36
    height: 36
    radius: 18
    color: mouseArea.containsMouse ? Qt.alpha("#d0bcff", 0.12) : Qt.alpha("#d0bcff", 0.08)
    border.width: 1
    border.color: Qt.alpha("#d0bcff", 0.2)

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
        font.pointSize: 16
        color: "#d0bcff"
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

    // Subtle glow effect when active
    layer.enabled: SearchManager.searchVisible
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowBlur: 0.6
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 0
        shadowColor: Qt.alpha("#d0bcff", 0.4)
    }
}
