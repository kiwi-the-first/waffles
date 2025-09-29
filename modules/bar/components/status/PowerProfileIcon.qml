pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.UPower
import "../../../../widgets" as Widgets
import "../../../../config"

Rectangle {
    id: powerProfileRect
    width: 36
    height: 36
    radius: Appearance.rounding.larger
    color: powerProfileHover.containsMouse ? Colours.alpha(Colours.m3primary, 0.12) : "transparent"

    property var currentProfile: PowerProfiles.profile
    property string profileName: PowerProfile.toString(currentProfile)

    // Hide the component if power profiles service is not available
    visible: PowerProfiles !== null

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    MouseArea {
        id: powerProfileHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            // Cycle through available power profiles
            if (powerProfileRect.currentProfile === PowerProfile.PowerSaver) {
                PowerProfiles.profile = PowerProfile.Balanced;
            } else if (powerProfileRect.currentProfile === PowerProfile.Balanced) {
                if (PowerProfiles.hasPerformanceProfile) {
                    PowerProfiles.profile = PowerProfile.Performance;
                } else {
                    PowerProfiles.profile = PowerProfile.PowerSaver;
                }
            } else if (powerProfileRect.currentProfile === PowerProfile.Performance) {
                PowerProfiles.profile = PowerProfile.PowerSaver;
            }
        }
    }

    Text {
        anchors.centerIn: parent

        text: {
            if (powerProfileHover.containsMouse) {
                switch (powerProfileRect.currentProfile) {
                case PowerProfile.Performance:
                    return "Perf";
                case PowerProfile.PowerSaver:
                    return "Save";
                case PowerProfile.Balanced:
                default:
                    return "Bal";
                }
            }
            return "";
        }

        // Only visible when hovered
        opacity: powerProfileHover.containsMouse ? 1 : 0

        font.family: Appearance.font.family.display
        font.pointSize: Appearance.font.size.body
        font.weight: Font.Medium
        color: {
            switch (powerProfileRect.currentProfile) {
            case PowerProfile.Performance:
                return Colours.m3primary;
            // return Colours.m3error;
            case PowerProfile.PowerSaver:
                return Colours.m3primary;
            case PowerProfile.Balanced:
            default:
                return Colours.m3primary;
            // return Colours.m3onSurface;
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
    }

    Widgets.MaterialIcon {
        id: powerProfileIcon
        anchors.centerIn: parent
        animate: true
        color: {
            switch (powerProfileRect.currentProfile) {
            case PowerProfile.Performance:
                return Colours.m3primary;
            // return Colours.m3error;
            case PowerProfile.PowerSaver:
                return Colours.m3primary;
            case PowerProfile.Balanced:
            default:
                return Colours.m3onSurface;
            }
        }
        font.pointSize: Appearance.font.size.iconMedium

        // Hide the icon while hovered so the profile name Text is shown instead
        opacity: powerProfileHover.containsMouse ? 0 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }

        text: {
            if (!powerProfileHover.containsMouse) {
                switch (powerProfileRect.currentProfile) {
                case PowerProfile.Performance:
                    return "bolt";
                case PowerProfile.PowerSaver:
                    return "eco";
                case PowerProfile.Balanced:
                default:
                    return "ac_unit";
                }
            }
            return "";
        }
    }
}
