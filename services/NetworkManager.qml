pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../utils"

QtObject {
    id: root

    property bool networkSelectorVisible: false
    property bool passwordDialogVisible: false
    property bool hoverMode: true
    property bool networkSelectorHovered: false
    property var availableNetworks: []
    property var savedConnections: []
    property var savedConnectionDetails: new Map()  // Maps SSID to connection UUID
    property bool isScanning: false

    // Computed properties for active network state
    readonly property bool isConnected: activeNetwork !== null
    readonly property var activeNetwork: {
        for (let network of availableNetworks) {
            if (network.isActive) {
                return network;
            }
        }
        return null;
    }
    readonly property string activeSSID: activeNetwork ? activeNetwork.ssid : ""
    readonly property int signalStrength: activeNetwork ? activeNetwork.signal : 0

    // Timer for hiding the network selector
    property Timer hideTimer: Timer {
        interval: 300
        onTriggered: {
            if (root.hoverMode && !root.networkSelectorHovered) {
                root.networkSelectorVisible = false;
            }
        }
    }

    // Timer for periodic network scanning
    property Timer scanTimer: Timer {
        interval: 300000  // Scan every 5 minutes - reduced frequency for resource efficiency
        running: true
        repeat: true
        onTriggered: root.scanNetworks()
    }

    // Debounce timer to prevent excessive scanning
    property Timer scanDebounceTimer: Timer {
        interval: 2000  // 2 second debounce
        onTriggered: root.performNetworkScan()
    }

    property var scanProcess: null

    function showNetworkSelector() {
        hideTimer.stop();
        if (!networkSelectorVisible) {
            scanNetworks();  // Refresh networks when showing
        }
        networkSelectorVisible = true;
    }

    function hideNetworkSelector() {
        if (!networkSelectorHovered) {
            networkSelectorVisible = false;
        }
    }

    function startHideTimer() {
        hideTimer.restart();
    }

    function stopHideTimer() {
        hideTimer.stop();
    }

    function scanNetworks() {
        // Use debouncing to prevent excessive scanning
        scanDebounceTimer.restart();
    }

    function performNetworkScan() {
        if (isScanning)
            return;

        isScanning = true;
        DebugUtils.debug("NetworkManager: Scanning for available networks");

        // First get saved connections, then scan for available networks
        getSavedConnections();
    }

    function getSavedConnections() {
        if (scanProcess) {
            scanProcess.destroy();
        }

        scanProcess = Qt.createQmlObject(`
            import QtQuick
            import Quickshell.Io
            Process {
                command: ["nmcli", "-t", "-f", "NAME,UUID,TYPE", "connection", "show"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        root.parseSavedConnections(text);
                        root.getSavedConnectionDetails();
                    }
                }

                stderr: StdioCollector {
                    onStreamFinished: {
                        if (text.length > 0) {
                            DebugUtils.error("NetworkManager: Error getting saved connections:", text);
                        }
                        // Continue with scan even if this fails
                        root.scanAvailableNetworks();
                    }
                }
            }
        `, root);
    }

    function parseSavedConnections(output) {
        const lines = output.trim().split('\n');
        const connections = [];

        for (let line of lines) {
            const parts = line.split(':');
            if (parts.length >= 3) {
                const name = parts[0].trim();
                const uuid = parts[1].trim();
                const type = parts[2].trim();

                // Only include WiFi connections
                if (type === '802-11-wireless' && name && uuid) {
                    connections.push({
                        name: name,
                        uuid: uuid
                    });
                }
            }
        }

        savedConnections = connections;
        DebugUtils.log("NetworkManager: Found", connections.length, "saved WiFi connections");
    }

    function getSavedConnectionDetails() {
        DebugUtils.log("NetworkManager: getSavedConnectionDetails() called with", savedConnections.length, "connections");
        if (savedConnections.length === 0) {
            DebugUtils.log("NetworkManager: No saved connections, going directly to scan networks");
            scanAvailableNetworks();
            return;
        }

        DebugUtils.log("NetworkManager: Getting active connection details...");
        // Use a simpler approach - get connection details with basic format
        if (scanProcess) {
            scanProcess.destroy();
        }

        scanProcess = Qt.createQmlObject(`
            import QtQuick
            import Quickshell.Io
            Process {
                command: ["nmcli", "-t", "-f", "NAME,TYPE,DEVICE", "connection", "show", "--active"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        DebugUtils.log("NetworkManager: Active connections query completed");
                        root.parseActiveConnections(text);
                        DebugUtils.log("NetworkManager: About to call getAllConnectionSSIDs...");
                        root.getAllConnectionSSIDs();
                    }
                }

                stderr: StdioCollector {
                    onStreamFinished: {
                        if (text.length > 0) {
                            DebugUtils.error("NetworkManager: Error getting active connections:", text);
                        }
                        // Continue anyway
                        DebugUtils.log("NetworkManager: Active connections failed, calling getAllConnectionSSIDs anyway...");
                        root.getAllConnectionSSIDs();
                    }
                }
            }
        `, root);
    }

    function parseActiveConnections(output) {
    // This helps us understand which connections are currently active
    // We'll use this information later if needed
    }

    function getAllConnectionSSIDs() {
        // First, let's see what connection names we actually have
        DebugUtils.log("NetworkManager: getAllConnectionSSIDs() called with", savedConnections.length, "connections");
        const connectionNames = savedConnections.map(conn => conn.name);
        DebugUtils.log("NetworkManager: Saved connection names:", connectionNames.join(", "));

        // Get the SSID for each saved connection individually
        const detailsMap = new Map();
        let processedCount = 0;

        if (savedConnections.length === 0) {
            DebugUtils.log("NetworkManager: No saved connections, proceeding to scan");
            scanAvailableNetworks();
            return;
        }

        DebugUtils.log("NetworkManager: Starting SSID extraction for", savedConnections.length, "connections");

        // Process each connection to get its SSID
        for (let connection of savedConnections) {
            DebugUtils.log("NetworkManager: Processing connection:", connection.name, "UUID:", connection.uuid);
            getConnectionSSID(connection.uuid, connection.name, detailsMap, () => {
                processedCount++;
                DebugUtils.log("NetworkManager: Processed", processedCount, "of", savedConnections.length, "connections");
                if (processedCount >= savedConnections.length) {
                    // All connections processed
                    savedConnectionDetails = detailsMap;
                    DebugUtils.log("NetworkManager: Final SSID mappings:");
                    for (let [ssid, connUuid] of detailsMap) {
                        DebugUtils.log("NetworkManager:   SSID '" + ssid + "' -> UUID '" + connUuid + "'");
                    }
                    scanAvailableNetworks();
                }
            });
        }
    }

    function getConnectionSSID(connectionUuid, connectionName, detailsMap, callback) {
        DebugUtils.log("NetworkManager: Getting SSID for connection:", connectionName, "UUID:", connectionUuid);
        const process = Qt.createQmlObject(`
            import QtQuick
            import Quickshell.Io
            Process {
                command: ["nmcli", "-t", "-f", "802-11-wireless.ssid", "connection", "show", "${connectionUuid}"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        DebugUtils.log("NetworkManager: SSID query output for '${connectionName}' (${connectionUuid}):", text.trim());
                        const lines = text.trim().split('\\n');
                        for (let line of lines) {
                            const parts = line.split(':');
                            if (parts.length >= 2 && parts[0].trim() === "802-11-wireless.ssid") {
                                const ssid = parts[1].trim();
                                if (ssid) {
                                    // For now, assume all saved connections have credentials
                                    // We'll test this during actual connection attempts
                                    detailsMap.set(ssid, "${connectionUuid}");
                                    DebugUtils.log("NetworkManager: Found SSID '" + ssid + "' for connection '${connectionName}' (UUID: ${connectionUuid})");
                                }
                                break;
                            }
                        }
                        callback();
                    }
                }

                stderr: StdioCollector {
                    onStreamFinished: {
                        if (text.length > 0) {
                            DebugUtils.error("NetworkManager: Error getting SSID for", "${connectionName}", "(${connectionUuid}):", text);
                        }
                        callback();
                    }
                }
            }
        `, root);
    }
    function scanAvailableNetworks() {
        if (scanProcess) {
            scanProcess.destroy();
        }

        scanProcess = Qt.createQmlObject(`
            import QtQuick
            import Quickshell.Io
            Process {
                command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,ACTIVE", "dev", "wifi"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        root.parseNetworkScanOutput(text);
                    }
                }

                stderr: StdioCollector {
                    onStreamFinished: {
                        if (text.length > 0) {
                            DebugUtils.error("NetworkManager: Scan error:", text);
                        }
                        root.isScanning = false;
                    }
                }
            }
        `, root);
    }

    function parseNetworkScanOutput(output) {
        const lines = output.trim().split('\n');
        const networks = [];
        const networkMap = new Map();

        for (let line of lines) {
            const parts = line.split(':');
            if (parts.length >= 4) {
                const ssid = parts[0].trim();
                const signal = parseInt(parts[1]) || 0;
                const security = parts[2].trim();
                const active = parts[3].trim() === 'yes';

                if (ssid) {
                    const existingNetwork = networkMap.get(ssid);
                    const hasSavedCredentials = savedConnectionDetails.has(ssid);

                    if (!existingNetwork) {
                        // First time seeing this SSID
                        networkMap.set(ssid, {
                            ssid: ssid,
                            signal: signal,
                            security: security,
                            isSecure: security !== '',
                            isActive: active,
                            hasSavedCredentials: hasSavedCredentials
                        });
                    } else {
                        // SSID already exists - prioritize active connections, then signal strength
                        if (active && !existingNetwork.isActive) {
                            // This one is active and existing isn't - replace
                            networkMap.set(ssid, {
                                ssid: ssid,
                                signal: signal,
                                security: security,
                                isSecure: security !== '',
                                isActive: active,
                                hasSavedCredentials: hasSavedCredentials
                            });
                        } else if (!active && !existingNetwork.isActive && signal > existingNetwork.signal) {
                            // Neither is active, keep the one with better signal
                            networkMap.set(ssid, {
                                ssid: ssid,
                                signal: signal,
                                security: security,
                                isSecure: security !== '',
                                isActive: active,
                                hasSavedCredentials: hasSavedCredentials
                            });
                        }
                        // If existing is active and this isn't, keep existing
                        // If both are active (shouldn't happen), keep existing
                    }
                }
            }
        }

        // Convert map values to array
        for (let network of networkMap.values()) {
            networks.push(network);
        }

        // Sort by signal strength (strongest first)
        networks.sort((a, b) => b.signal - a.signal);

        availableNetworks = networks;
        isScanning = false;

        // Debug logging
        for (let network of networks) {
            if (network.isActive) {
                DebugUtils.log("NetworkManager: Connected to", network.ssid, "- Signal:", network.signal + "%");
            } else if (network.hasSavedCredentials) {
                DebugUtils.log("NetworkManager: Found saved network", network.ssid, "- Signal:", network.signal + "%");
            } else if (network.isSecure) {
                DebugUtils.log("NetworkManager: Found secure network (no saved creds)", network.ssid, "- Signal:", network.signal + "%");
            }
        }

        DebugUtils.log("NetworkManager: Found", networks.length, "networks");
    }

    function connectToNetwork(ssid, password) {
        DebugUtils.log("NetworkManager: Connecting to", ssid);

        // First try with saved connection if available, otherwise use direct method
        if (savedConnectionDetails.has(ssid)) {
            const connectionUuid = savedConnectionDetails.get(ssid);
            DebugUtils.log("NetworkManager: Attempting to use saved connection UUID", connectionUuid);
            connectUsingSavedConnection(ssid, connectionUuid, password);
        } else {
            // Use direct WiFi connection method
            connectUsingDirectMethod(ssid, password);
        }
    }

    function connectUsingSavedConnection(ssid, connectionUuid, fallbackPassword) {
        // Try to activate the saved connection first
        executeConnectionCommand(["nmcli", "connection", "up", connectionUuid], ssid, () => {
            // If saved connection fails, fall back to direct method
            DebugUtils.log("NetworkManager: Saved connection failed, falling back to direct method");
            connectUsingDirectMethod(ssid, fallbackPassword);
        });
    }

    function connectUsingDirectMethod(ssid, password) {
        const command = password ? ["nmcli", "dev", "wifi", "connect", ssid, "password", password] : ["nmcli", "dev", "wifi", "connect", ssid];

        executeConnectionCommand(command, ssid);
    }

    function executeConnectionCommand(command, ssid, onError) {
        const connectProcess = Qt.createQmlObject(`
            import QtQuick
            import Quickshell.Io
            Process {
                command: ${JSON.stringify(command)}
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        if (text.includes("successfully activated") || text.includes("Connection successfully activated")) {
                            DebugUtils.log("NetworkManager: Successfully connected to", "${ssid}");
                            Qt.callLater(() => root.scanNetworks());
                        }
                    }
                }

                stderr: StdioCollector {
                    onStreamFinished: {
                        if (text.length > 0) {
                            DebugUtils.error("NetworkManager: Connection failed for", "${ssid}", ":", text);
                        }
                    }
                }
            }
        `, root);

        // Handle errors if callback provided
        if (onError) {
            connectProcess.stderr.streamFinished.connect(() => {
                if (connectProcess.stderr.text.length > 0) {
                    onError();
                }
            });
        }
    }

    Component.onCompleted: {
        scanNetworks();
    }
}
