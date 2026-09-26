import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../widgets"

// Workspace pills in their own auto-hide panel: bottom edge, just right of
// the sidebar. Same reveal logic as the sidebar, sliding up.
PanelWindow {
    id: root

    property bool revealed: false
    readonly property int hideDelay: 150
    readonly property int triggerHeight: 6
    readonly property int pad: 8

    anchors { bottom: true; left: true }
    margins.left: 60                          // sidebar width + gap
    implicitWidth: pills.implicitWidth + 2 * pad
    implicitHeight: 28 + 2 * pad
    exclusiveZone: 0
    aboveWindows: true
    WlrLayershell.layer: WlrLayer.Overlay   // above fullscreen windows too
    color: "transparent"

    mask: Region { item: root.revealed ? surface : trigger }

    Item {
        id: trigger; x: 0; y: parent.height - root.triggerHeight; width: parent.width; height: root.triggerHeight
        HoverHandler { id: triggerHover }
    }

    readonly property bool wantVisible: triggerHover.hovered || surfaceHover.hovered
    onWantVisibleChanged: {
        if (wantVisible) { hideTimer.stop(); revealed = true; }
        else hideTimer.restart();
    }
    Timer { id: hideTimer; interval: root.hideDelay; onTriggered: root.revealed = false }

    Rectangle {
        id: surface
        width: root.width
        height: root.height
        y: root.revealed ? 0 : height
        Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        color: Theme.c.linen
        topLeftRadius: 14
        topRightRadius: 14

        HoverHandler { id: surfaceHover }
        Workspaces { id: pills; anchors.centerIn: parent }
    }
}
