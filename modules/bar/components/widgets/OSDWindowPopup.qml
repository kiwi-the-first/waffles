import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../../widgets"
import "../../../../services"

PopupWindow {
    id: osdWindow

    implicitWidth: 80
    implicitHeight: 320
    visible: false
    color: "transparent"

    Rectangle {
        id: content

        anchors.fill: parent
        color: "#1c1b1f"
        radius: 16
        border.color: Qt.alpha("#938f99", 0.2)
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 15

            MouseArea {
                implicitWidth: 30
                implicitHeight: 150
                hoverEnabled: true

                onEntered: OSDManager.hovered = true
                onExited: OSDManager.hovered = false

                onWheel: wheel => {
                    if (wheel.angleDelta.y > 0)
                        Audio.setVolume(Audio.volume + 0.05);
                    else if (wheel.angleDelta.y < 0)
                        Audio.setVolume(Audio.volume - 0.05);
                }

                VerticalSlider {
                    anchors.fill: parent

                    icon: {
                        if (Audio.muted)
                            return "🔇";
                        if (value >= 0.5)
                            return "🔊";
                        if (value > 0)
                            return "🔉";
                        return "🔈";
                    }
                    value: Audio.volume
                    onMoved: Audio.setVolume(value)
                }
            }

            MouseArea {
                implicitWidth: 30
                implicitHeight: 150
                hoverEnabled: true

                onEntered: OSDManager.hovered = true
                onExited: OSDManager.hovered = false

                onWheel: wheel => {
                    try {
                        if (wheel.angleDelta.y > 0)
                            Brightness.increaseBrightness();
                        else if (wheel.angleDelta.y < 0)
                            Brightness.decreaseBrightness();
                    } catch (e) {
                        console.log("Brightness control error:", e);
                    }
                }

                VerticalSlider {
                    anchors.fill: parent

                    icon: "☀"
                    value: 0.5  // Default brightness value
                    onMoved: {
                        try {
                            // Use the brightness service functions instead of direct monitor access
                            const diff = value - 0.5;
                            if (diff > 0) {
                                for (let i = 0; i < Math.abs(diff) * 10; i++) {
                                    Brightness.increaseBrightness();
                                }
                            } else if (diff < 0) {
                                for (let i = 0; i < Math.abs(diff) * 10; i++) {
                                    Brightness.decreaseBrightness();
                                }
                            }
                        } catch (e) {
                            console.log("Brightness set error:", e);
                        }
                    }
                }
            }
        }
    }
}
