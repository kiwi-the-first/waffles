//@ pragma IconTheme Papirus-Dark
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import "modules/bar"
import "modules/bar/components" as Components
import "modules/bar/components/widgets" as Widgets
import "services"

ShellRoot {
    // Force IPCManager instantiation (required for IpcHandlers to work)
    property var ipcManager: IPCManager

    Bar {
        id: mainBar

        // Handle keyboard focus when password dialog or search window is visible
        WlrLayershell.keyboardFocus: (NetworkManager.passwordDialogVisible || SearchManager.searchVisible) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    }

    Widgets.CalendarWindow {
        id: calendarWindow
        objectName: "calendarWindow"
        anchor.window: mainBar
        anchor.rect.x: 70    // Position directly to the right of the bar
        anchor.rect.y: 440  // Center vertically relative to the screen center
        visible: CalendarManager.calendarVisible
    }

    Widgets.ActionCenterWindow {
        id: actionCenterWindow
        objectName: "actionCenterWindow"
        anchor.window: mainBar
        anchor.rect.x: 70
        anchor.rect.y: 660
        visible: ActionCenterManager.actionCenterVisible
    }

    Widgets.NetworkSelectorWindow {
        id: networkSelectorWindow
        objectName: "networkSelectorWindow"
        anchor.window: mainBar
        anchor.rect.x: 70
        anchor.rect.y: 800  // Position near the network icon
        visible: NetworkManager.networkSelectorVisible
    }

    Widgets.SearchWindow {
        id: searchWindow
        objectName: "searchWindow"
        anchor.window: mainBar
        anchor.rect.x: (mainBar.screen.width - searchWindow.implicitWidth) / 2  // Center horizontally
        anchor.rect.y: (mainBar.screen.height - searchWindow.implicitHeight) / 2  // Center vertically
        visible: SearchManager.searchVisible

        Component.onCompleted: {
            SearchManager.setSearchWindow(searchWindow);
        }
    }

    Widgets.SettingsWindow {
        id: settingsWindow
        objectName: "settingsWindow"
        anchor.window: mainBar
        anchor.rect.x: (mainBar.screen.width - searchWindow.implicitWidth) / 2  // Center horizontally
        anchor.rect.y: (mainBar.screen.height - searchWindow.implicitHeight) / 2  // Center vertically
        // anchor.rect.x: 70
        // anchor.rect.y: 440
        visible: SettingsManager.settingsWindowVisible
    }

    Widgets.WorkspaceWindow {
        id: workspaceWindow
        objectName: "workspaceWindow"
        anchor.window: mainBar
        anchor.rect.x: 70    // Position directly to the right of the bar
        anchor.rect.y: -4   // Position above the calendar
        visible: WorkspaceManager.workspaceWindowVisible
    }

    // OSD window for volume and brightness controls
    Widgets.OSDWindowPopup {
        id: osdWindow
        objectName: "osdWindow"
        anchor.window: mainBar
        anchor.rect.x: (mainBar.screen.width - osdWindow.implicitWidth) / 2  // Center on screen
        anchor.rect.y: 850   // Position above the calendar
        visible: OSDManager.osdVisible
    }
}
