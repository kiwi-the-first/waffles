//@ pragma IconTheme Papirus-Dark
import Quickshell
import Quickshell.Wayland
import QtQuick
import "modules/bar"
import "modules/bar/components" as Components
import "modules/bar/components/widgets" as Widgets
import "services"

ShellRoot {
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

    Widgets.WorkspaceWindow {
        id: workspaceWindow
        objectName: "workspaceWindow"
        anchor.window: mainBar
        anchor.rect.x: 70    // Position directly to the right of the bar
        anchor.rect.y: -4   // Position above the calendar
        visible: WorkspaceManager.workspaceWindowVisible
    }

    // Search window overlay - using FloatingWindow with proper namespace
    FloatingWindow {
        id: searchWindowContainer
        objectName: "searchWindowContainer"
        screen: mainBar.screen
        visible: SearchManager.searchVisible
        color: "transparent"
        WlrLayershell.namespace: "waffles-launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: SearchManager.searchVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        Widgets.SearchWindow {}
    }
}
