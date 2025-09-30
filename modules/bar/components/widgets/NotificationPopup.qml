pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../widgets" as Widgets
import "../../../../config"
import "../../../../utils" as Utils

Item {
    id: toast

    required property var notificationData    // NotifWrapper

    signal dismissRequested

    readonly property bool hasActions: toast.notificationData && toast.notificationData.notification && toast.notificationData.notification.actions && toast.notificationData.notification.actions.length > 0

    // Animation properties (matching Noctalia's pattern)
    property real scaleValue: 0.8
    property real opacityValue: 0.0
    property bool isRemoving: false

    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight

    width: implicitWidth
    height: implicitHeight

    // Apply animation values to the whole item
    scale: scaleValue
    opacity: opacityValue

    // Function to get app-specific icon path (using existing Icons utility)
    function getAppIconPath(appName) {
        if (!appName)
            return "";

        // Use the existing Icons utility to get app icon
        const iconPath = Utils.Icons.getAppIcon(appName);
        return iconPath || "";
    }

    Rectangle {
        id: card
        width: 360
        implicitHeight: layout.implicitHeight + (Appearance.spacing.larger * 2) // Using Noctalia-style spacing
        radius: Appearance.rounding.large  // Using Noctalia radius system
        color: Colours.m3surface
        border.color: Colours.m3outline
        border.width: Math.max(1, 1)  // Consistent with Noctalia border approach

        // Progress bar indicator (matching Noctalia style)
        Rectangle {
            id: progressBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            color: "transparent"
            radius: parent.radius

            property real availableWidth: parent.width - (2 * parent.radius)

            Rectangle {
                x: card.radius + (parent.availableWidth * (1 - (toast.notificationData?.progress || 1.0))) / 2
                width: parent.availableWidth * (toast.notificationData?.progress || 1.0)
                height: parent.height
                color: {
                    if (toast.notificationData?.urgency === 2) // Critical
                        return Colours.m3error;
                    else if (toast.notificationData?.urgency === 0) // Low
                        return Colours.m3onSurface;
                    else
                        return Colours.m3primary; // Normal
                }
                radius: parent.radius
            }
        }

        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: Appearance.spacing.larger  // Using Noctalia spacing
            anchors.rightMargin: (Appearance.spacing.larger + 32)  // Space for close button
            spacing: Appearance.spacing.normal

            // Main content section matching Noctalia's layout
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.larger

                // App icon section (Noctalia style with app-specific icons)
                ColumnLayout {
                    // App-specific icon only (no fallback)
                    Item {
                        id: iconContainer
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignTop
                        Layout.topMargin: 30

                        property string iconPath: {
                            const appName = toast.notificationData?.appName || "";
                            if (appName) {
                                const path = toast.getAppIconPath(appName);
                                return path || "";
                            }
                            return "";
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            radius: width * 0.5
                            clip: true

                            // Only show app-specific icon when available
                            Image {
                                id: appIconImage
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                                asynchronous: true
                                source: iconContainer.iconPath
                                visible: iconContainer.iconPath !== "" && status === Image.Ready
                            }
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                    }
                }

                // Text content
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    // Header section with app name and timestamp (Noctalia style)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.spacing.small

                        Rectangle {
                            Layout.preferredWidth: 6
                            Layout.preferredHeight: 6
                            radius: 3
                            color: {
                                if (toast.notificationData?.urgency === 2) // Critical
                                    return Colours.m3error;
                                else if (toast.notificationData?.urgency === 0) // Low
                                    return Colours.m3onSurface;
                                else
                                    return Colours.m3primary;
                            }
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            text: `${toast.notificationData?.appName || "System"} · ${Qt.formatTime(new Date(), "HH:mm")}`
                            color: Colours.m3secondary
                            font.pointSize: Appearance.font.size.smaller
                            font.family: Appearance.font.family.sans
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    Text {
                        text: toast.notificationData?.summary || ""
                        font.family: Appearance.font.family.display
                        font.pointSize: Appearance.font.size.large
                        font.weight: Font.Medium
                        color: Colours.m3onSurface
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        maximumLineCount: 3
                        visible: text.length > 0
                    }

                    Text {
                        text: toast.notificationData?.body || ""
                        font.family: Appearance.font.family.sans
                        font.pointSize: Appearance.font.size.normal
                        color: Colours.m3onSurface
                        textFormat: Text.PlainText
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        Layout.fillWidth: true
                        maximumLineCount: 5
                        elide: Text.ElideRight
                        visible: text.length > 0
                    }

                    // Notification actions (matching Noctalia style)
                    Flow {
                        Layout.fillWidth: true
                        spacing: Appearance.spacing.small
                        Layout.topMargin: Appearance.spacing.normal
                        visible: toast.hasActions

                        flow: Flow.LeftToRight
                        layoutDirection: Qt.LeftToRight

                        Repeater {
                            model: toast.hasActions ? toast.notificationData.notification.actions : []
                            delegate: Rectangle {
                                required property var modelData
                                property string buttonText: modelData.text || "Action"

                                width: buttonTextItem.implicitWidth + 16
                                height: 24
                                color: Colours.m3primary
                                radius: Appearance.rounding.normal

                                Text {
                                    id: buttonTextItem
                                    anchors.centerIn: parent
                                    text: parent.buttonText
                                    color: Colours.m3onPrimary
                                    font.pointSize: Appearance.font.size.small
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (parent.modelData.invoke)
                                            parent.modelData.invoke();
                                        toast.startDismiss();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Close button (positioned absolutely like Noctalia)
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: Appearance.spacing.normal
            anchors.rightMargin: Appearance.spacing.normal
            width: 24
            height: 24
            radius: 12
            color: closeButtonArea.containsMouse ? Qt.alpha(Colours.m3onSurface, 0.1) : "transparent"

            Widgets.MaterialIcon {
                anchors.centerIn: parent
                text: "close"
                font.pointSize: 16
                color: Colours.m3onSurfaceVariant
            }

            MouseArea {
                id: closeButtonArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: toast.startDismiss()
            }
        }

        // Right-click to dismiss (matching Noctalia)
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: function (mouse) {
                if (mouse.button === Qt.RightButton) {
                    toast.startDismiss();
                }
            }
        }
    }

    // Animate in when the item is created (Noctalia style)
    Component.onCompleted: {
        scaleValue = 1.0;
        opacityValue = 1.0;
    }

    // Animation behaviors (matching Noctalia's smooth animations)
    Behavior on scale {
        NumberAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.OutExpo  // Noctalia uses OutExpo for scale
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.anim.durations.small
            easing.type: Easing.OutQuad  // Noctalia uses OutQuad for opacity
        }
    }

    // Animate out function (matching Noctalia pattern)
    function animateOut() {
        isRemoving = true;
        scaleValue = 0.8;
        opacityValue = 0.0;
    }

    function startDismiss() {
        if (removalTimer.running)
            return;
        animateOut();
        removalTimer.start();
    }

    // Timer for delayed removal after animation (matching Noctalia)
    Timer {
        id: removalTimer
        interval: Appearance.anim.durations.normal
        repeat: false
        onTriggered: toast.dismissRequested()
    }
}
