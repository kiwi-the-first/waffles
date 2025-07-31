pragma ComponentBehavior: Bound

import QtQuick

MouseArea {
    id: root

    property color color: "#d0bcff"
    property real radius: 17
    property bool disabled: false

    signal clicked

    hoverEnabled: !disabled
    cursorShape: disabled ? Qt.ArrowCursor : Qt.PointingHandCursor

    onClicked: function () {
        if (!disabled) {
            root.clicked();
            rippleEffect.createRipple(mouseX, mouseY);
        }
    }

    Rectangle {
        id: stateLayer
        anchors.fill: parent
        color: Qt.alpha(root.color, root.disabled ? 0 : root.pressed ? 0.1 : root.containsMouse ? 0.08 : 0)
        radius: root.radius

        Behavior on color {
            ColorAnimation {
                duration: 400
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
            }
        }

        Rectangle {
            id: ripple
            radius: width / 2
            color: Qt.alpha(root.color, 0.2)
            opacity: 0

            transform: Translate {
                x: -ripple.width / 2
                y: -ripple.height / 2
            }
        }
    }

    Item {
        id: rippleEffect
        anchors.fill: parent

        function createRipple(x, y) {
            if (root.disabled)
                return;

            ripple.x = x;
            ripple.y = y;
            ripple.width = 0;
            ripple.height = 0;
            ripple.opacity = 1;

            rippleAnimation.restart();
        }

        SequentialAnimation {
            id: rippleAnimation

            ParallelAnimation {
                NumberAnimation {
                    target: ripple
                    property: "width"
                    to: Math.max(root.width, root.height) * 2
                    duration: 400
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: ripple
                    property: "height"
                    to: Math.max(root.width, root.height) * 2
                    duration: 400
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: ripple
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 400
                    easing.type: Easing.OutQuad
                }
            }
        }
    }
}
