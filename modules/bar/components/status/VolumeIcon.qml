pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.Pipewire
import "../../../../widgets" as Widgets
import "../../../../config"

Rectangle {
    width: 36
    height: 36
    radius: Appearance.rounding.larger
    color: volumeHover.containsMouse ? Colours.alpha(Colours.m3primary, 0.12) : "transparent"

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volume: sink?.audio?.volume ?? 0

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    MouseArea {
        id: volumeHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (parent.sink?.ready && parent.sink?.audio) {
                parent.sink.audio.muted = !parent.muted;
            }
        }
    }

    Widgets.MaterialIcon {
        anchors.centerIn: parent
        animate: true

        // Icon glyph (hidden while hovered so percentage can show)
        text: parent.muted ? "volume_off" : parent.volume >= 0.66 ? "volume_up" : parent.volume >= 0.33 ? "volume_down" : "volume_mute"
        color: parent.muted ? Colours.m3error : Colours.m3onSurface
        font.pointSize: Appearance.font.size.iconMedium

        // Hide the icon while hovered so the percentage Text is shown instead
        opacity: volumeHover.containsMouse ? 0 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
    }

    // Show numeric volume when hovered
    Text {
        anchors.centerIn: parent

        text: volumeHover.containsMouse ? (parent.muted ? "Muted" : Math.round(parent.volume * 100).toString() + "%") : ""

        // Only visible when hovered
        opacity: volumeHover.containsMouse ? 1 : 0

        font.family: Appearance.font.family.display
        font.pointSize: Appearance.font.size.body
        font.weight: Font.Medium
        color: parent.muted ? Colours.m3error : Colours.m3onSurface

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
    }

    // Audio service tracking
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }
}
