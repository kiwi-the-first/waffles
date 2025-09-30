import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../widgets" as Widgets
import "../../../../config"

Button {
    id: root

    property string iconName: ""
    property color backgroundColor: Colours.m3primary
    property color textColor: Colours.m3onPrimary
    property color hoverColor: Qt.darker(backgroundColor, 1.1)
    property bool outlined: false
    property real fontSize: Appearance.font.size.small

    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: Math.max(32, contentItem.implicitHeight + topPadding + bottomPadding)

    leftPadding: Appearance.spacing.normal
    rightPadding: Appearance.spacing.normal
    topPadding: Appearance.spacing.small
    bottomPadding: Appearance.spacing.small

    background: Rectangle {
        radius: Appearance.rounding.small
        color: {
            if (!root.enabled)
                return Colours.m3surfaceVariant;
            if (root.outlined) {
                return root.hovered ? Qt.rgba(root.backgroundColor.r, root.backgroundColor.g, root.backgroundColor.b, 0.12) : "transparent";
            }
            return root.hovered ? root.hoverColor : root.backgroundColor;
        }
        border.width: root.outlined ? 1 : 0
        border.color: root.outlined ? root.backgroundColor : "transparent"

        // Smooth color transitions
        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 200
            }
        }
    }

    contentItem: RowLayout {
        spacing: Appearance.spacing.small

        Widgets.MaterialIcon {
            visible: root.iconName.length > 0
            text: root.iconName
            font.pointSize: root.fontSize
            color: {
                if (!root.enabled)
                    return Colours.m3onSurfaceVariant;
                if (root.outlined)
                    return root.backgroundColor;
                return root.textColor;
            }

            // Smooth color transitions
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }

        Widgets.StyledText {
            visible: root.text.length > 0
            text: root.text
            font.pointSize: root.fontSize
            color: {
                if (!root.enabled)
                    return Colours.m3onSurfaceVariant;
                if (root.outlined)
                    return root.backgroundColor;
                return root.textColor;
            }

            // Smooth color transitions
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }
    }
}
