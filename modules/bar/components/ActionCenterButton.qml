import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import "../../../services"
import "../../../widgets" as Widgets
import "../../../config"
import qs.modules.actioncenter

Rectangle {
    id: root

    implicitWidth: 44
    implicitHeight: 36
    radius: Appearance.rounding.larger

    color: buttonHover.containsMouse ? Qt.alpha(Colours.semantic.accent, 0.12) : "transparent"
    border.width: 1
    border.color: Qt.alpha("#938f99", 0.08)

    property bool expanded: ActionCenterManager.actionCenterVisible

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    MouseArea {
        id: buttonHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            ActionCenterManager.toggleActionCenter();
        }

        onEntered: {
            if (ActionCenterManager.hoverMode) {
                ActionCenterManager.stopHideTimer(); // Cancel any pending hide
                ActionCenterManager.showActionCenter();
            }
        }

        onExited: {
            if (ActionCenterManager.hoverMode) {
                ActionCenterManager.startHideTimer(); // Start delay before hiding
            }
        }
    }

    Widgets.MaterialIcon {
        anchors.centerIn: parent
        // text: root.expanded ? "keyboard_arrow_left" : "keyboard_arrow_right"
        text: root.expanded ? "close_fullscreen" : "dashboard_customize"
        color: Colours.semantic.textPrimary
        font.pointSize: Appearance.font.size.iconMedium
        fill: buttonHover.containsMouse ? 1 : 0
        animate: true

        Behavior on rotation {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }
}
