pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import "../config"

// Reusable hoverable icon button component
// Consolidates the pattern used in SearchButton, ActionCenterButton, and header buttons
Rectangle {
    id: root

    property string icon: ""
    property string tooltipText: ""
    property bool enabled: true
    property real iconSize: Appearance.font.size.iconMedium
    property color iconColor: Colours.semantic.textPrimary
    property color backgroundColor: "transparent"
    property color hoverColor: Qt.alpha(Colours.m3primary, 0.12)
    property real iconFill: 0
    property bool animateIcon: false
    property bool showIconFillOnHover: false
    
    signal clicked

    implicitWidth: 36
    implicitHeight: 36
    radius: Appearance.rounding.larger
    color: mouseArea.containsMouse && enabled ? hoverColor : backgroundColor

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    MaterialIcon {
        id: iconElement
        anchors.centerIn: parent
        text: root.icon
        color: root.iconColor
        font.pointSize: root.iconSize
        fill: root.showIconFillOnHover ? (mouseArea.containsMouse ? 1 : root.iconFill) : root.iconFill
        animate: root.animateIcon
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.enabled
        onClicked: root.clicked()
    }

    ToolTip {
        visible: mouseArea.containsMouse && root.tooltipText.length > 0
        text: root.tooltipText
        delay: 500
    }
}
