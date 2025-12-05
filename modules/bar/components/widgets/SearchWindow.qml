pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../../../../services"
import "../../../../utils"
import "../../../../widgets" as Widgets
import "../../../../config"

PanelWindow {
    id: searchWindow

    // Screen property for multi-monitor support
    property ShellScreen targetScreen: null
    screen: targetScreen

    // Expose the input so external callers can reset/focus like other modules do
    property alias searchField: searchInput

    implicitWidth: 500
    implicitHeight: Math.max(400, Math.min(600, searchList.contentHeight + 120))
    visible: false
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "waffles-search-" + (targetScreen?.name || "unknown")
    // Important: without requesting keyboard focus on Wayland, this PanelWindow
    // will not receive key events (so TextField won't focus type). Using Exclusive
    // here because this modal contains the only active text input while visible
    // and does not spawn other nested popups that need focus. Mirrors DankModal pattern.
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    // Allow it to float without reserving space
    WlrLayershell.exclusiveZone: -1

    property string searchText: ""
    property var searchResults: []
    property bool searchActive: false

    // Handle window visibility changes to manage focus and reset state like AppDrawer/Spotlight
    onVisibleChanged: {
        if (visible) {
            DebugUtils.debug("SearchWindow became visible, scheduling focus and reset");
            // Reset search state to be consistent with other modals
            searchInput.text = "";
            searchResults = [];
            searchList.currentIndex = -1;

            // Defer focus to ensure the TextField exists and is ready
            Qt.callLater(function () {
                searchInput.forceActiveFocus();
                // Force focus scope as well (belt & suspenders on some compositors)
                focusScope.forceActiveFocus();
            });
        }
    }

    // Methods to show/hide the search window (modal-like)
    function showSearch() {
        DebugUtils.debug("SearchWindow.showSearch() called");
        searchWindow.visible = true;
        SearchManager.searchVisible = true;
        Qt.callLater(() => searchInput.forceActiveFocus());
    }

    function hideSearch() {
        DebugUtils.debug("SearchWindow.hideSearch() called");
        searchWindow.visible = false;
        searchInput.text = "";
        searchResults = [];
        SearchManager.searchVisible = false;
    }

    // Sync with SearchManager and register this window
    Component.onCompleted: {
        // Register the window reference so SearchManager can call show/hide
        try {
            SearchManager.setSearchWindow(searchWindow);
        } catch (e) {}
    }

    Connections {
        target: SearchManager
        function onSearchVisibleChanged() {
            if (SearchManager.searchVisible && !searchWindow.visible) {
                searchWindow.showSearch();
            } else if (!SearchManager.searchVisible && searchWindow.visible) {
                searchWindow.hideSearch();
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colours.m3surface
        radius: Appearance.rounding.large
        border.color: Qt.alpha("#938f99", 0.2)
        border.width: 1

        // Subtle shadow effect
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.8
            shadowHorizontalOffset: 4
            shadowVerticalOffset: 4
            shadowColor: Colours.alpha(Colours.m3shadow, 0.25)
        }

        // Focus scope to manage keyboard focus within the search window
        FocusScope {
            id: focusScope
            anchors.fill: parent
            focus: searchWindow.visible

            // Global keyboard handler inspired by end-4/dots-hyprland
            Keys.onPressed: event => {
                // Prevent Esc from being handled here
                if (event.key === Qt.Key_Escape) {
                    return;
                }

                // Handle Backspace: focus and delete character if not focused
                if (event.key === Qt.Key_Backspace) {
                    if (!searchInput.activeFocus) {
                        searchInput.forceActiveFocus();
                        if (event.modifiers & Qt.ControlModifier) {
                            // Delete word before cursor
                            let text = searchInput.text;
                            let pos = searchInput.cursorPosition;
                            if (pos > 0) {
                                let left = text.slice(0, pos);
                                let match = left.match(/(\s*\S+)\s*$/);
                                let deleteLen = match ? match[0].length : 1;
                                searchInput.text = text.slice(0, pos - deleteLen) + text.slice(pos);
                                searchInput.cursorPosition = pos - deleteLen;
                            }
                        } else {
                            // Delete character before cursor if any
                            if (searchInput.cursorPosition > 0) {
                                searchInput.text = searchInput.text.slice(0, searchInput.cursorPosition - 1) + searchInput.text.slice(searchInput.cursorPosition);
                                searchInput.cursorPosition -= 1;
                            }
                        }
                        // Always move cursor to end after programmatic edit
                        searchInput.cursorPosition = searchInput.text.length;
                        event.accepted = true;
                    }
                    return;
                }

                // Only handle visible printable characters (ignore control chars, arrows, etc.)
                if (event.text && event.text.length === 1 && event.key !== Qt.Key_Enter && event.key !== Qt.Key_Return && event.text.charCodeAt(0) >= 0x20) {
                    if (!searchInput.activeFocus) {
                        searchInput.forceActiveFocus();
                        // Insert the character at the cursor position
                        searchInput.text = searchInput.text.slice(0, searchInput.cursorPosition) + event.text + searchInput.text.slice(searchInput.cursorPosition);
                        searchInput.cursorPosition += 1;
                        event.accepted = true;
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                // Header with search input
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // Title
                    Widgets.WindowHeader {
                        Layout.fillWidth: true
                        headerIcon: "search"
                        headerTitle: "Search"
                        onCloseClicked: searchWindow.hideSearch()
                    }

                    // Search input field
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: Appearance.rounding.normal
                        color: Colours.alpha(Colours.m3onSurface, 0.04)
                        border.color: searchInput.activeFocus ? Colours.m3primary : Colours.alpha(Colours.m3onSurface, 0.2)
                        border.width: 1

                        TextField {
                            id: searchInput
                            anchors.fill: parent
                            anchors.margins: 1

                            placeholderText: "Search applications, files, or run commands..."
                            font.pointSize: Appearance.font.size.normal
                            color: Colours.m3onSurface
                            placeholderTextColor: Colours.m3onSurfaceVariant

                            // Direct focus binding like end-4/dots-hyprland
                            // Let programmatic focus control handle this; binding to visibility can steal focus back.
                            focus: false
                            activeFocusOnTab: true
                            focusPolicy: Qt.StrongFocus

                            background: Rectangle {
                                color: "transparent"
                                radius: Appearance.rounding.normal
                            }

                            leftPadding: 12
                            rightPadding: 12

                            // Handle keyboard input
                            Keys.onPressed: function (event) {
                                if (event.key === Qt.Key_Escape) {
                                    searchWindow.hideSearch();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    if (searchWindow.searchResults.length > 0) {
                                        searchWindow.executeResult(searchWindow.searchResults[searchList.currentIndex || 0]);
                                    }
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Down) {
                                    if (searchList.count > 0) {
                                        searchList.currentIndex = Math.min(searchList.count - 1, (searchList.currentIndex || 0) + 1);
                                    }
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Up) {
                                    if (searchList.count > 0) {
                                        searchList.currentIndex = Math.max(0, (searchList.currentIndex || 0) - 1);
                                    }
                                    event.accepted = true;
                                }
                            }

                            // Search as user types
                            onTextChanged: {
                                searchWindow.searchText = text;
                                searchTimer.restart();
                            }
                        }
                    }
                }

                // Results list
                ScrollView {
                    id: scrollView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    visible: searchWindow.searchResults.length > 0

                    ListView {
                        id: searchList
                        model: searchWindow.searchResults
                        spacing: 4
                        currentIndex: -1
                        focus: true
                        interactive: true
                        cacheBuffer: Math.max(0, Math.min(height * 2, 1000))
                        reuseItems: true

                        // Highlight current item
                        highlight: Rectangle {
                            color: Colours.alpha(Colours.m3primary, 0.12)
                            radius: Appearance.rounding.normal
                        }

                        onCurrentIndexChanged: function () {
                            if (currentIndex >= 0) {
                                // Ensure the selection is visible for keyboard navigation
                                Qt.callLater(function () {
                                    searchList.positionViewAtIndex(currentIndex, ListView.Contain);
                                });
                            }
                        }

                        delegate: Rectangle {
                            id: resultDelegate
                            width: searchList.width
                            height: 56
                            radius: Appearance.rounding.normal
                            color: {
                                if (searchList.currentIndex === index) {
                                    return Colours.alpha(Colours.m3primary, 0.15);
                                } else if (resultMouseArea.containsMouse) {
                                    return Colours.alpha(Colours.m3primary, 0.08);
                                } else {
                                    return "transparent";
                                }
                            }

                            required property var modelData
                            required property int index
                            property var resultData: modelData

                            MouseArea {
                                id: resultMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    searchWindow.executeResult(resultDelegate.resultData);
                                }

                                onEntered: {
                                    searchList.currentIndex = resultDelegate.index;
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 16

                                // Icon
                                Loader {
                                    Layout.preferredWidth: 24
                                    Layout.preferredHeight: 24

                                    sourceComponent: {
                                        if (resultDelegate.resultData.type === "Application") {
                                            return appIconComponent;
                                        } else {
                                            return materialIconComponent;
                                        }
                                    }

                                    Component {
                                        id: appIconComponent
                                        IconImage {
                                            source: Quickshell.iconPath(resultDelegate.resultData.icon || "application-x-executable")
                                            width: 24
                                            height: 24
                                        }
                                    }

                                    Component {
                                        id: materialIconComponent
                                        Widgets.MaterialIcon {
                                            text: {
                                                if (resultDelegate.resultData.type === "Calculation")
                                                    return "calculate";
                                                if (resultDelegate.resultData.type === "Web Search")
                                                    return "public";
                                                return resultDelegate.resultData.icon || "apps";
                                            }
                                            color: Colours.m3primary
                                            font.pointSize: Appearance.font.size.larger
                                        }
                                    }
                                }

                                // Content
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    // Title
                                    Widgets.StyledText {
                                        text: resultDelegate.resultData.title || "Unknown"
                                        font.pointSize: Appearance.font.size.normal
                                        font.weight: Font.Medium
                                        color: Colours.m3onSurface
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    // Description
                                    Widgets.StyledText {
                                        text: resultDelegate.resultData.description || ""
                                        font.pointSize: Appearance.font.size.small
                                        color: Colours.m3onSurfaceVariant
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        visible: text.length > 0
                                    }
                                }

                                // Type indicator
                                Widgets.StyledText {
                                    text: resultDelegate.resultData.type || ""
                                    font.pointSize: Appearance.font.size.small
                                    color: Colours.m3outline
                                    visible: text.length > 0
                                }
                            }
                        }
                    }
                }

                // No results message
                Widgets.StyledText {
                    text: searchWindow.searchText.length > 0 ? "No results found" : "Start typing to search..."
                    font.pointSize: Appearance.font.size.normal
                    color: Colours.m3onSurfaceVariant
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    visible: searchWindow.searchResults.length === 0
                }
            }
        }
    }

    // Search timer to debounce search queries
    Timer {
        id: searchTimer
        interval: 300
        onTriggered: searchWindow.performSearch()
    }

    // Functions
    function performSearch() {
        if (searchText.length === 0) {
            searchResults = [];
            return;
        }

        var results = [];
        var query = searchText.toLowerCase();

        // Search applications using AppSearch service
        var appResults = AppSearch.fuzzyQuery(searchText);
        for (var i = 0; i < appResults.length; i++) {
            results.push(appResults[i]);
        }

        // Math calculation - simplified regex check
        var mathPattern = /^[\d+\-*/().\s]+$/;
        if (searchText.trim().match(mathPattern)) {
            try {
                var mathResult = eval(searchText.trim());
                if (!isNaN(mathResult) && isFinite(mathResult)) {
                    results.unshift({
                        title: mathResult.toString(),
                        description: "Math result for: " + searchText,
                        type: "Calculation",
                        icon: "calculate",
                        action: "copy",
                        data: mathResult.toString()
                    });
                }
            } catch (e)
            // Invalid math expression
            {}
        }

        // Web search
        if (searchText.trim().length > 0) {
            results.push({
                title: "Search \"" + searchText + "\" on the web",
                description: "Open web search in browser",
                type: "Web Search",
                icon: "public",
                action: "web",
                data: searchText
            });
        }

        searchResults = results;

        // Reset selection to first item
        if (results.length > 0) {
            searchList.currentIndex = 0;
        }
    }

    function executeResult(result) {
        if (!result)
            return;

        DebugUtils.debug("Executing result:", result.title, "Action:", result.action);

        switch (result.action) {
        case "launch":
            // Launch application using DesktopEntry.execute()
            if (result.execute && typeof result.execute === "function") {
                result.execute();
            } else if (result.data && result.data.execute) {
                result.data.execute();
            } else if (typeof result.data === "string") {
                // Fallback: execute as command
                Quickshell.execDetached([result.data]);
            }
            break;
        case "copy":
            // Copy to clipboard
            Quickshell.clipboardText = result.data;
            break;
        case "web":
            // Open web search
            Qt.openUrlExternally("https://www.google.com/search?q=" + encodeURIComponent(result.data));
            break;
        default:
            DebugUtils.warn("Unknown action:", result.action);
        }

        // Hide search window after execution
        searchWindow.hideSearch();
    }
}
