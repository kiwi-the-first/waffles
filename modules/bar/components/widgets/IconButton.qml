import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../widgets" as Widgets
import "../../../../config"

Rectangle {
    id: root

    property string icon: ""
    property string tooltipText: ""
    property bool enabled: true
    property alias iconSize: iconElement.font.pointSize
    property color iconColor: Colours.m3primary
    property color backgroundColor: "transparent"
    property color hoverColor: Qt.rgba(Colours.m3primary.r, Colours.m3primary.g, Colours.m3primary.b, 0.12)

    signal clicked

    Layout.preferredWidth: 32
    Layout.preferredHeight: 32
    radius: Appearance.rounding.normal
    color: mouseArea.containsMouse && enabled ? hoverColor : backgroundColor

    // Smooth color transitions
    Behavior on color {
        ColorAnimation {
            duration: 200
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.enabled
        onClicked: root.clicked()
    }

    Widgets.MaterialIcon {
        id: iconElement
        anchors.centerIn: parent
        text: root.icon
        color: enabled ? root.iconColor : Colours.m3onSurfaceVariant
        font.pointSize: Appearance.font.size.normal

        // Smooth color transitions
        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }

    // Tooltip (if needed)
    ToolTip {
        visible: mouseArea.containsMouse && root.tooltipText.length > 0
        text: root.tooltipText
        delay: 500
    }
}
