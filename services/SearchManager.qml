pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: searchManager

    property bool searchVisible: false
    property var searchWindow: null

    // Methods to control search visibility
    function showSearch() {
        searchVisible = true;
        if (!searchWindow)
            return;

        // Prefer explicit API on the window (showSearch), fall back to show/hide or visible property.
        if (searchWindow.showSearch && typeof searchWindow.showSearch === 'function') {
            searchWindow.showSearch();
        } else if (searchWindow.show && typeof searchWindow.show === 'function') {
            searchWindow.show();
        } else if (typeof searchWindow.visible !== 'undefined') {
            searchWindow.visible = true;
        }
    }

    function hideSearch() {
        searchVisible = false;
        if (!searchWindow)
            return;

        if (searchWindow.hideSearch && typeof searchWindow.hideSearch === 'function') {
            searchWindow.hideSearch();
        } else if (searchWindow.hide && typeof searchWindow.hide === 'function') {
            searchWindow.hide();
        } else if (typeof searchWindow.visible !== 'undefined') {
            searchWindow.visible = false;
        }
    }

    function toggleSearch() {
        if (searchVisible) {
            hideSearch();
        } else {
            showSearch();
        }
    }

    // Set the search window reference
    function setSearchWindow(window) {
        searchWindow = window;

        // Keep manager in sync if the window updates the visible property directly.
        try {
            if (searchWindow && typeof searchWindow.visible !== 'undefined') {
                searchVisible = !!searchWindow.visible;
            }
        } catch (e)
        // ignore
        {}
    }
}
