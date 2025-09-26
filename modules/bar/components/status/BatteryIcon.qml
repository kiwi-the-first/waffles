pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.UPower
import "../../../../widgets" as Widgets
import "../../../../config"

Rectangle {
    id: batteryRect
    width: 36
    height: 36
    radius: Appearance.rounding.larger
    color: batteryHover.containsMouse ? Colours.alpha(Colours.m3primary, 0.12) : "transparent"

    property var battery: UPower.displayDevice
    property bool isCharging: !UPower.onBattery
    property int percentage: battery ? Math.round(battery.percentage * 100) : 0
    property bool isLowBattery: percentage < 20 && !isCharging

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    MouseArea {
        id: batteryHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    Text {
        anchors.centerIn: parent

        text: {
            if (batteryHover.containsMouse)
                return batteryRect.percentage.toString();
            return "";
        }

        // Only visible when hovered
        opacity: batteryHover.containsMouse ? 1 : 0

        font.family: Appearance.font.family.display
        font.pointSize: Appearance.font.size.body
        font.weight: Font.Medium
        color: parent.isLowBattery ? Colours.m3error : Colours.m3onSurface

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
    }

    Widgets.MaterialIcon {
        id: batteryIcon
        anchors.centerIn: parent
        animate: true
        color: parent.isLowBattery ? Colours.m3error : parent.isCharging ? Colours.m3primary : Colours.m3onSurface
        font.pointSize: Appearance.font.size.iconMedium
        // fill: batteryHover.containsMouse ? 1 : 0

        // Hide the icon while hovered so the percentage Text is shown instead
        opacity: batteryHover.containsMouse ? 0 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }

        text: {
            if (!batteryHover.containsMouse) {
                if (!parent.battery || !parent.battery.isLaptopBattery)
                    return "battery_unknown";

                if (parent.isCharging) {
                    if (parent.percentage >= 95)
                        // return "battery_charging_full";
                        return "battery_full";
                    if (parent.percentage >= 80)
                        return "battery_charging_90";
                    if (parent.percentage >= 60)
                        return "battery_charging_80";
                    if (parent.percentage >= 50)
                        return "battery_charging_60";
                    if (parent.percentage >= 30)
                        return "battery_charging_50";
                    if (parent.percentage >= 20)
                        return "battery_charging_30";
                    return "battery_charging_20";
                } else {
                    if (parent.percentage >= 95)
                        return "battery_full";
                    if (parent.percentage >= 80)
                        return "battery_6_bar";
                    if (parent.percentage >= 65)
                        return "battery_5_bar";
                    if (parent.percentage >= 50)
                        return "battery_4_bar";
                    if (parent.percentage >= 35)
                        return "battery_3_bar";
                    if (parent.percentage >= 20)
                        return "battery_2_bar";
                    if (parent.percentage >= 10)
                        return "battery_1_bar";
                    return "battery_0_bar";
                }
            }
            return "";
        }
    }

    // Low battery warning animation
    // SequentialAnimation {
    //     running: batteryRect.isLowBattery
    //     loops: Animation.Infinite
    //
    //     NumberAnimation {
    //         target: batteryIcon
    //         property: "opacity"
    //         from: 1.0
    //         to: 0.3
    //         duration: 1000
    //         easing.type: Easing.InOutSine
    //     }
    //     NumberAnimation {
    //         target: batteryIcon
    //         property: "opacity"
    //         from: 0.3
    //         to: 1.0
    //         duration: 1000
    //         easing.type: Easing.InOutSine
    //     }
    // }
}
