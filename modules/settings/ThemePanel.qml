import QtQuick
import "../../config"

Rectangle {
    id: themePanel
    width: parent.width
    height: 80
    radius: Appearance.rounding.larger
    color: Colours.alpha(Colours.m3outline, 0.05)
    border.width: 1
    border.color: Colours.alpha(Colours.m3outline, 0.1)

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "Theme"
            font.family: Appearance.font.family.display
            font.pointSize: Appearance.font.size.body
            font.weight: Font.Medium
            color: Colours.m3onSurface
        }

        Row {
            spacing: 8

            // Light Theme Button
            Rectangle {
                width: 80
                height: 32
                radius: Appearance.rounding.normal
                color: Colours.currentTheme === "light" ? Colours.m3primary : Colours.alpha(Colours.m3outline, 0.1)
                border.width: 1
                border.color: Colours.currentTheme === "light" ? Colours.m3primary : Colours.alpha(Colours.m3outline, 0.2)

                Text {
                    anchors.centerIn: parent
                    text: "Light"
                    font.family: Appearance.font.family.display
                    font.pointSize: Appearance.font.size.smaller
                    color: Colours.currentTheme === "light" ? Colours.m3onPrimary : Colours.m3onSurface
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Colours.currentTheme = "light";
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            // Dark Theme Button
            Rectangle {
                width: 80
                height: 32
                radius: Appearance.rounding.normal
                color: Colours.currentTheme === "dark" ? Colours.m3primary : Colours.alpha(Colours.m3outline, 0.1)
                border.width: 1
                border.color: Colours.currentTheme === "dark" ? Colours.m3primary : Colours.alpha(Colours.m3outline, 0.2)

                Text {
                    anchors.centerIn: parent
                    text: "Dark"
                    font.family: Appearance.font.family.display
                    font.pointSize: Appearance.font.size.smaller
                    color: Colours.currentTheme === "dark" ? Colours.m3onPrimary : Colours.m3onSurface
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Colours.currentTheme = "dark";
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            // Dynamic Theme Button
            Rectangle {
                width: 80
                height: 32
                radius: Appearance.rounding.normal
                color: Colours.currentTheme === "dynamic" ? Colours.m3primary : Colours.alpha(Colours.m3outline, 0.1)
                border.width: 1
                border.color: Colours.currentTheme === "dynamic" ? Colours.m3primary : Colours.alpha(Colours.m3outline, 0.2)

                Text {
                    anchors.centerIn: parent
                    text: "Auto"
                    font.family: Appearance.font.family.display
                    font.pointSize: Appearance.font.size.smaller
                    color: Colours.currentTheme === "dynamic" ? Colours.m3onPrimary : Colours.m3onSurface
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Colours.currentTheme = "dynamic";
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }
        }
    }
}
