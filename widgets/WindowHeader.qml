pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../config"

// Reusable window header component
// Provides consistent header styling with icon, title, and actions
RowLayout {
    id: root

    property string headerIcon: ""
    property string headerTitle: ""
    property bool showCloseButton: true
    property alias actionsContent: actionsLoader.sourceComponent
    
    signal closeClicked

    spacing: Appearance.spacing.normal

    MaterialIcon {
        visible: root.headerIcon.length > 0
        text: root.headerIcon
        color: Colours.m3primary
        font.pointSize: Appearance.font.size.larger
    }

    StyledText {
        text: root.headerTitle
        font.pointSize: Appearance.font.size.medium
        font.weight: Font.Medium
        color: Colours.m3onSurface
        Layout.fillWidth: true
    }

    // Custom actions area
    Loader {
        id: actionsLoader
        Layout.preferredHeight: 32
    }

    CloseButton {
        visible: root.showCloseButton
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        onClicked: root.closeClicked()
    }
}
