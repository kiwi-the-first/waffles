//@ pragma IconTheme Papirus-Dark
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import qs.modules.bar
import qs.modules.clock
import qs.modules.bar.components as Components
import qs.modules.bar.components.widgets as Widgets
import qs.services

// import qs.utils

ShellRoot {
    // Force IPCManager instantiation (required for IpcHandlers to work)
    property var ipcManager: IPCManager

    // Notification popups (toast-style). Stacks from top-right of screen.
    // Already multi-monitor aware
    Widgets.NotificationPopupManager {
        id: notificationPopupManager
    }

    // Multi-monitor support: Create bar and related windows for each screen
    Variants {
        model: Quickshell.screens

        delegate: Item {
            id: screenDelegate
            required property ShellScreen modelData

            // Wallpaper for this screen
            Wallpaper {
                targetScreen: screenDelegate.modelData
            }

            // Bar for this screen
            Bar {
                id: screenBar
                targetScreen: screenDelegate.modelData

                // Handle keyboard focus when password dialog or search window is visible
                WlrLayershell.keyboardFocus: (NetworkManager.passwordDialogVisible || SearchManager.searchVisible) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            }

            // Calendar window for this screen
            Widgets.CalendarWindow {
                id: calendarWindow
                objectName: "calendarWindow-" + (screenDelegate.modelData?.name || "unknown")
                anchor.window: screenBar
                anchor.rect.x: 70    // Position directly to the right of the bar
                anchor.rect.y: 440   // Center vertically relative to the screen center
                visible: CalendarManager.calendarVisible
            }

            // Action Center window for this screen
            Widgets.ActionCenterWindow {
                id: actionCenterWindow
                objectName: "actionCenterWindow-" + (screenDelegate.modelData?.name || "unknown")
                targetScreen: screenDelegate.modelData
                visible: ActionCenterManager.actionCenterVisible
            }

            // Network selector window for this screen
            Widgets.NetworkSelectorWindow {
                id: networkSelectorWindow
                objectName: "networkSelectorWindow-" + (screenDelegate.modelData?.name || "unknown")
                anchor.window: screenBar
                anchor.rect.x: 70
                anchor.rect.y: 800   // Position near the network icon
                visible: NetworkManager.networkSelectorVisible
            }

            // Big clock for this screen
            BigClock {
                targetScreen: screenDelegate.modelData
                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }
                margins.left: -50
                margins.top: -600
            }

            // Search window for this screen
            Widgets.SearchWindow {
                id: searchWindow
                objectName: "searchWindow-" + (screenDelegate.modelData?.name || "unknown")
                targetScreen: screenDelegate.modelData
                visible: SearchManager.searchVisible

                Component.onCompleted: {
                    // Only register the first screen's search window
                    if (screenDelegate.modelData === Quickshell.screens[0]) {
                        SearchManager.setSearchWindow(searchWindow);
                    }
                }
            }

            // Settings window for this screen (uses PopupWindow, inherits screen from anchor)
            Widgets.SettingsWindow {
                id: settingsWindow
                objectName: "settingsWindow-" + (screenDelegate.modelData?.name || "unknown")
                anchor.window: screenBar
                anchor.rect.x: (screenDelegate.modelData ? screenDelegate.modelData.width - settingsWindow.implicitWidth : 500) / 2
                anchor.rect.y: (screenDelegate.modelData ? screenDelegate.modelData.height - settingsWindow.implicitHeight : 400) / 2
                visible: SettingsManager.settingsWindowVisible
            }

            // Workspace window for this screen
            Widgets.WorkspaceWindow {
                id: workspaceWindow
                objectName: "workspaceWindow-" + (screenDelegate.modelData?.name || "unknown")
                anchor.window: screenBar
                anchor.rect.x: 70    // Position directly to the right of the bar
                anchor.rect.y: -4    // Position above the calendar
                visible: WorkspaceManager.workspaceWindowVisible
            }

            // OSD window for volume and brightness controls
            Widgets.OSDWindowPopup {
                id: osdWindow
                objectName: "osdWindow-" + (screenDelegate.modelData?.name || "unknown")
                anchor.window: screenBar
                anchor.rect.x: (screenDelegate.modelData ? screenDelegate.modelData.width - osdWindow.implicitWidth : 240) / 2
                anchor.rect.y: 850   // Position above the calendar
                visible: OSDManager.osdVisible
            }
        }
    }
}
