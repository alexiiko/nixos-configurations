import QtQuick
import Quickshell
import "../../theme"
import "../power"
import "../tray"

// The sidebar. Auto-hides: slides off the left edge and only a thin strip
// stays hot. Moving the mouse to the edge reveals it; leaving hides it.
// While hidden the input mask shrinks to the strip, so clicks in the space
// it would occupy go to the window underneath, not to us.
PanelWindow {
    id: root

    property bool revealed: false
    readonly property int hideDelay: 150
    readonly property int triggerWidth: 6

    anchors { left: true; top: true; bottom: true }
    implicitWidth: 48
    exclusiveZone: 0          // overlay; windows use the full screen
    aboveWindows: true
    color: "transparent"

    mask: Region { item: root.revealed ? surface : trigger }

    // hot strip on the very edge; invisible
    Item {
        id: trigger; x: 0; y: 0; width: root.triggerWidth; height: parent.height
        HoverHandler { id: triggerHover }
    }

    // Hover is tracked by HoverHandlers on the trigger strip and on the
    // surface itself. They must be ancestors of the buttons: a MouseArea on
    // top blocks hover from reaching items *beneath* it, but not handlers
    // on its ancestors. Bar stays while the power popover is open, since
    // the mouse leaves us to use it.
    readonly property bool wantVisible: triggerHover.hovered || surfaceHover.hovered || power.open
    onWantVisibleChanged: {
        if (wantVisible) { hideTimer.stop(); revealed = true; }
        else hideTimer.restart();
    }
    Timer { id: hideTimer; interval: root.hideDelay; onTriggered: root.revealed = false }

    Rectangle {
        id: surface
        width: root.width
        height: root.height
        x: root.revealed ? 0 : -width
        Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        color: Theme.c.linen
        border.width: 1
        border.color: Theme.c.mist
        topRightRadius: 14
        bottomRightRadius: 14

        HoverHandler { id: surfaceHover }

        Column {
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
            anchors.topMargin: 10
            spacing: 8

            NixButton  { anchors.horizontalCenter: parent.horizontalCenter }
            Workspaces { anchors.horizontalCenter: parent.horizontalCenter }
        }

        Column {
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            anchors.bottomMargin: 12
            spacing: 12

            Clock    { anchors.horizontalCenter: parent.horizontalCenter }
            WhatsApp { anchors.horizontalCenter: parent.horizontalCenter }
            Tray     { anchors.horizontalCenter: parent.horizontalCenter }
            PowerMenu { id: power; anchors.horizontalCenter: parent.horizontalCenter; barWindow: root }
        }
    }
}
