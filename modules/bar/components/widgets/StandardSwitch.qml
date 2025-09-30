import QtQuick
import QtQuick.Controls
import "../../../../config"

Switch {
    id: root

    property color activeColor: Colours.m3primary
    property color inactiveColor: Colours.m3outline
    property color thumbColor: Colours.m3onPrimary
    property color trackColor: Colours.m3surface

    indicator: Rectangle {
        id: track
        implicitWidth: 52
        implicitHeight: 32
        x: root.leftPadding
        y: parent.height / 2 - height / 2
        radius: height / 2
        color: root.checked ? root.activeColor : root.inactiveColor

        // Smooth color transitions
        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }

        Rectangle {
            id: thumb
            x: root.checked ? parent.width - width - 4 : 4
            y: (parent.height - height) / 2
            width: 24
            height: 24
            radius: width / 2
            color: root.thumbColor

            // Smooth position transitions
            Behavior on x {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }
    }

    contentItem: null
}
