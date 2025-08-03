pragma Singleton
import QtQuick
import Quickshell
import "../../services"

QtObject {
    id: root

    // Global interaction mode - true for hover, false for click/toggle
    property bool hoverMode: PersistentSettings.settings.clickToReveal === false  // Inverse logic: clickToReveal false means hover mode

    // Individual overrides (optional - defaults to global setting)
    property bool calendarHoverMode: hoverMode
    property bool actionCenterHoverMode: hoverMode

    function setGlobalHoverMode(enabled) {
        hoverMode = enabled;
        // Update persistent settings (inverse logic)
        PersistentSettings.settings.clickToReveal = !enabled;
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

    // Watch for changes from persistent settings
    property Connections settingsWatcher: Connections {
        target: PersistentSettings.settings
        function onClickToRevealChanged() {
            root.hoverMode = !PersistentSettings.settings.clickToReveal;
            root.calendarHoverMode = root.hoverMode;
            root.actionCenterHoverMode = root.hoverMode;
        }
    }
}
