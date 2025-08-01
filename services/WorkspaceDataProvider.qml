import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var workspaceData: ({})
    signal dataUpdated(var data)

    Process {
        id: clientsProcess
        command: ["hyprctl", "clients", "-j"]
        running: false

        stdout: StdioCollector {
            id: clientsCollector
            onStreamFinished: {
                root.parseClientsOutput(clientsCollector.text);
            }
        }
    }

    function updateData() {
        clientsProcess.running = true;
    }

    function parseClientsOutput(output) {
        try {
            // Always create workspaces 1-10 first
            let workspaces = {};
            for (let i = 1; i <= 10; i++) {
                workspaces[i] = {
                    id: i,
                    name: `Workspace ${i}`,
                    clients: []
                };
            }

            // Then add clients if any exist
            if (output && output.trim() !== "") {
                let clients = JSON.parse(output);
                if (Array.isArray(clients)) {
                    clients.forEach(client => {
                        if (client.workspace && client.workspace.id && workspaces[client.workspace.id]) {
                            workspaces[client.workspace.id].clients.push({
                                title: client.title || "Untitled",
                                class: client.class || "Unknown"
                            });
                        }
                    });
                }
            }

            console.log("Generated workspace data with", Object.keys(workspaces).length, "workspaces");
            workspaceData = workspaces;
            dataUpdated(workspaceData);
        } catch (e) {
            console.error("Failed to parse hyprctl clients output:", e);
            generateFallbackData();
        }
    }

    function generateFallbackData() {
        // Generate fallback workspace data 1-10
        let fallbackData = {};
        for (let i = 1; i <= 10; i++) {
            fallbackData[i] = {
                id: i,
                name: `Workspace ${i}`,
                clients: []
            };
        }

        workspaceData = fallbackData;
        dataUpdated(fallbackData);
    }
}
