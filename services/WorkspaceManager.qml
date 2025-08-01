pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../modules/common"

QtObject {
    id: root

    property bool workspaceWindowVisible: false
    property bool hoverMode: true  // Will be updated by InteractionSettings binding
    property bool workspaceWindowHovered: false  // Track if workspace window is being hovered
    property var workspaceData: ({})

    // Timer to fetch client data
    property Timer clientsTimer: Timer {
        interval: 100
        running: false
        repeat: false

        onTriggered: {
            console.log("Updating workspace data...");
            root.fetchClientsData();
        }
    }

    function fetchClientsData() {
        var process = Qt.createQmlObject(`
            import QtQuick
            import Quickshell.Io
            Process {
                command: ["hyprctl", "clients", "-j"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        root.parseClientsOutput(text);
                    }
                }

                stderr: StdioCollector {
                    onStreamFinished: {
                        if (text.length > 0) {
                            // Handle errors silently or log to file if needed
                        }
                    }
                }
            }
        `, root);
    }

    // Listen to Hyprland events for real-time updates
    property var hyprlandConnections: Connections {
        target: Hyprland
        function onRawEvent(event) {
            // Check if event and event.name exist before accessing
            if (!event || !event.name) {
                return;
            }

            // Only update on window changes, not workspace switches
            if (event.name === "openwindow" || event.name === "closewindow" || event.name === "movewindow") {
                console.log("Window event detected:", event.name, "- updating workspace data");
                root.updateWorkspaceData();
            }
        }
    }

    // Initialize workspace data directly
    Component.onCompleted: {
        if (typeof InteractionSettings !== 'undefined') {
            hoverMode = Qt.binding(() => InteractionSettings.hoverMode);
        }
        initializeWorkspaceData();
    }

    function initializeWorkspaceData() {
        let workspaces = {};
        for (let i = 1; i <= 10; i++) {
            workspaces[i] = {
                id: i,
                name: `Workspace ${i}`,
                clients: []
            };
        }
        workspaceData = workspaces;

        // Fetch client data using timer
        clientsTimer.start();
    }

    function parseClientsOutput(output) {
        try {

            // Start with existing workspace structure for regular workspaces
            let workspaces = {};
            for (let i = 1; i <= 10; i++) {
                workspaces[i] = {
                    id: i,
                    name: `Workspace ${i}`,
                    clients: []
                };
            }

            // Add clients if any exist
            if (output && output.trim() !== "") {
                let clients = JSON.parse(output);

                if (Array.isArray(clients)) {
                    clients.forEach((client, index) => {
                        if (client.workspace && client.workspace.id !== undefined) {
                            const workspaceId = client.workspace.id;

                            // Create workspace entry if it doesn't exist (for special workspaces)
                            if (!workspaces[workspaceId]) {
                                workspaces[workspaceId] = {
                                    id: workspaceId,
                                    name: client.workspace.name || `Workspace ${workspaceId}`,
                                    clients: []
                                };
                            }

                            workspaces[workspaceId].clients.push({
                                title: client.title || "Untitled",
                                class: client.class || "Unknown"
                            });
                        }
                    });
                }
            }

            workspaceData = workspaces;
        } catch (e) {
            console.error("Failed to parse hyprctl clients output:", e);
            // Keep the basic workspace structure even if client parsing fails
        }
    }

    property Timer hideTimer: Timer {
        interval: 200  // Same as calendar for consistency
        running: false
        repeat: false

        onTriggered: {
            if (!root.workspaceWindowHovered) {
                root.hideWorkspaceWindow();
            }
        }
    }

    function showWorkspaceWindow() {
        console.log("Showing workspace window - refreshing data");
        updateWorkspaceData();
        workspaceWindowVisible = true;
    }

    function hideWorkspaceWindow() {
        workspaceWindowVisible = false;
    }

    function toggleWorkspaceWindow() {
        if (workspaceWindowVisible) {
            hideWorkspaceWindow();
        } else {
            showWorkspaceWindow();
        }
    }

    function startHideTimer() {
        if (hoverMode) {
            hideTimer.restart();
        }
    }

    function stopHideTimer() {
        if (hoverMode) {
            hideTimer.stop();
        }
    }

    function updateWorkspaceData() {
        initializeWorkspaceData();
    }
}
