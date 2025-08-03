pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Hyprland
import "../../../../services"
import "../../../../utils"
import "../../../../config"
import "../../../common"

PopupWindow {
    id: workspaceWindow

    implicitWidth: 344
    implicitHeight: 380
    visible: false
    color: "transparent"

    // HoverHandler to detect hover over the entire window content
    HoverHandler {
        id: workspaceHover

        onHoveredChanged: {
            if (InteractionSettings.hoverMode) {
                WorkspaceManager.workspaceWindowHovered = hovered;
                if (hovered) {
                    WorkspaceManager.stopHideTimer();
                } else {
                    WorkspaceManager.startHideTimer();
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colours.semantic.backgroundMain
        radius: Appearance.rounding.larger
        border.color: Colours.alpha(Colours.m3outline, 0.2)
        border.width: 1

        // Subtle shadow effect
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.8
            shadowHorizontalOffset: 4
            shadowVerticalOffset: 4
            shadowColor: Colours.alpha(Colours.m3shadow, 0.4)
        }
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.margins: 16
        contentWidth: availableWidth
        clip: true

        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Column {
            width: parent.width
            spacing: 16

            // Header
            Text {
                text: "Workspaces"
                font.family: Appearance.font.family.display
                font.pointSize: Appearance.font.size.large
                font.weight: Font.Bold
                color: Colours.semantic.accent
                width: parent.width
            }

            // Separator
            Rectangle {
                width: parent.width
                height: 1
                color: Colours.alpha(Colours.m3outline, 0.2)
            }

            // Display all available workspaces
            Flow {
                width: parent.width
                spacing: 12

                Repeater {
                    model: Object.keys(WorkspaceManager.workspaceData).filter(workspaceId => {
                        // Only show workspaces that have clients
                        const workspace = WorkspaceManager.workspaceData[workspaceId];
                        return workspace && workspace.clients && workspace.clients.length > 0;
                    }).sort((a, b) => {
                        // Sort regular workspaces (positive numbers) first, then special workspaces
                        const aNum = parseInt(a);
                        const bNum = parseInt(b);
                        if (aNum > 0 && bNum > 0)
                            return aNum - bNum; // Both positive: normal sort
                        if (aNum > 0 && bNum <= 0)
                            return -1; // a positive, b special: a first
                        if (aNum <= 0 && bNum > 0)
                            return 1;  // a special, b positive: b first
                        return aNum - bNum; // Both special: normal sort
                    })

                    delegate: Rectangle {
                        id: workspaceRect
                        width: 96  // Fixed width for consistent layout
                        height: 80
                        radius: Appearance.rounding.normal
                        color: mouseArea.containsMouse ? Colours.alpha(Colours.m3outline, 0.12) : Colours.alpha(Colours.m3outline, 0.08)
                        border.width: 1
                        border.color: Colours.alpha(Colours.m3outline, 0.15)

                        required property string modelData  // The workspace ID as string
                        property var workspaceData: WorkspaceManager.workspaceData[modelData] || {
                            id: modelData,
                            name: `Workspace ${modelData}`,
                            clients: []
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Item {
                            anchors.fill: parent
                            anchors.margins: 8

                            Column {
                                anchors.centerIn: parent
                                width: parent.width - 16  // Account for the 8px margins on each side
                                spacing: 4

                                // Workspace name (shown on hover)
                                Text {
                                    id: workspaceName
                                    text: {
                                        const workspaceName = workspaceRect.workspaceData.name || `Workspace ${workspaceRect.workspaceData.id}`;

                                        // For special workspaces, remove "special:" prefix
                                        if (workspaceName.startsWith("special:")) {
                                            return workspaceName.substring(8); // Remove "special:"
                                        }

                                        // For regular workspaces, show just the number
                                        if (workspaceName.startsWith("Workspace ")) {
                                            return workspaceRect.workspaceData.id.toString();
                                        }

                                        // For any other format, return as-is
                                        return workspaceName;
                                    }
                                    font.family: Appearance.font.family.display
                                    font.pointSize: Appearance.font.size.smaller
                                    font.weight: Font.Medium
                                    color: Colours.semantic.accent
                                    visible: mouseArea.containsMouse
                                    wrapMode: Text.WordWrap
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter

                                    Behavior on visible {
                                        NumberAnimation {
                                            duration: 150
                                            easing.type: Easing.OutQuad
                                        }
                                    }
                                }

                                // App icons grid (hidden on hover)
                                Flow {
                                    id: appIconsFlow
                                    width: parent.width
                                    spacing: 15
                                    visible: !mouseArea.containsMouse

                                    Behavior on visible {
                                        NumberAnimation {
                                            duration: 150
                                            easing.type: Easing.OutQuad
                                        }
                                    }

                                    Repeater {
                                        model: workspaceRect.workspaceData.clients || []

                                        delegate: Rectangle {
                                            id: appIcon
                                            width: 24  // Increased from 16
                                            height: 24 // Increased from 16
                                            radius: Appearance.rounding.small
                                            color: Colours.alpha(Colours.m3primary, 0.2)
                                            border.width: 1
                                            border.color: Colours.alpha(Colours.m3primary, 0.3)

                                            required property var modelData

                                            // Try to load app icon
                                            Image {
                                                anchors.centerIn: parent
                                                width: 30  // Increased from 12
                                                height: 30 // Increased from 12
                                                source: Icons.getAppIcon(appIcon.modelData.class || "")
                                                fillMode: Image.PreserveAspectFit
                                                visible: status === Image.Ready

                                                onStatusChanged: {
                                                    if (status === Image.Error) {
                                                        fallbackIcon.visible = true;
                                                    }
                                                }
                                            }

                                            // Fallback text icon
                                            Text {
                                                id: fallbackIcon
                                                anchors.centerIn: parent
                                                text: (appIcon.modelData.class || "?")[0].toUpperCase()
                                                font.family: Appearance.font.family.display
                                                font.pointSize: Appearance.font.size.smaller  // Increased from 7
                                                font.weight: Font.Bold
                                                color: Colours.semantic.accent
                                                visible: false
                                            }

                                            // Tooltip
                                            MouseArea {
                                                id: iconMouseArea
                                                anchors.fill: parent
                                                hoverEnabled: true

                                                ToolTip {
                                                    visible: iconMouseArea.containsMouse
                                                    text: (appIcon.modelData.title || "Untitled") + (appIcon.modelData.class ? " (" + appIcon.modelData.class + ")" : "")
                                                    delay: 500
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }  // Close Item wrapper

                        // Click to switch workspace
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                if (!InteractionSettings.hoverMode) {
                                    switchToWorkspace();
                                }
                            }

                            onEntered: {
                                if (InteractionSettings.hoverMode) {
                                    // In hover mode, switch workspace on hover after a delay
                                    hoverTimer.start();
                                }
                            }

                            onExited: {
                                if (InteractionSettings.hoverMode) {
                                    hoverTimer.stop();
                                }
                            }

                            function switchToWorkspace() {
                                // Switch to the clicked workspace using appropriate Hyprland dispatcher
                                const workspaceId = workspaceRect.workspaceData.id;
                                const workspaceName = workspaceRect.workspaceData.name || `Workspace ${workspaceId}`;

                                DebugUtils.log("Switching to workspace:", workspaceId, "name:", workspaceName);

                                // Check if this is a special workspace
                                if (workspaceName.startsWith("special:")) {
                                    // For special workspaces, use togglespecialworkspace
                                    Hyprland.dispatch(`togglespecialworkspace ${workspaceName}`);
                                } else {
                                    // For regular workspaces, use workspace
                                    Hyprland.dispatch(`workspace ${workspaceId}`);
                                }

                                // Hide the workspace window after switching
                                WorkspaceManager.hideWorkspaceWindow();
                            }

                            // Timer to delay workspace switch in hover mode
                            Timer {
                                id: hoverTimer
                                interval: 600  // Slightly longer delay for workspace switching
                                repeat: false
                                onTriggered: {
                                    if (mouseArea.containsMouse && InteractionSettings.hoverMode) {
                                        mouseArea.switchToWorkspace();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Empty state
            Item {
                width: parent.width
                height: 60
                visible: Object.keys(WorkspaceManager.workspaceData).length === 0

                Text {
                    anchors.centerIn: parent
                    text: "No active workspaces"
                    font.family: Appearance.font.family.display
                    font.pointSize: Appearance.font.size.smaller
                    color: Colours.semantic.borderStrong
                }
            }
        }
    }
}
