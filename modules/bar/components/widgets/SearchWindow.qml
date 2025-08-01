pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import "../../../../services"

Rectangle {
    id: searchWindow

    width: 400
    height: searchInput.text.length > 0 ? 300 : 60
    visible: SearchManager.searchVisible
    color: "#1c1b1f"
    radius: 16
    border.color: Qt.alpha("#938f99", 0.2)
    border.width: 1

    // Position the search window - center on screen like reference implementations
    anchors.centerIn: parent

    // Focus handling - simplified for Wayland compatibility
    focus: SearchManager.searchVisible

    Behavior on height {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    // HoverHandler to detect hover and prevent closing
    HoverHandler {
        id: searchHover

        onHoveredChanged: {
            if (SearchManager.hoverMode) {
                if (hovered) {
                    SearchManager.searchHovered = true;
                    SearchManager.stopHideTimer();
                } else {
                    SearchManager.searchHovered = false;
                    SearchManager.startHideTimer();
                }
            }
        }
    }

    // Subtle shadow effect
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowBlur: 0.8
        shadowHorizontalOffset: 4
        shadowVerticalOffset: 4
        shadowColor: Qt.alpha("#000000", 0.4)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Search input
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Qt.alpha("#d0bcff", 0.05)
            radius: 8
            border.width: 1
            border.color: searchInput.activeFocus ? "#d0bcff" : Qt.alpha("#938f99", 0.3)

            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    text: "search"
                    font.family: "Material Symbols Outlined"
                    font.pointSize: 16
                    color: "#d0bcff"
                }

                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: "Search applications, calculate, or run commands..."
                    font.family: "JetBrains Mono"
                    font.pointSize: 11
                    color: "#e6e0e9"
                    placeholderTextColor: Qt.alpha("#938f99", 0.7)
                    selectByMouse: true

                    // Simplified focus for Wayland compatibility
                    focus: true

                    // Standard TextField properties
                    renderType: Text.NativeRendering
                    selectedTextColor: "#e6e0e9"
                    selectionColor: Qt.alpha("#d0bcff", 0.3)

                    background: Rectangle {
                        color: "transparent"
                    }

                    // Clear text when search window is hidden
                    Connections {
                        target: SearchManager
                        function onSearchVisibleChanged() {
                            if (!SearchManager.searchVisible) {
                                searchInput.text = "";
                            }
                        }
                    }

                    onAccepted: {
                        if (text.trim().length > 0) {
                            searchWindow.executeSearch(text.trim());
                        }
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            SearchManager.hideSearch();
                            event.accepted = true;
                        }
                    }
                }
            }
        }
        // Search results area (shown when there's input)
        Rectangle {
            id: resultsArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: searchInput.text.length > 0
            color: Qt.alpha("#938f99", 0.03)
            radius: 8
            border.width: 1
            border.color: Qt.alpha("#938f99", 0.1)

            ScrollView {
                anchors.fill: parent
                anchors.margins: 8
                contentWidth: availableWidth
                clip: true

                Column {
                    width: parent.width
                    spacing: 4

                    // Example results
                    Repeater {
                        model: searchWindow.getSearchResults(searchInput.text)
                        delegate: Rectangle {
                            id: resultItem
                            required property var modelData

                            width: parent.width
                            height: 32
                            color: searchResultMouse.containsMouse ? Qt.alpha("#d0bcff", 0.08) : "transparent"
                            radius: 4

                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
                                    easing.type: Easing.OutCubic
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8

                                Text {
                                    text: resultItem.modelData.icon || "app_registration"
                                    font.family: "Material Symbols Outlined"
                                    font.pointSize: 14
                                    color: "#d0bcff"
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: resultItem.modelData.name || "Search Result"
                                    font.family: "JetBrains Mono"
                                    font.pointSize: 10
                                    color: "#e6e0e9"
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: resultItem.modelData.type || "App"
                                    font.family: "JetBrains Mono"
                                    font.pointSize: 9
                                    color: "#938f99"
                                }
                            }

                            MouseArea {
                                id: searchResultMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    searchWindow.executeSearchResult(resultItem.modelData);
                                }
                            }
                        }
                    }

                    // Show placeholder when no results
                    Text {
                        width: parent.width
                        visible: searchWindow.getSearchResults(searchInput.text).length === 0
                        text: "No results found"
                        font.family: "JetBrains Mono"
                        font.pointSize: 10
                        color: "#938f99"
                        horizontalAlignment: Text.AlignHCenter
                        topPadding: 20
                    }
                }
            }
        }
    }

    // Search logic functions
    function getSearchResults(query) {
        if (!query || query.length === 0)
            return [];

        let results = [];

        // Simple application search (placeholder)
        const apps = [
            {
                name: "Calculator",
                icon: "calculate",
                type: "App",
                exec: "gnome-calculator"
            },
            {
                name: "Terminal",
                icon: "terminal",
                type: "App",
                exec: "gnome-terminal"
            },
            {
                name: "File Manager",
                icon: "folder",
                type: "App",
                exec: "nautilus"
            },
            {
                name: "Text Editor",
                icon: "edit",
                type: "App",
                exec: "gnome-text-editor"
            },
            {
                name: "Web Browser",
                icon: "web",
                type: "App",
                exec: "firefox"
            }
        ];

        // Filter apps by query
        results = apps.filter(app => app.name.toLowerCase().includes(query.toLowerCase()));

        // Add command execution if query looks like a command
        if (query.includes(" ") || query.startsWith("/")) {
            results.unshift({
                name: `Run: ${query}`,
                icon: "terminal",
                type: "Command",
                exec: query
            });
        }

        // Add calculator result for mathematical expressions
        if (/^[0-9+\-*/.() ]+$/.test(query)) {
            try {
                const result = eval(query);
                if (!isNaN(result)) {
                    results.unshift({
                        name: `${query} = ${result}`,
                        icon: "calculate",
                        type: "Math",
                        exec: `echo "${result}" | wl-copy`
                    });
                }
            } catch (e)
            // Ignore math errors
            {}
        }

        return results.slice(0, 8); // Limit to 8 results
    }

    function executeSearch(query) {
        const results = getSearchResults(query);
        if (results.length > 0) {
            executeSearchResult(results[0]);
        }
    }

    function executeSearchResult(result) {
        console.log("Executing:", result.name, "->", result.exec);

        if (result.type === "Command") {
            Quickshell.execDetached(["bash", "-c", result.exec]);
        } else if (result.type === "Math") {
            Quickshell.execDetached(["bash", "-c", result.exec]);
        } else {
            // Launch application
            Quickshell.execDetached([result.exec]);
        }

        SearchManager.hideSearch();
    }
}
