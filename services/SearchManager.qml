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
        if (searchWindow && searchWindow.show) {
            searchWindow.show();
        }
    }

    function hideSearch() {
        searchVisible = false;
        if (searchWindow && searchWindow.hide) {
            searchWindow.hide();
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
    }
}
