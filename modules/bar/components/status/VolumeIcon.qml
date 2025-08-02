pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.Pipewire
import "../../../../widgets" as Widgets

Rectangle {
    width: 36
    height: 36
    radius: 12
    color: volumeHover.containsMouse ? Qt.alpha("#d0bcff", 0.12) : "transparent"

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

        text: parent.muted ? "volume_off" : parent.volume >= 0.66 ? "volume_up" : parent.volume >= 0.33 ? "volume_down" : "volume_mute"
        color: parent.muted ? "#f2b8b5" : "#e6e0e9"
        font.pointSize: 18
        fill: volumeHover.containsMouse ? 1 : 0
    }

    // Audio service tracking
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }
}
