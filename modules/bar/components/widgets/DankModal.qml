pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

// Minimal DankModal inspired wrapper (PanelWindow-based) so other UI can use DankModal type
PanelWindow {
    id: root

    property alias content: contentLoader.sourceComponent
    property alias contentLoader: contentLoader
    property real width: 480
    property real height: 320
    property bool showBackground: true
    property real backgroundOpacity: 0.5
    property string positioning: "center"
    property point customPosition: Qt.point(0, 0)
    property bool closeOnEscapeKey: true
    property bool closeOnBackgroundClick: true
    property string animationType: "scale"
    property int animationDuration: 200
    property var animationEasing: Easing.InOutQuad
    property color backgroundColor: "#ffffff"
    property color borderColor: "#000000"
    property real borderWidth: 1
    property real cornerRadius: 8
    property bool enableShadow: true
    property bool shouldBeVisible: false
    property bool shouldHaveFocus: shouldBeVisible
    property bool allowStacking: false

    signal opened
    signal dialogClosed
    signal backgroundClicked

    function open() {
        shouldBeVisible = true;
        visible = true;
        Qt.callLater(function () {
            if (focusScope)
                focusScope.forceActiveFocus();
        });
        opened();
    }

    function close() {
        shouldBeVisible = false;
        visible = false;
        dialogClosed();
    }

    function toggle() {
        if (shouldBeVisible)
            close();
        else
            open();
    }

    visible: shouldBeVisible
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "waffles-modal"

    anchors.fill: parent

    Rectangle {
        id: background
        anchors.fill: parent
        color: "black"
        opacity: root.showBackground ? (root.shouldBeVisible ? root.backgroundOpacity : 0) : 0
        visible: root.showBackground

        MouseArea {
            anchors.fill: parent
            enabled: root.closeOnBackgroundClick
            onClicked: {
                root.backgroundClicked();
                if (root.closeOnBackgroundClick)
                    root.close();
            }
        }
    }

    Rectangle {
        id: contentContainer
        width: root.width
        height: root.height
        anchors.centerIn: positioning === "center" ? parent : undefined
        x: positioning === "custom" ? customPosition.x : x
        y: positioning === "custom" ? customPosition.y : y
        color: root.backgroundColor
        radius: root.cornerRadius
        border.color: root.borderColor
        border.width: root.borderWidth
        layer.enabled: root.enableShadow
        opacity: root.shouldBeVisible ? 1 : 0
        scale: root.animationType === "scale" ? (root.shouldBeVisible ? 1 : 0.9) : 1

        Loader {
            id: contentLoader
            anchors.fill: parent
            active: root.visible
            asynchronous: false
        }
    }

    FocusScope {
        id: focusScope
        anchors.fill: parent
        visible: root.visible
        focus: root.visible
        Keys.onEscapePressed: event => {
            if (root.closeOnEscapeKey && root.shouldHaveFocus) {
                root.close();
                event.accepted = true;
            }
        }
        onVisibleChanged: {
            if (visible && root.shouldHaveFocus) {
                Qt.callLater(() => focusScope.forceActiveFocus());
            }
        }
    }
}
