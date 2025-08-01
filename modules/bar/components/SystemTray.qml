pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../../utils"
import "../../common"

Column {
    id: root
    spacing: 8
    width: 40

    // Context menu for system tray items
    PopupWindow {
        id: contextMenu
        implicitWidth: 200
        implicitHeight: Math.max(40, menuListView.contentHeight + 12)
        visible: false
        color: "transparent"

        property var menu
        property var anchorItem: null
        property bool menuHovered: false

        anchor.item: anchorItem
        anchor.rect.x: 0
        anchor.rect.y: -4

        // Timer for hiding context menu in hover mode
        property Timer hideTimer: Timer {
            interval: 200
            onTriggered: {
                if (InteractionSettings.hoverMode && !contextMenu.menuHovered) {
                    contextMenu.hideMenu();
                }
            }
        }

        function showAt(item) {
            if (!item) {
                DebugUtils.log("SystemTray: Cannot show menu - no anchor item");
                return;
            }
            hideTimer.stop();
            anchorItem = item;
            visible = true;
            Qt.callLater(() => contextMenu.anchor.updateAnchor());
        }

        function hideMenu() {
            visible = false;
            menuHovered = false;
        }

        function startHideTimer() {
            if (InteractionSettings.hoverMode) {
                hideTimer.restart();
            }
        }

        function stopHideTimer() {
            hideTimer.stop();
        }

        // HoverHandler to detect hover over context menu for hover mode
        HoverHandler {
            id: contextMenuHover
            onHoveredChanged: {
                if (InteractionSettings.hoverMode) {
                    contextMenu.menuHovered = hovered;
                    if (hovered) {
                        contextMenu.stopHideTimer();
                    } else {
                        contextMenu.startHideTimer();
                    }
                }
            }
        }

        Item {
            anchors.fill: parent
            Keys.onEscapePressed: contextMenu.hideMenu()
        }

        QsMenuOpener {
            id: menuOpener
            menu: contextMenu.menu
        }

        Rectangle {
            anchors.fill: parent
            color: "#2d2d30"
            border.color: Qt.alpha("#938f99", 0.3)
            border.width: 1
            radius: 8
        }

        ListView {
            id: menuListView
            anchors.fill: parent
            anchors.margins: 6
            spacing: 2
            interactive: false
            enabled: contextMenu.visible
            clip: true

            model: ScriptModel {
                values: menuOpener.children ? [...menuOpener.children.values] : []
            }

            delegate: Rectangle {
                id: menuEntry
                required property var modelData

                width: menuListView.width
                height: (menuEntry.modelData?.isSeparator) ? 8 : 32
                color: "transparent"
                radius: 6

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 8
                    height: 1
                    color: Qt.alpha("#938f99", 0.4)
                    visible: menuEntry.modelData?.isSeparator ?? false
                }

                Rectangle {
                    anchors.fill: parent
                    color: menuMouseArea.containsMouse ? Qt.alpha("#938f99", 0.2) : "transparent"
                    radius: 6
                    visible: !(menuEntry.modelData?.isSeparator ?? false)

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 20
                            color: (menuEntry.modelData?.enabled ?? true) ? "#e6e0e9" : "#6c6c6c"
                            text: menuEntry.modelData?.text ?? ""
                            font.family: "JetBrains Mono"
                            font.pointSize: 9
                            elide: Text.ElideRight
                        }

                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 16
                            height: 16
                            source: menuEntry.modelData?.icon ?? ""
                            visible: (menuEntry.modelData?.icon ?? "") !== ""
                            smooth: true
                        }
                    }

                    MouseArea {
                        id: menuMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: (menuEntry.modelData?.enabled ?? true) && !(menuEntry.modelData?.isSeparator ?? false) && contextMenu.visible
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (menuEntry.modelData && !menuEntry.modelData.isSeparator) {
                                DebugUtils.log("SystemTray: Menu item clicked:", menuEntry.modelData.text);
                                menuEntry.modelData.triggered();
                                contextMenu.hideMenu();
                            }
                        }

                        onEntered: {
                            if (InteractionSettings.hoverMode && menuEntry.modelData && !menuEntry.modelData.isSeparator) {
                                // In hover mode, trigger menu items on hover after a delay
                                menuHoverTimer.start();
                            }
                        }

                        onExited: {
                            if (InteractionSettings.hoverMode) {
                                menuHoverTimer.stop();
                            }
                        }

                        Timer {
                            id: menuHoverTimer
                            interval: 800  // Slightly longer delay for menu items
                            repeat: false
                            onTriggered: {
                                if (menuMouseArea.containsMouse && InteractionSettings.hoverMode && menuEntry.modelData && !menuEntry.modelData.isSeparator) {
                                    DebugUtils.log("SystemTray: Menu item hovered:", menuEntry.modelData.text);
                                    menuEntry.modelData.triggered();
                                    contextMenu.hideMenu();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Background container similar to StatusGroup
    Rectangle {
        width: 44
        height: repeater.count > 0 ? (repeater.count * 32 + (repeater.count - 1) * 8 + 16) : 0
        radius: 17
        anchors.horizontalCenter: parent.horizontalCenter
        visible: repeater.count > 0

        color: Qt.alpha("#d0bcff", 0.05)
        border.width: 1
        border.color: Qt.alpha("#938f99", 0.08)

        // Subtle background gradient
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.alpha("#d0bcff", 0.02)
                }
                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                id: repeater
                model: SystemTray.items

                Rectangle {
                    required property SystemTrayItem modelData

                    width: 32
                    height: 32
                    radius: 8
                    color: mouseArea.containsMouse ? Qt.alpha("#938f99", 0.2) : "transparent"
                    // Remove individual borders
                    border.width: 0

                    Image {
                        id: trayIcon
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        source: {
                            let icon = parent.modelData.icon || "";
                            if (!icon)
                                return "";

                            // Handle special icon path format used by some applications
                            if (icon.includes("?path=")) {
                                const [name, path] = icon.split("?path=");
                                const fileName = name.substring(name.lastIndexOf("/") + 1);
                                return `file://${path}/${fileName}`;
                            }
                            return icon;
                        }
                        smooth: true
                        mipmap: true
                        asynchronous: true

                        // Fallback for missing icons
                        Rectangle {
                            anchors.fill: parent
                            visible: trayIcon.status === Image.Error || !trayIcon.source
                            color: Qt.alpha("#938f99", 0.3)
                            radius: 4

                            Text {
                                anchors.centerIn: parent
                                text: "?"
                                font.family: "JetBrains Mono"
                                font.pointSize: 10
                                color: "#e6e0e9"
                            }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor

                        onClicked: function (mouse) {
                            if (!parent.modelData)
                                return;

                            DebugUtils.log("SystemTray: Click detected, button:", mouse.button);
                            DebugUtils.log("SystemTray: Item title:", parent.modelData.title);
                            DebugUtils.log("SystemTray: Item id:", parent.modelData.id);
                            DebugUtils.log("SystemTray: Item hasMenu:", parent.modelData.hasMenu);
                            DebugUtils.log("SystemTray: Item onlyMenu:", parent.modelData.onlyMenu);

                            if (mouse.button === Qt.LeftButton) {
                                // Close any open context menu first
                                if (contextMenu.visible) {
                                    contextMenu.hideMenu();
                                }

                                DebugUtils.log("SystemTray: Left click - checking onlyMenu flag");
                                if (!parent.modelData.onlyMenu) {
                                    DebugUtils.log("SystemTray: Calling activate() - not menu-only");
                                    parent.modelData.activate();
                                } else {
                                    DebugUtils.log("SystemTray: Skipping activate() - item is menu-only");
                                }
                            } else if (mouse.button === Qt.RightButton && !InteractionSettings.hoverMode) {
                                // Only handle right-click in click mode
                                DebugUtils.log("SystemTray: Right click - checking for context menu");

                                // If menu is already visible, close it
                                if (contextMenu.visible) {
                                    contextMenu.hideMenu();
                                    return;
                                }

                                // Show context menu
                                showContextMenu();
                            }
                        }

                        onEntered: {
                            if (InteractionSettings.hoverMode && parent.modelData.hasMenu) {
                                // In hover mode, show context menu on enter
                                contextMenuTimer.start();
                            }
                        }

                        onExited: {
                            if (InteractionSettings.hoverMode) {
                                // In hover mode, start hide timer when leaving tray item
                                contextMenuTimer.stop();
                                contextMenu.startHideTimer();
                            }
                        }

                        function showContextMenu() {
                            if (parent.modelData.hasMenu) {
                                DebugUtils.log("SystemTray: Showing context menu for:", parent.modelData.title);
                                try {
                                    contextMenu.menu = parent.modelData.menu;
                                    contextMenu.showAt(parent);
                                } catch (error) {
                                    DebugUtils.log("SystemTray: Error showing context menu:", error);
                                    DebugUtils.log("SystemTray: Falling back to secondaryActivate()");
                                    if (parent.modelData.secondaryActivate) {
                                        parent.modelData.secondaryActivate();
                                    }
                                }
                            } else {
                                DebugUtils.log("SystemTray: No context menu available, calling secondaryActivate()");
                                if (parent.modelData.secondaryActivate) {
                                    parent.modelData.secondaryActivate();
                                } else {
                                    DebugUtils.log("SystemTray: No secondaryActivate method available");
                                }
                            }
                        }

                        // Timer to delay context menu show in hover mode
                        Timer {
                            id: contextMenuTimer
                            interval: 500
                            repeat: false
                            onTriggered: {
                                if (mouseArea.containsMouse && InteractionSettings.hoverMode) {
                                    mouseArea.showContextMenu();
                                }
                            }
                        }
                    }

                    // Simple tooltip using Rectangle
                    Rectangle {
                        property SystemTrayItem item: parent.modelData
                        visible: mouseArea.containsMouse && hoverTimer.triggered && item.title
                        anchors.bottom: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 8
                        width: tooltipText.width + 16
                        height: tooltipText.height + 8
                        color: "#1c1b1f"
                        border.color: Qt.alpha("#938f99", 0.3)
                        border.width: 1
                        radius: 6
                        z: 100

                        Text {
                            id: tooltipText
                            anchors.centerIn: parent
                            text: parent.item.title || ""
                            font.family: "JetBrains Mono"
                            font.pointSize: 9
                            color: "#e6e0e9"
                        }
                    }

                    Timer {
                        id: hoverTimer
                        interval: 1000
                        running: mouseArea.containsMouse
                        repeat: false
                        property bool triggered: false
                        onTriggered: triggered = true
                        onRunningChanged: if (!running)
                            triggered = false
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
    }
}
