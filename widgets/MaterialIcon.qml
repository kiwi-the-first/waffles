pragma ComponentBehavior: Bound

import QtQuick
import qs.config

Text {
    id: root
    property real fill: 0
    property int grade: -25
    property bool animate: false

    renderType: Text.NativeRendering
    textFormat: Text.PlainText
    color: Colours.semantic.textPrimary
    font.family: Appearance.font.family.material
    font.pointSize: Appearance.font.size.iconLarge
    font.variableAxes: ({
            FILL: fill.toFixed(1),
            GRAD: grade,
            opsz: 20,
            wght: 400
        })

    Behavior on color {
        ColorAnimation {
            duration: 400
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
        }
    }

    Behavior on fill {
        enabled: root.animate
        NumberAnimation {
            duration: 400
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
        }
    }
}
