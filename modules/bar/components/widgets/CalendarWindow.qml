import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls
import Quickshell
import "../../../../services"
import "../../../../config"

PopupWindow {
    id: calendarWindow

    implicitWidth: 320
    implicitHeight: 360
    visible: false
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Colours.semantic.backgroundMain
        radius: Appearance.rounding.larger
        border.color: Colours.alpha(Colours.m3outline, 0.2)
        border.width: 1

        // HoverHandler to detect hover and prevent closing
        HoverHandler {
            id: calendarHover

            onHoveredChanged: {
                if (CalendarManager.hoverMode) {
                    if (hovered) {
                        CalendarManager.calendarHovered = true;
                        CalendarManager.stopHideTimer();
                    } else {
                        CalendarManager.calendarHovered = false;
                        CalendarManager.startHideTimer();
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
            shadowColor: Colours.alpha(Colours.m3shadow, 0.4)
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Month/Year header with navigation
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    width: 32
                    height: 32
                    radius: Appearance.rounding.smaller
                    color: mouseArea1.containsMouse ? Colours.alpha(Colours.m3primary, 0.12) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "‹"
                        color: Colours.semantic.accent
                        font.pointSize: Appearance.font.size.title
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: mouseArea1
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

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: calendar.monthNames[calendar.displayedMonth] + " " + calendar.displayedYear
                    color: Colours.semantic.textPrimary
                    font.pointSize: Appearance.font.size.large
                    font.weight: Font.Medium
                    font.family: Appearance.font.family.display
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: Appearance.rounding.smaller
                    color: mouseArea2.containsMouse ? Colours.alpha(Colours.m3primary, 0.12) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "›"
                        color: Colours.semantic.accent
                        font.pointSize: Appearance.font.size.title
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: mouseArea2
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

            // Day labels
            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 4
                columnSpacing: 4

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
                        Layout.preferredHeight: 24
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
                                if (mouseArea.containsMouse)
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
                                font.pointSize: Appearance.font.size.normal
                                font.weight: parent.isToday ? Font.Bold : Font.Normal
                                font.family: Appearance.font.family.display
                            }

                            MouseArea {
                                id: mouseArea
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
                height: 32
                radius: Appearance.rounding.normal
                color: todayMouseArea.containsMouse ? Colours.alpha(Colours.m3primary, 0.15) : Colours.alpha(Colours.m3primary, 0.08)
                border.width: 1
                border.color: Colours.alpha(Colours.m3primary, 0.3)

                Text {
                    anchors.centerIn: parent
                    text: "Today"
                    color: Colours.semantic.accent
                    font.pointSize: Appearance.font.size.normal
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
