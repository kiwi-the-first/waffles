pragma Singleton

import QtQuick

// Reusable animation behavior components
// Reduces duplication of common animation patterns
QtObject {
    id: root

    // Standard color animation for state changes
    readonly property Component smoothColorTransition: Component {
        Behavior {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }

    // Fast color animation
    readonly property Component fastColorTransition: Component {
        Behavior {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }

    // Standard number animation
    readonly property Component smoothNumberTransition: Component {
        Behavior {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }

    // Smooth scale animation
    readonly property Component scaleTransition: Component {
        Behavior {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }
    }

    // Opacity fade
    readonly property Component opacityFade: Component {
        Behavior {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }

    // Material Design emphasized easing
    readonly property Component emphasizedTransition: Component {
        Behavior {
            ColorAnimation {
                duration: 400
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
            }
        }
    }
}
