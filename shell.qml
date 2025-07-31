import Quickshell
import QtQuick
import "bar"
import "bar/components" as Components

ShellRoot {
    Bar {
        id: mainBar
    }

    Components.CalendarWindow {
        id: calendarWindow
        objectName: "calendarWindow"
        anchor.window: mainBar
        anchor.rect.x: 70    // Position directly to the right of the bar
        anchor.rect.y: 440  // Center vertically relative to the screen center
        visible: CalendarManager.calendarVisible
    }

    Components.ActionCenterWindow {
        id: actionCenterWindow
        objectName: "actionCenterWindow"
        anchor.window: mainBar
        anchor.rect.x: 70    // Position directly to the right of the bar
        anchor.rect.y: 660   // Position below the calendar
        visible: ActionCenterManager.actionCenterVisible
    }
}
