pragma ComponentBehavior: Bound

import QtQuick
import "../config"

// Reusable card/container component
// Provides consistent styling for panels, cards, and containers
Rectangle {
    id: root

    property real borderOpacity: 0.1
    property real backgroundOpacity: 1.0
    property bool elevated: false
    property alias cardContent: contentLoader.sourceComponent
    property int cardPadding: Appearance.padding.normal
    
    radius: Appearance.rounding.large
    color: elevated ? Colours.m3surfaceContainer : Colours.m3surface
    border.color: Colours.alpha(Colours.m3outline, borderOpacity)
    border.width: 1

    Loader {
        id: contentLoader
        anchors.fill: parent
        anchors.margins: root.cardPadding
    }
}
