import QtQuick
import QtQuick.Effects
import "../../../widgets"
import "../../../services"
import "../../../config"

Rectangle {
    id: searchButton

    width: 36
    height: 36
    radius: Appearance.rounding.large
    color: mouseArea.containsMouse ? Qt.alpha(Colours.semantic.accent, 0.12) : Qt.alpha(Colours.semantic.accent, 0.08)
    border.width: 1
    border.color: Qt.alpha(Colours.semantic.accent, 0.2)

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
        color: Colours.semantic.accent
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
        shadowColor: Qt.alpha(Colours.semantic.accent, 0.4)
    }
}
