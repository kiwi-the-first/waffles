pragma Singleton
import QtQuick

QtObject {
    id: root

    property bool settingsWindowVisible: false
    property bool settingsWindowHovered: false

    function showSettingsWindow() {
        settingsWindowVisible = true;
    }

    function hideSettingsWindow() {
        settingsWindowVisible = false;
    }

    function toggleSettingsWindow() {
        settingsWindowVisible = !settingsWindowVisible;
    }
}
