import QtQuick
import QtQuick.Controls

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

            color: "#4d4d4d"
            radius: 15

            Rectangle {
                anchors.fill: parent

                color: "#666666"
                radius: parent.radius
            }
        }

        handle: Rectangle {
            id: handle

            property bool moving: slider.pressed

            x: slider.leftPadding + (slider.horizontal ? slider.visualPosition * slider.availableWidth : (slider.availableWidth - width) / 2)
            y: slider.topPadding + (slider.horizontal ? (slider.availableHeight - height) / 2 : slider.visualPosition * slider.availableHeight)

            implicitWidth: slider.implicitHeight / 4.5
            implicitHeight: slider.implicitHeight

            color: "#ffffff"
            radius: width / 2

            Text {
                id: iconText

                property bool moving: handle.moving

                function update(): void {
                    text = moving ? Math.round(root.value * 100) : root.icon;
                    font.pointSize = moving ? 8 : 12;
                    font.family = moving ? "sans-serif" : "Material Icons";
                }

                anchors.centerIn: parent
                text: root.icon
                color: "#333333"
                font.pointSize: 12
                font.family: "Material Icons"

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
