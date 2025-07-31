import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../.." as Root

PopupWindow {
    id: calendarWindow

    implicitWidth: 320
    implicitHeight: 360
    visible: false
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#1c1b1f"
        radius: 12
        border.color: Qt.alpha("#938f99", 0.2)
        border.width: 1

        // HoverHandler to detect hover and prevent closing
        HoverHandler {
            id: calendarHover

            onHoveredChanged: {
                if (Root.CalendarManager.hoverMode) {
                    if (hovered) {
                        Root.CalendarManager.calendarHovered = true;
                        Root.CalendarManager.stopHideTimer();
                    } else {
                        Root.CalendarManager.calendarHovered = false;
                        Root.CalendarManager.startHideTimer();
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
                    radius: 6
                    color: mouseArea1.containsMouse ? Qt.alpha("#d0bcff", 0.12) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "‹"
                        color: "#d0bcff"
                        font.pointSize: 16
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
                    color: "#e6e0e9"
                    font.pointSize: 14
                    font.weight: Font.Medium
                    font.family: "JetBrains Mono"
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 6
                    color: mouseArea2.containsMouse ? Qt.alpha("#d0bcff", 0.12) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "›"
                        color: "#d0bcff"
                        font.pointSize: 16
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
                        color: Qt.alpha("#938f99", 0.8)
                        font.pointSize: 10
                        font.weight: Font.Medium
                        font.family: "JetBrains Mono"
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
                            radius: 6

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
                                    return "#d0bcff";
                                if (mouseArea.containsMouse)
                                    return Qt.alpha("#d0bcff", 0.12);
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
                                        return "#1c1b1f";
                                    if (parent.isCurrentMonth)
                                        return "#e6e0e9";
                                    return Qt.alpha("#938f99", 0.4);
                                }
                                font.pointSize: 11
                                font.weight: parent.isToday ? Font.Bold : Font.Normal
                                font.family: "JetBrains Mono"
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
                radius: 8
                color: todayMouseArea.containsMouse ? Qt.alpha("#d0bcff", 0.15) : Qt.alpha("#d0bcff", 0.08)
                border.width: 1
                border.color: Qt.alpha("#d0bcff", 0.3)

                Text {
                    anchors.centerIn: parent
                    text: "Today"
                    color: "#d0bcff"
                    font.pointSize: 11
                    font.family: "JetBrains Mono"
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
