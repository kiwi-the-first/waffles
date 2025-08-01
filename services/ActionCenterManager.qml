pragma Singleton
import QtQuick
import Quickshell
import "../modules/common"

QtObject {
    id: root

    property bool actionCenterVisible: false
    property bool hoverMode: true  // Will be updated by InteractionSettings binding
    property bool actionCenterHovered: false  // Track if action center is being hovered

    // Bind to global settings when available
    Component.onCompleted: {
        if (typeof InteractionSettings !== 'undefined') {
            hoverMode = Qt.binding(() => InteractionSettings.actionCenterHoverMode);
        }
    }

    property Timer hideTimer: Timer {
        interval: 200  // Same as calendar for consistency
        onTriggered: {
            if (root.hoverMode && !root.actionCenterHovered) {
                root.actionCenterVisible = false;
            }
        }
    }

    function toggleActionCenter() {
        if (!hoverMode) {
            actionCenterVisible = !actionCenterVisible;
        }
    }

    function showActionCenter() {
        hideTimer.stop();
        actionCenterVisible = true;
    }

    function hideActionCenter() {
        if (!actionCenterHovered) {
            actionCenterVisible = false;
        }
    }

    function startHideTimer() {
        hideTimer.restart();
    }

    function stopHideTimer() {
        hideTimer.stop();
    }

    function closeActionCenter() {
        actionCenterVisible = false;
    }
}
