pragma Singleton

import QtQuick
import "../config"

QtObject {
    id: root

    // Debug/informational messages - only shown when debug mode is enabled
    function log(message, ...args) {
        if (Appearance.debug.enabled) {
            console.log(message, ...args);
        }
    }

    // Debug messages - only shown when debug mode is enabled
    function debug(message, ...args) {
        if (Appearance.debug.enabled) {
            console.debug(message, ...args);
        }
    }

    // Warning messages - always shown (potential issues users should know about)
    function warn(message, ...args) {
        console.warn(message, ...args);
    }

    // Error messages - always shown (critical issues that need attention)
    function error(message, ...args) {
        console.error(message, ...args);
    }
}
