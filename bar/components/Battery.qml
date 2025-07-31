import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../../widgets" as Widgets

Rectangle {
    id: root

    implicitWidth: 44
    implicitHeight: content.implicitHeight + 16
    radius: 17

    color: hoverArea.containsMouse ? Qt.alpha("#d0bcff", 0.08) : "transparent"

    property var battery: UPower.displayDevice
    property bool isCharging: !UPower.onBattery
    property int percentage: battery ? Math.round(battery.percentage * 100) : 0
    property bool isLowBattery: percentage < 20 && !isCharging

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

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: root.scale = 0.95
        onReleased: root.scale = 1.0
        onCanceled: root.scale = 1.0
    }

    Column {
        id: content
        anchors.centerIn: parent
        spacing: 4

        Widgets.MaterialIcon {
            id: batteryIcon
            anchors.horizontalCenter: parent.horizontalCenter
            animate: true

            color: root.isLowBattery ? "#f2b8b5" : root.isCharging ? "#a6d4a9" : "#e6e0e9"
            font.pointSize: 22
            fill: hoverArea.containsMouse ? 1 : 0

            text: {
                if (!root.battery || !root.battery.isLaptopBattery)
                    return "battery_unknown";

                if (root.isCharging) {
                    if (root.percentage >= 95)
                        return "battery_charging_full";
                    else if (root.percentage >= 80)
                        return "battery_charging_90";
                    else if (root.percentage >= 60)
                        return "battery_charging_80";
                    else if (root.percentage >= 50)
                        return "battery_charging_60";
                    else if (root.percentage >= 30)
                        return "battery_charging_50";
                    else if (root.percentage >= 20)
                        return "battery_charging_30";
                    else
                        return "battery_charging_20";
                } else {
                    if (root.percentage >= 95)
                        return "battery_full";
                    else if (root.percentage >= 80)
                        return "battery_6_bar";
                    else if (root.percentage >= 65)
                        return "battery_5_bar";
                    else if (root.percentage >= 50)
                        return "battery_4_bar";
                    else if (root.percentage >= 35)
                        return "battery_3_bar";
                    else if (root.percentage >= 20)
                        return "battery_2_bar";
                    else if (root.percentage >= 10)
                        return "battery_1_bar";
                    else
                        return "battery_0_bar";
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                }
            }
        }

        Widgets.StyledText {
            id: percentageText
            anchors.horizontalCenter: parent.horizontalCenter
            animate: true

            font.family: "JetBrains Mono"
            font.pointSize: 8
            font.weight: 500
            color: root.isLowBattery ? "#f2b8b5" : "#cac4d0"

            text: {
                if (!root.battery || !root.battery.isLaptopBattery)
                    return "??";
                return root.percentage + "%";
            }

            opacity: hoverArea.containsMouse ? 1.0 : 0.8

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                }
            }
        }
    }

    // Low battery warning animation
    SequentialAnimation {
        running: root.isLowBattery
        loops: Animation.Infinite

        NumberAnimation {
            target: batteryIcon
            property: "opacity"
            from: 1.0
            to: 0.3
            duration: 1000
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: batteryIcon
            property: "opacity"
            from: 0.3
            to: 1.0
            duration: 1000
            easing.type: Easing.InOutSine
        }
    }
}
