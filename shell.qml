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

    Widgets.SettingsWindow {
        id: settingsWindow
        objectName: "settingsWindow"
        anchor.window: mainBar
        anchor.rect.x: 70
        anchor.rect.y: 440
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

    // Search window overlay - using FloatingWindow with proper namespace
    // FloatingWindow {
    //     id: searchWindowContainer
    //     objectName: "searchWindowContainer"
    //     screen: mainBar.screen
    //     visible: SearchManager.searchVisible
    //     color: "transparent"
    //     WlrLayershell.namespace: "waffles-launcher"
    //     WlrLayershell.layer: WlrLayer.Overlay
    //     WlrLayershell.exclusionMode: ExclusionMode.Ignore
    //     WlrLayershell.keyboardFocus: SearchManager.searchVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    //
    //     Widgets.SearchWindow {}
    // }

    // OSD window for volume and brightness controls
    Widgets.OSDWindowPopup {
        id: osdWindow
        objectName: "osdWindow"
        anchor.window: mainBar
        anchor.rect.x: -90  // Position to the left of the bar
        anchor.rect.y: 20   // Top margin
        visible: OSDManager.osdVisible
    }
}
