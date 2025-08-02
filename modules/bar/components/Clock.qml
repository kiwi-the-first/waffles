import Quickshell
import QtQuick
import "../../../widgets" as Widgets
import "../../../services" as Root

Rectangle {
    id: root

    property color colour: "#ffffff"
    property bool calendarVisible: false

    implicitWidth: 44
    implicitHeight: content.implicitHeight + 16
    radius: 17

    color: hoverArea.containsMouse ? Qt.alpha("#d0bcff", 0.08) : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 400
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: root.scale = 0.95
        onReleased: root.scale = 1.0
        onCanceled: root.scale = 1.0

        onClicked: {
            Root.CalendarManager.toggleCalendar();
        }

        onEntered: {
            if (Root.CalendarManager.hoverMode) {
                Root.CalendarManager.stopHideTimer(); // Cancel any pending hide
                Root.CalendarManager.showCalendar();
            }
        }

        onExited: {
            if (Root.CalendarManager.hoverMode) {
                Root.CalendarManager.startHideTimer(); // Start delay before hiding
            }
        }
    }

    Column {
        id: content
        anchors.centerIn: parent
        spacing: 4

        // Calendar icon
        Widgets.MaterialIcon {
            id: calendarIcon
            anchors.horizontalCenter: parent.horizontalCenter
            animate: true

            text: "calendar_month"
            color: "#e6e0e9"
            font.pointSize: 15
            fill: hoverArea.containsMouse ? 1 : 0
            grade: hoverArea.containsMouse ? 0 : -25

            Behavior on grade {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                }
            }
        }

        // Time display
        Widgets.StyledText {
            id: timeText
            anchors.horizontalCenter: parent.horizontalCenter
            animate: true

            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDateTime(systemClock.date, "HH\nmm")
            color: "#cac4d0"
            font.pointSize: 13
            font.family: "JetBrains Mono"
            font.weight: 500

            opacity: hoverArea.containsMouse ? 1.0 : 0.8

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }
    }
}
