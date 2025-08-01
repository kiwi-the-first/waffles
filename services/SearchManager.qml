pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: searchManager

    property bool searchVisible: false
    property bool hoverMode: false
    property bool searchHovered: false

    property Timer hideTimer: Timer {
        id: hideTimer
        interval: 2000  // 2 seconds delay
        repeat: false
        onTriggered: {
            if (searchManager.hoverMode && !searchManager.searchHovered) {
                searchManager.searchVisible = false;
            }
        }
    }

    function showSearch() {
        searchVisible = true;
        if (hoverMode) {
            stopHideTimer();
        }
    }

    function hideSearch() {
        if (hoverMode) {
            startHideTimer();
        } else {
            searchVisible = false;
        }
    }

    function toggleSearch() {
        if (searchVisible) {
            hideSearch();
        } else {
            showSearch();
        }
    }

    function startHideTimer() {
        if (hoverMode) {
            hideTimer.restart();
        }
    }

    function stopHideTimer() {
        hideTimer.stop();
    }

    // Enable hover mode automatically after showing search
    onSearchVisibleChanged: {
        if (searchVisible) {
            hoverMode = true;
        } else {
            hoverMode = false;
            searchHovered = false;
        }
    }
}
