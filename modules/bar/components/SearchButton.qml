import QtQuick
import QtQuick.Effects
import "../../../widgets" as Widgets
import "../../../config"
import "../../../services"

Widgets.HoverableIconButton {
    id: searchButton

    icon: "search"
    iconColor: Colours.m3primary
    iconSize: Appearance.font.size.title
    backgroundColor: Qt.alpha(Colours.m3primary, 0.08)
    hoverColor: Qt.alpha(Colours.m3primary, 0.12)
    
    width: 36
    height: 36
    radius: Appearance.rounding.large
    
    border.width: 1
    border.color: Qt.alpha(Colours.m3primary, 0.2)
    
    onClicked: {
        SearchManager.toggleSearch();
    }
}
