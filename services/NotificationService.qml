pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Simplified notification service based on noctalia-shell reference
Singleton {
    id: root

    // Configuration
    property int maxVisible: 4
    property int maxHistory: 200

    // Models for UI binding
    property ListModel activeList: ListModel {}        // Current popup notifications
    property ListModel historyList: ListModel {}      // All notifications for history panel

    // Control properties
    property bool popupsDisabled: false

    // For compatibility with existing popup manager
    readonly property var visibleNotifications: _getVisibleArray()
    readonly property var notifications: _getAllArray()

    // Internal state
    property var activeMap: ({})
    property int _arrayRevision: 0  // Force array updates

    readonly property var _urgency: ({
            "Low": 0,
            "Normal": 1,
            "Critical": 2
        })

    // Auto-dismiss timer like noctalia-shell
    Timer {
        id: progressTimer
        interval: 100  // Update every 100ms for smooth progress
        repeat: true
        running: root.activeList.count > 0
        onTriggered: {
            const now = Date.now();

            for (let i = root.activeList.count - 1; i >= 0; i--) {
                const notif = root.activeList.get(i);
                const elapsed = now - notif.timestamp.getTime();
                const expire = notif.expireTimeout;

                const progress = Math.max(1.0 - (elapsed / expire), 0.0);
                root.activeList.setProperty(i, "progress", progress);

                // Debug logging
                if (elapsed >= expire) {
                    console.log("Removing notification after", elapsed, "ms (expire:", expire, ")");
                }

                // Remove expired notifications
                if (elapsed >= expire) {
                    const notification = root.activeMap[notif.id];
                    if (notification) {
                        try {
                            notification.dismiss();
                        } catch (e) {}
                    }
                    root.removeActive(notif.id);
                }
            }
        }
    }

    // Notification server
    NotificationServer {
        keepOnReload: false
        actionsSupported: true
        imageSupported: true

        onNotification: function (notif) {
            if (notif) {
                root.handleNotification(notif);
            }
        }
    }

    readonly property bool notificationsAvailable: true

    // Force update arrays when model changes
    function _getVisibleArray() {
        _arrayRevision; // Access to trigger updates
        const result = [];
        for (let i = 0; i < activeList.count; i++) {
            result.push(activeList.get(i));
        }
        return result;
    }

    function _getAllArray() {
        _arrayRevision; // Access to trigger updates
        const result = [];
        for (let i = 0; i < historyList.count; i++) {
            result.push(historyList.get(i));
        }
        return result;
    }

    function _updateArrays() {
        _arrayRevision++;
    }

    // Main notification handler
    function handleNotification(notification) {
        if (!notification)
            return;

        notification.tracked = true;

        // Create notification data
        const data = createNotificationData(notification);

        // Add to history first
        addToHistory(data);

        // Add to active notifications if not in DND mode
        if (!popupsDisabled) {
            addToActive(notification, data);
        }
    }

    function createNotificationData(n) {
        const time = new Date();
        // Generate more unique ID using timestamp and random component
        const id = `notif_${time.getTime()}_${Math.random().toString(36).substr(2, 9)}`;

        // Debug: Check what expireTimeout we're getting
        const defaultTimeout = getDefaultTimeout(n.urgency || 1);
        let finalTimeout = defaultTimeout;

        // Handle expireTimeout like noctalia-shell does
        if (n.expireTimeout && n.expireTimeout > 0) {
            finalTimeout = n.expireTimeout;
        }

        console.log("Notification:", n.summary, "expireTimeout:", n.expireTimeout, "urgency:", n.urgency, "final:", finalTimeout);

        return {
            "id": id,
            "summary": n.summary || "",
            "body": stripTags(n.body || ""),
            "appName": getAppName(n.appName || ""),
            "urgency": Math.max(0, Math.min(2, n.urgency || 1)),
            "timestamp": time,
            "popup": true,
            "notification": n // Keep reference for actions
            ,
            "progress": 1.0  // For timeout visualization
            ,
            "expireTimeout": finalTimeout
        };
    }

    function getDefaultTimeout(urgency) {
        // Default timeouts in milliseconds based on urgency
        switch (urgency) {
        case 0:
            return 3000;  // Low urgency: 3 seconds
        case 2:
            return 10000; // Critical: 10 seconds
        default:
            return 6000; // Normal: 6 seconds
        }
    }

    function addToActive(notification, data) {
        // Store notification reference
        activeMap[data.id] = notification;

        // Connect close signal
        notification.closed.connect(() => removeActive(data.id));

        // Add to active list
        activeList.insert(0, data);

        // Limit active notifications
        while (activeList.count > maxVisible) {
            const last = activeList.get(activeList.count - 1);
            if (activeMap[last.id]) {
                try {
                    activeMap[last.id].dismiss();
                } catch (e) {}
            }
            activeList.remove(activeList.count - 1);
        }

        _updateArrays();
    }

    function addToHistory(data) {
        historyList.insert(0, data);

        // Limit history size
        while (historyList.count > maxHistory) {
            historyList.remove(historyList.count - 1);
        }

        _updateArrays();
    }

    function removeActive(id) {
        // Remove from active list
        for (let i = 0; i < activeList.count; i++) {
            if (activeList.get(i).id === id) {
                activeList.remove(i);
                break;
            }
        }

        // Clean up mapping
        delete activeMap[id];

        _updateArrays();
    }

    // Utility functions
    function getAppName(name) {
        if (!name || String(name).trim() === "")
            return "Unknown";

        const nameStr = String(name).trim();

        // Handle reverse domain names
        if (nameStr.includes(".") && (nameStr.startsWith("com.") || nameStr.startsWith("org.") || nameStr.startsWith("io.") || nameStr.startsWith("net."))) {
            const parts = nameStr.split(".");
            let appPart = parts[parts.length - 1];

            if (!appPart || appPart === "app" || appPart === "desktop") {
                appPart = parts[parts.length - 2] || parts[0];
            }

            if (appPart) {
                return cleanName(appPart);
            }
        }

        return cleanName(nameStr);
    }

    function cleanName(name) {
        let displayName = String(name);
        if (displayName.length > 0) {
            displayName = displayName.charAt(0).toUpperCase() + displayName.slice(1);
        }
        return displayName || "Unknown";
    }

    function stripTags(text) {
        return String(text || "").replace(/<[^>]*>/g, '');
    }

    // Public API functions for compatibility
    function dismissNotification(wrapper) {
        if (wrapper && wrapper.notification) {
            try {
                wrapper.notification.dismiss();
            } catch (e) {}
        }
    }

    function removeFromVisibleNotifications(wrapper, dismiss = true) {
        if (!wrapper)
            return;

        if (dismiss && wrapper.notification) {
            try {
                wrapper.notification.dismiss();
            } catch (e) {}
        }
    }

    function releaseWrapper(wrapper) {
        removeFromVisibleNotifications(wrapper, true);
    }

    // Clear all active notifications
    function dismissAllActive() {
        Object.values(activeMap).forEach(n => {
            try {
                n.dismiss();
            } catch (e) {}
        });
        activeList.clear();
        activeMap = {};
        _updateArrays();
    }

    // Clear history
    function clearHistory() {
        historyList.clear();
        _updateArrays();
    }

    // Remove single item from history by ID
    function removeFromHistory(id) {
        for (let i = 0; i < historyList.count; i++) {
            if (historyList.get(i).id === id) {
                historyList.remove(i);
                break;
            }
        }
        _updateArrays();
    }
}
