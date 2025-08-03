import QtQuick
import QtQuick.Controls
import "../config"

Item {
    id: root

    required property string icon
    property real value: 0
    property real oldValue: 0
    property bool pressed: slider.pressed

    signal moved(real value)

    implicitWidth: 30
    implicitHeight: 150

    Slider {
        id: slider

        anchors.fill: parent
        orientation: Qt.Vertical
        from: 0.0
        to: 1.0
        value: root.value

        onMoved: root.moved(value)

        background: Rectangle {
            anchors.fill: parent

            color: Colours.semantic.sliderTrack
            radius: Appearance.rounding.large

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height * root.value

                color: Colours.semantic.sliderActiveTrack
                radius: parent.radius
            }
        }

        handle: Rectangle {
            id: handle

            property bool moving: slider.pressed

            x: slider.leftPadding + (slider.horizontal ? slider.visualPosition * slider.availableWidth : (slider.availableWidth - width) / 2)
            y: slider.topPadding + (slider.horizontal ? (slider.availableHeight - height) / 2 : (1 - slider.visualPosition) * (slider.availableHeight - height))

            implicitWidth: 26
            implicitHeight: 26

            color: handle.moving ? Colours.semantic.sliderHandleActive : Colours.semantic.sliderHandle
            radius: width / 2
            border.color: Colours.semantic.sliderBorder
            border.width: 1

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Text {
                id: iconText

                property bool moving: handle.moving

                function update(): void {
                    text = moving ? Math.round(root.value * 100) : root.icon;
                    font.pointSize = moving ? Appearance.font.size.tiny : Appearance.font.size.body;
                    font.family = moving ? Appearance.font.family.sans : Appearance.font.family.materialIcons;
                }

                anchors.centerIn: parent
                text: root.icon
                color: Colours.semantic.sliderBorder
                font.pointSize: Appearance.font.size.body
                font.family: Appearance.font.family.materialIcons

                Behavior on text {
                    SequentialAnimation {
                        NumberAnimation {
                            target: iconText
                            property: "scale"
                            from: 1
                            to: 0
                            duration: 100
                        }
                        ScriptAction {
                            script: iconText.update()
                        }
                        NumberAnimation {
                            target: iconText
                            property: "scale"
                            from: 0
                            to: 1
                            duration: 100
                        }
                    }
                }
            }
        }
    }

    onPressedChanged: handle.moving = pressed

    onValueChanged: {
        if (Math.abs(value - oldValue) < 0.01)
            return;
        oldValue = value;
        handle.moving = true;
        stateChangeDelay.restart();
    }

    Timer {
        id: stateChangeDelay

        interval: 500
        onTriggered: {
            if (!root.pressed)
                handle.moving = false;
        }
    }
}
