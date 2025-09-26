import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.services
import qs.utils
import qs.widgets as Widgets
import qs.config
import qs.modules.actioncenter.model

// Full-height right side action center panel with navbar tabs
PanelWindow {
    id: actionCenter
    property int panelWidth: 400
    color: "transparent"
    visible: ActionCenterManager.actionCenterVisible
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell:actioncenter"

    property string currentTab: "quick"
    property var toggles: []
    function getToggle(id) { return toggles.find(t => t.id === id); }
    function loadToggles() { toggles = ToggleModel.load(PersistentSettings.settings); syncDynamicStates(); }
    function saveToggles() { ToggleModel.persist(PersistentSettings.settings, toggles); }
    Component.onCompleted: { loadToggles(); updatePosition(); }
    function updatePosition() { if (actionCenter.screen) { actionCenter.x = actionCenter.screen.width - panelWidth; actionCenter.y = 0; actionCenter.width = panelWidth; actionCenter.height = actionCenter.screen.height; } }
    onScreenChanged: updatePosition()
    function syncDynamicStates() { const wifi=getToggle('wifi'); if (wifi) wifi.active=(NetworkManager.availableNetworks||[]).some(n=>n.isActive); const audioMute=getToggle('audioMute'); if (audioMute) audioMute.active=Audio.muted; const powerProfile=getToggle('powerProfile'); if (powerProfile && powerProfile.activeState===undefined) powerProfile.activeState=PersistentSettings.settings.actionCenterPowerProfile||'balanced'; }

    // External actions
    function openQuickSettings() { currentTab = 'quick'; ActionCenterManager.open(); }
    function openNotifications() { currentTab = 'notifications'; ActionCenterManager.open(); }

    Connections { target: ActionCenterManager; function onOpened() { actionCenter.hideNotificationPopouts(); } }

    function hideNotificationPopouts() {
        // Stub: integrate with notification popouts when available
        if (typeof NotificationService !== 'undefined' && NotificationService.closePopouts) {
            NotificationService.closePopouts();
        }
    }

    // Close when clicking outside the panel content
    MouseArea {
        anchors.fill: parent
        z: 0
        onClicked: (ev) => {
            // If click is left of container, close
            if (ev.x < contentContainer.x) {
                ActionCenterManager.close();
            }
        }
    }

    // Content container aligned right
    Rectangle {
        id: contentContainer
        width: actionCenter.panelWidth
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        color: Colours.m3surface
        radius: 0
        border.color: Qt.alpha(Colours.m3outline, 0.3)
        border.width: 1
        clip: true
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.6
            shadowHorizontalOffset: -4
            shadowVerticalOffset: 0
            shadowColor: Colours.alpha(Colours.m3shadow, 0.5)
        }

        FocusScope {
            id: focusScope
            anchors.fill: parent
            focus: actionCenter.visible
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) { ActionCenterManager.close(); event.accepted = true; return; }
                if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9 && currentTab === 'quick') {
                    const idx = event.key - Qt.Key_1;
                    if (idx < toggleRepeater.count) {
                        toggleRepeater.itemAt(idx).activate();
                        event.accepted = true;
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Navbar
                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    color: Colours.alpha(Colours.m3onSurface, 0.04)
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        function tabButton(text, tabId) {
                            return Qt.createQmlObject(`import QtQuick; import QtQuick.Layouts; import QtQuick.Controls; import "../../config"; Rectangle { \n` +
                                `property string _tab: '${tabId}'; Layout.preferredHeight: 32; Layout.preferredWidth: 120; radius: Appearance.rounding.normal; \n` +
                                `color: actionCenter.currentTab === _tab ? Colours.alpha(Colours.m3primary,0.15) : 'transparent'; border.width: 1; border.color: actionCenter.currentTab === _tab ? Colours.m3primary : Qt.alpha(Colours.m3outline,0.4); \n` +
                                `Text { anchors.centerIn: parent; text: '${text}'; color: Colours.m3onSurface; font.pointSize: Appearance.font.size.small; font.weight: Font.Medium } \n` +
                                `MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { actionCenter.currentTab = parent._tab; } } }`, navRow, 'dynamicTab');
                        }

                        Item { id: navRow; Layout.fillWidth: true; implicitHeight: 32 }
                        Component.onCompleted: {
                            tabButton('Quick Settings','quick');
                            tabButton('Notifications','notifications');
                        }

                        // Close button
                        Rectangle {
                            Layout.preferredWidth: 32; Layout.preferredHeight: 32
                            implicitWidth: 32; implicitHeight: 32
                            radius: Appearance.rounding.normal
                            color: closeArea.containsMouse ? Colours.alpha(Colours.m3error,0.12) : 'transparent'
                            border.width: 1; border.color: Qt.alpha(Colours.m3outline,0.3)
                            Widgets.MaterialIcon { anchors.centerIn: parent; text: 'close'; color: Colours.m3error; font.pointSize: Appearance.font.size.normal }
                            MouseArea { id: closeArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: ActionCenterManager.close() }
                        }
                    }
                }

                // Content stack
                Loader {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    sourceComponent: currentTab === 'quick' ? quickSettingsComponent : notificationsComponent
                }
            }
        }
    }

    // QUICK SETTINGS COMPONENT
    Component {
        id: quickSettingsComponent
        Flickable {
            id: flick
            contentWidth: width
            contentHeight: column.implicitHeight + 40
            clip: true
            interactive: contentHeight > height
            anchors.fill: parent
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            ColumnLayout {
                id: column
                width: flick.width
                spacing: 12
                padding: 12

                // Toggle grid
                GridLayout {
                    id: toggleGrid
                ColumnLayout {
                    id: column
                    width: flick.width
                    spacing: 12
                    // Replaced unsupported padding with margins via an inner Item wrapper if needed
                    // For now rely on spacing; container already has Flickable padding by content offset
                        id: toggleRepeater
                        model: toggles
                        delegate: ToggleTile {
                            width: (toggleGrid.width - (toggleGrid.columnSpacing * (toggleGrid.columns - 1))) / toggleGrid.columns
                            icon: modelData.icon
                            indexLabel: (index < 9) ? (index+1).toString() : ''
                            active: modelData.type === 'cycle' ? (modelData.activeState !== 'balanced') : modelData.active
                            cycleDisplay: modelData.type === 'cycle' ? modelData.activeState : ''
                            onActivated: {
                                handleToggle(modelData.id)
                            }
                            function activate() { onActivated(); }
                        }
                    }
                }

                // Sliders section
                SlidersSection { Layout.fillWidth: true }

                // Network section
                NetworkSection { Layout.fillWidth: true; maxVisible: 5 }

                // Media placeholder
                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    radius: Appearance.rounding.normal
                    color: Colours.alpha(Colours.m3onSurface,0.04)
                    border.width: 1
                    border.color: Qt.alpha(Colours.m3outline,0.3)
                    Text { anchors.centerIn: parent; text: 'Media Controls (placeholder)'; color: Colours.m3onSurfaceVariant; font.pointSize: Appearance.font.size.small }
                }

                // Footer row
                FooterRow { Layout.fillWidth: true }
            }
        }
    }

    // QUICK SETTINGS COMPONENT (updated version declared earlier in file)
        property alias icon: iconLabel.text
        property string indexLabel: ''
        property bool active: false
        property string cycleDisplay: ''
        signal activated()
        implicitHeight: 60
        radius: Appearance.rounding.normal
        color: active ? Colours.alpha(Colours.m3primary,0.25) : Colours.alpha(Colours.m3onSurface,0.06)
        border.width: 1
        border.color: active ? Colours.m3primary : Qt.alpha(Colours.m3outline,0.4)
        Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.OutCubic } }
        Behavior on border.color { ColorAnimation { duration: 140; easing.type: Easing.OutCubic } }

        Column {
            anchors.centerIn: parent
            spacing: 4
            Widgets.MaterialIcon { id: iconLabel; text: 'wifi'; color: active ? Colours.m3primary : Colours.m3onSurface; font.pointSize: Appearance.font.size.iconMedium }
            Text { text: cycleDisplay.length>0 ? cycleDisplay : indexLabel; color: Colours.m3onSurfaceVariant; font.pointSize: Appearance.font.size.tiny; horizontalAlignment: Text.AlignHCenter; width: parent.width }
        }
        MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: tile.activated() }
        Keys.onPressed: (e)=>{ if (e.key===Qt.Key_Return||e.key===Qt.Key_Enter||e.key===Qt.Key_Space) { tile.activated(); e.accepted=true; } }
        onActivated: activated()
    }

    // Sliders Section
    component SlidersSection: ColumnLayout {
        spacing: 8
        Rectangle { Layout.fillWidth: true; implicitHeight: 1; Layout.preferredHeight: 1; color: Qt.alpha(Colours.m3outline,0.2) }
        Text { text: 'Controls'; color: Colours.m3onSurfaceVariant; font.pointSize: Appearance.font.size.small }
        // Volume
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Widgets.MaterialIcon { text: Audio.muted ? 'volume_off' : 'volume_up'; color: Colours.m3primary; font.pointSize: Appearance.font.size.iconMedium; MouseArea { anchors.fill: parent; onClicked: { Audio.toggleMute(); const t=getToggle('audioMute'); if (t) { t.active = Audio.muted; saveToggles(); } } } }
            Slider { Layout.fillWidth: true; from: 0; to: 1; value: Audio.volume; onMoved: Audio.setVolume(value); }
        }
        // Brightness
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Widgets.MaterialIcon { text: 'brightness_medium'; color: Colours.m3primary; font.pointSize: Appearance.font.size.iconMedium }
            Slider { Layout.fillWidth: true; from: 0; to: 1; value: Brightness.monitors.length>0 ? Brightness.monitors[0].brightness : 0; onMoved: { if (Brightness.monitors.length>0) Brightness.monitors[0].setBrightness(value); } }
        }
    }

    // Network Section (view-only list)
    component NetworkSection: ColumnLayout {
        property int maxVisible: 5
        spacing: 6
        Rectangle { Layout.fillWidth: true; implicitHeight: 1; Layout.preferredHeight: 1; color: Qt.alpha(Colours.m3outline,0.2) }
        RowLayout {
            Layout.fillWidth: true
            Widgets.MaterialIcon {
                text: 'network_wifi_3_bar'
                color: Colours.m3primary
                font.pointSize: Appearance.font.size.iconMedium
            }
            Text {
                text: 'Networks'
                color: Colours.m3onSurface
                font.pointSize: Appearance.font.size.small
                font.weight: Font.Medium
                Layout.fillWidth: true
            }
            Rectangle {
                implicitWidth: 28; implicitHeight: 28
                radius: Appearance.rounding.small
                color: refreshArea.containsMouse ? Colours.alpha(Colours.m3primary,0.15) : Colours.alpha(Colours.m3onSurface,0.05)
                Widgets.MaterialIcon {
                    anchors.centerIn: parent
                    text: 'refresh'
                    color: Colours.m3primary
                    font.pointSize: Appearance.font.size.normal
                }
                MouseArea {
                    id: refreshArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NetworkManager.scanNetworks()
                }
            }
        }
        Repeater {
            model: (NetworkManager.availableNetworks || []).slice(0, maxVisible)
            delegate: Rectangle {
                width: parent.width; implicitHeight: 40; Layout.preferredHeight: 40; radius: Appearance.rounding.normal
                color: modelData.isActive ? Colours.alpha(Colours.m3primary,0.18) : Colours.alpha(Colours.m3onSurface,0.04)
                border.width: 1
                border.color: modelData.isActive ? Colours.m3primary : Qt.alpha(Colours.m3outline,0.3)
                RowLayout { anchors.fill: parent; anchors.margins: 8; spacing: 8
                    Widgets.MaterialIcon { text: signalIcon(modelData.signal); color: Colours.m3primary; font.pointSize: Appearance.font.size.iconSmall }
                    Text { text: modelData.ssid; color: Colours.m3onSurface; font.pointSize: Appearance.font.size.small; Layout.fillWidth: true; elide: Text.ElideRight }
                    Text { text: modelData.isActive ? 'Connected' : (modelData.hasSavedCredentials ? 'Saved' : ''); color: Colours.m3onSurfaceVariant; font.pointSize: Appearance.font.size.tiny }
                }
                function signalIcon(sig) {
                    if (sig>=80) return 'network_wifi';
                    if (sig>=60) return 'network_wifi_3_bar';
                    if (sig>=40) return 'network_wifi_2_bar';
                    return 'network_wifi_1_bar';
                }
            }
        }
    }

    // Footer Row
    component FooterRow: RowLayout {
        spacing: 8
        Rectangle { Layout.fillWidth: true; implicitHeight: 1; Layout.preferredHeight: 1; color: Qt.alpha(Colours.m3outline,0.2) }
        // We'll actually build separate row below separator
        Component.onCompleted: {
            // Replace placeholder with actual row
            parent.insertLayoutItem( parent.indexOf(this), footerContent )
            destroy();
        }
    }

    Component { id: footerContent
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            // Left spacer grows
            Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }
            // Settings button
            Rectangle {
                Layout.preferredWidth: 48; Layout.preferredHeight: 48
                implicitWidth: 48; implicitHeight: 48
                radius: Appearance.rounding.normal
                color: settingsArea.containsMouse ? Colours.alpha(Colours.m3primary,0.15) : Colours.alpha(Colours.m3onSurface,0.05)
                border.width: 1
                border.color: Qt.alpha(Colours.m3outline,0.3)
                Widgets.MaterialIcon { anchors.centerIn: parent; text: 'settings'; color: Colours.m3primary; font.pointSize: Appearance.font.size.iconMedium }
                MouseArea { id: settingsArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { if (typeof SettingsManager !== 'undefined' && SettingsManager.showSettingsWindow) SettingsManager.showSettingsWindow(); } }
            }
            // Power (wlogout)
            Rectangle {
                Layout.preferredWidth: 48; Layout.preferredHeight: 48
                implicitWidth: 48; implicitHeight: 48
                radius: Appearance.rounding.normal
                color: powerArea.containsMouse ? Colours.alpha(Colours.m3error,0.18) : Colours.alpha(Colours.m3onSurface,0.05)
                border.width: 1
                border.color: Qt.alpha(Colours.m3outline,0.3)
                Widgets.MaterialIcon { anchors.centerIn: parent; text: 'power_settings_new'; color: Colours.m3error; font.pointSize: Appearance.font.size.iconMedium }
                MouseArea { id: powerArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached(['wlogout']) }
            }
        }
    }

    // React to external changes for dynamic states
    Connections { target: NetworkManager; function onAvailableNetworksChanged() { syncDynamicStates(); } }
    Connections { target: Audio; function onMutedChanged() { const t=getToggle('audioMute'); if (t){ t.active = Audio.muted; saveToggles(); } } }

    // IPC Handler
    IpcHandler {
        function openQuick(): string { actionCenter.openQuickSettings(); return 'ACTIONCENTER_OPEN_QUICK_SUCCESS'; }
        function openNotifications(): string { actionCenter.openNotifications(); return 'ACTIONCENTER_OPEN_NOTIFICATIONS_SUCCESS'; }
        function toggle(): string { ActionCenterManager.toggle(); return 'ACTIONCENTER_TOGGLE_SUCCESS'; }
        function close(): string { ActionCenterManager.close(); return 'ACTIONCENTER_CLOSE_SUCCESS'; }
        function openTab(tab: string): string { actionCenter.currentTab = tab === 'notifications' ? 'notifications' : 'quick'; ActionCenterManager.open(); return 'ACTIONCENTER_OPEN_TAB_SUCCESS'; }
        target: 'actioncenter'
    }
}
