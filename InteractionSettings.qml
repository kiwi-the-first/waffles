pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: root

    // Global interaction mode - true for hover, false for click/toggle
    property bool hoverMode: true  // Default to hover mode for both calendar and action center

    // Individual overrides (optional - defaults to global setting)
    property bool calendarHoverMode: hoverMode
    property bool actionCenterHoverMode: hoverMode

    function setGlobalHoverMode(enabled) {
        hoverMode = enabled;
        // Update individual modes to match global setting
        calendarHoverMode = enabled;
        actionCenterHoverMode = enabled;
    }

    function setCalendarMode(enabled) {
        calendarHoverMode = enabled;
    }

    function setActionCenterMode(enabled) {
        actionCenterHoverMode = enabled;
    }
}
