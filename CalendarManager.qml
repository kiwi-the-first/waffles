pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: root

    property bool calendarVisible: false
    property bool hoverMode: true  // Will be updated by InteractionSettings binding
    property bool calendarHovered: false  // Track if calendar is being hovered

    // Bind to global settings when available
    Component.onCompleted: {
        if (typeof InteractionSettings !== 'undefined') {
            hoverMode = Qt.binding(() => InteractionSettings.calendarHoverMode);
        }
    }

    property Timer hideTimer: Timer {
        interval: 200  // Reduced from test value
        onTriggered: {
            if (root.hoverMode && !root.calendarHovered) {
                root.calendarVisible = false;
            }
        }
    }

    function toggleCalendar() {
        if (!hoverMode) {
            calendarVisible = !calendarVisible;
        }
    }

    function showCalendar() {
        hideTimer.stop();
        calendarVisible = true;
    }

    function hideCalendar() {
        if (!calendarHovered) {
            calendarVisible = false;
        }
    }

    function startHideTimer() {
        hideTimer.restart();
    }

    function stopHideTimer() {
        hideTimer.stop();
    }
}
