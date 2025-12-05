import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../../../../services"
import "../../../settings" as Settings
import "../../../../utils"
import "../../../../widgets" as Widgets
import "../../../../config"

PanelWindow {
    id: actionCenterWindow

    // Screen property for multi-monitor support
    property ShellScreen targetScreen: null
    screen: targetScreen

    anchors {
        top: true
        bottom: true
        right: true
    }

    margins {
        top: 10
        bottom: 10
        right: 10
    }

    implicitWidth: 380
    visible: false
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "waffles-actioncenter-" + (targetScreen?.name || "unknown")
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.exclusiveZone: -1

    // Process for wlogout command
    Process {
        id: wlogoutProcess
        command: ["wlogout", "-b", "3", "-T", "250", "-B", "250", "-L", "500", "-R", "500", "-c", "40", "-r", "40", "--protocol", "layer-shell"]
        running: false
    }

    // Handle visibility changes and focus
    onVisibleChanged: {
        if (visible) {
            focusScope.forceActiveFocus();
        }
    }

    // Function to close the action center
    function closeActionCenter() {
        ActionCenterManager.closeActionCenter();
    }

    // Focus scope for keyboard handling
    FocusScope {
        id: focusScope
        anchors.fill: parent
        focus: actionCenterWindow.visible

        // Global keyboard handler for escape key
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                closeActionCenter();
                event.accepted = true;
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Colours.semantic.backgroundMain
            radius: Appearance.rounding.large
            border.color: Qt.alpha("#938f99", 0.2)
            border.width: 1

            // HoverHandler to detect hover and prevent closing
            HoverHandler {
                id: actionCenterHover

                onHoveredChanged: {
                    if (ActionCenterManager.hoverMode) {
                        if (hovered) {
                            ActionCenterManager.actionCenterHovered = true;
                            ActionCenterManager.stopHideTimer();
                        } else {
                            ActionCenterManager.actionCenterHovered = false;
                            ActionCenterManager.startHideTimer();
                        }
                    }
                }
            }

            // Subtle shadow effect
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.8
                shadowHorizontalOffset: 4
                shadowVerticalOffset: 4
                shadowColor: Qt.alpha("#000000", 0.4)
            }

            ScrollView {
                anchors.fill: parent
                anchors.margins: 20
                contentWidth: availableWidth
                clip: true

                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    width: parent.width
                    spacing: 16

                    // Header
                    Rectangle {
                        width: parent.width
                        height: 40
                        color: "transparent"

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Action Center"
                            font.family: Appearance.font.family.display
                            font.pointSize: Appearance.font.size.title
                            font.weight: Font.Medium
                            color: Colours.semantic.textPrimary
                        }

                        // Header button row
                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            // Power button
                            Widgets.HoverableIconButton {
                                width: 32
                                height: 32
                                icon: "power_settings_new"
                                hoverColor: Qt.alpha("#938f99", 0.15)
                                onClicked: {
                                    wlogoutProcess.running = true;
                                }
                            }

                            // Settings button
                            Widgets.HoverableIconButton {
                                width: 32
                                height: 32
                                icon: "settings"
                                hoverColor: Qt.alpha("#938f99", 0.15)
                                onClicked: {
                                    SettingsManager.showSettingsWindow();
                                }
                            }

                            // Close button
                            Widgets.CloseButton {
                                onClicked: {
                                    closeActionCenter();
                                }
                            }
                        }
                    }

                    // Separator
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Qt.alpha("#938f99", 0.3)
                    }

                    // Notifications Section
                    Rectangle {
                        width: parent.width
                        height: 360
                        color: Qt.alpha("#938f99", 0.05)
                        radius: Appearance.rounding.larger
                        border.width: 1
                        border.color: Qt.alpha("#938f99", 0.1)

                        NotificationHistoryContent {
                            anchors.fill: parent
                            anchors.margins: 16
                            showHeader: true  // Show header with clear all button
                            compactMode: true  // Use compact mode for Action Center
                        }
                    }

                    // Calendar Section
                    Rectangle {
                        width: parent.width
                        height: 400
                        color: Qt.alpha("#938f99", 0.05)
                        radius: Appearance.rounding.larger
                        border.width: 1
                        border.color: Qt.alpha("#938f99", 0.1)

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            // Calendar header
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Widgets.MaterialIcon {
                                    text: "calendar_month"
                                    font.pointSize: Appearance.font.size.normal
                                    color: Colours.m3primary
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: calendar.monthNames[calendar.displayedMonth] + " " + calendar.displayedYear
                                    color: Colours.semantic.textPrimary
                                    font.pointSize: Appearance.font.size.larger
                                    font.weight: Font.Medium
                                    font.family: Appearance.font.family.display
                                }

                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: Appearance.rounding.smaller
                                    color: prevMonthArea.containsMouse ? Colours.alpha(Colours.m3primary, 0.12) : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "‹"
                                        color: Colours.semantic.accent
                                        font.pointSize: Appearance.font.size.large
                                        font.weight: Font.Bold
                                    }

                                    MouseArea {
                                        id: prevMonthArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            let newDate = new Date(calendar.displayedYear, calendar.displayedMonth - 1, 1);
                                            calendar.displayedYear = newDate.getFullYear();
                                            calendar.displayedMonth = newDate.getMonth();
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: Appearance.rounding.smaller
                                    color: nextMonthArea.containsMouse ? Colours.alpha(Colours.m3primary, 0.12) : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "›"
                                        color: Colours.semantic.accent
                                        font.pointSize: Appearance.font.size.large
                                        font.weight: Font.Bold
                                    }

                                    MouseArea {
                                        id: nextMonthArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            let newDate = new Date(calendar.displayedYear, calendar.displayedMonth + 1, 1);
                                            calendar.displayedYear = newDate.getFullYear();
                                            calendar.displayedMonth = newDate.getMonth();
                                        }
                                    }
                                }
                            }

                            // Separator
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                color: Colours.m3outline
                            }

                            // Day labels
                            GridLayout {
                                Layout.fillWidth: true
                                columns: 7
                                rowSpacing: 4
                                columnSpacing: 8

                                Repeater {
                                    model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                                    Text {
                                        required property string modelData
                                        text: modelData
                                        color: Colours.alpha(Colours.m3outline, 0.8)
                                        font.pointSize: Appearance.font.size.smaller
                                        font.weight: Font.Medium
                                        font.family: Appearance.font.family.display
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.preferredWidth: 32
                                        Layout.preferredHeight: 20
                                    }
                                }
                            }

                            // Calendar grid
                            Item {
                                id: calendar
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                property var currentDate: new Date()
                                property int displayedMonth: currentDate.getMonth()
                                property int displayedYear: currentDate.getFullYear()
                                property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

                                GridLayout {
                                    anchors.fill: parent
                                    columns: 7
                                    rowSpacing: 4
                                    columnSpacing: 4

                                    Repeater {
                                        model: 42 // 6 weeks × 7 days

                                        Rectangle {
                                            required property int index
                                            Layout.preferredWidth: 32
                                            Layout.preferredHeight: 32
                                            radius: Appearance.rounding.smaller

                                            property var date: {
                                                let firstDay = new Date(calendar.displayedYear, calendar.displayedMonth, 1);
                                                let startDate = new Date(firstDay);
                                                startDate.setDate(startDate.getDate() - firstDay.getDay());
                                                let currentDate = new Date(startDate);
                                                currentDate.setDate(startDate.getDate() + index);
                                                return currentDate;
                                            }

                                            property bool isCurrentMonth: date.getMonth() === calendar.displayedMonth
                                            property bool isToday: {
                                                let today = new Date();
                                                return date.getDate() === today.getDate() && date.getMonth() === today.getMonth() && date.getFullYear() === today.getFullYear();
                                            }

                                            color: {
                                                if (isToday)
                                                    return Colours.semantic.accent;
                                                if (dayMouseArea.containsMouse)
                                                    return Colours.alpha(Colours.m3primary, 0.12);
                                                return "transparent";
                                            }

                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: 150
                                                    easing.type: Easing.OutQuad
                                                }
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                text: parent.date.getDate()
                                                color: {
                                                    if (parent.isToday)
                                                        return Colours.m3surface;
                                                    if (parent.isCurrentMonth)
                                                        return Colours.m3onSurface;
                                                    return Colours.alpha(Colours.m3outline, 0.4);
                                                }
                                                font.pointSize: Appearance.font.size.small
                                                font.weight: parent.isToday ? Font.Bold : Font.Normal
                                                font.family: Appearance.font.family.display
                                            }

                                            MouseArea {
                                                id: dayMouseArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                            }
                                        }
                                    }
                                }
                            }

                            // Today button
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 60
                                height: 28
                                radius: Appearance.rounding.normal
                                color: todayMouseArea.containsMouse ? Colours.alpha(Colours.m3primary, 0.15) : Colours.alpha(Colours.m3primary, 0.08)
                                border.width: 1
                                border.color: Colours.alpha(Colours.m3primary, 0.3)

                                Text {
                                    anchors.centerIn: parent
                                    text: "Today"
                                    color: Colours.semantic.accent
                                    font.pointSize: Appearance.font.size.small
                                    font.family: Appearance.font.family.display
                                }

                                MouseArea {
                                    id: todayMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        let today = new Date();
                                        calendar.displayedMonth = today.getMonth();
                                        calendar.displayedYear = today.getFullYear();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
