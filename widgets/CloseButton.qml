pragma ComponentBehavior: Bound

import QtQuick
import "../config"

// Reusable close button component
// Used across multiple windows and popups
Rectangle {
    id: root

    property color iconColor: Colours.semantic.textPrimary
    property color hoverColor: Qt.alpha("#938f99", 0.15)
    property color normalColor: "transparent"
    property real iconSize: Appearance.font.size.iconMedium
    
    signal clicked

    width: 32
    height: 32
    radius: Appearance.rounding.normal
    color: mouseArea.containsMouse ? hoverColor : normalColor

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    MaterialIcon {
        anchors.centerIn: parent
        text: "close"
        font.pointSize: root.iconSize
        color: root.iconColor
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
