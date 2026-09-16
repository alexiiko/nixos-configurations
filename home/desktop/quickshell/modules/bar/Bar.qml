import QtQuick
import Quickshell
import Quickshell.Wayland
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

    readonly property int barWidth: 48
    anchors { left: true; top: true; bottom: true }
    implicitWidth: barWidth + 380        // room for the tray pill to expand into
    exclusiveZone: 0          // overlay; windows use the full screen
    aboveWindows: true
    color: "transparent"
    // the wifi password field needs the keyboard; only then
    WlrLayershell.keyboardFocus: tray.wantsKeyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // input: the bar surface plus the (possibly expanded) tray pill; never
    // the empty area to the right of the bar
    mask: Region {
        item: root.revealed ? surface : trigger
        regions: [ Region { item: trayMask }, Region { item: calMask }, Region { item: powerMask } ]
    }
    // Region.item takes the item's coordinates relative to its parent, and
    // the tray is nested two levels down. This window-level item shadows the
    // pill's real position so the expanded part is clickable.
    // Plain property sums, not mapToItem: those are reactive, mapToItem is
    // not (it evaluated once at y=0 before layout and never moved).
    Item {
        id: trayMask
        visible: false
        x: surface.x + bottomCol.x + tray.x
        y: surface.y + bottomCol.y + tray.y
        width: tray.inputWidth
        height: tray.height
    }

    Item {
        id: calMask
        visible: false
        x: surface.x + bottomCol.x + calBtn.x + calBtn.inputX
        y: surface.y + bottomCol.y + calBtn.y + calBtn.inputY
        width: calBtn.inputWidth
        height: calBtn.inputHeight
    }

    Item {
        id: powerMask
        visible: false
        x: surface.x + bottomCol.x + power.x + power.inputX
        y: surface.y + bottomCol.y + power.y + power.inputY
        width: power.inputWidth
        height: power.inputHeight
    }

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
    readonly property bool wantVisible: triggerHover.hovered || surfaceHover.hovered || power.open || calBtn.open || tray.anyOpen
    onWantVisibleChanged: {
        if (wantVisible) { hideTimer.stop(); revealed = true; }
        else hideTimer.restart();
    }
    Timer { id: hideTimer; interval: root.hideDelay; onTriggered: root.revealed = false }

    Rectangle {
        id: surface
        width: root.barWidth
        height: root.height
        x: root.revealed ? 0 : -root.barWidth
        Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        color: Theme.c.linen
        topRightRadius: 14
        bottomRightRadius: 14

        HoverHandler { id: surfaceHover }

        // Click on the bare bar (not a button): close whatever popover is open.
        // Declared before the content so the buttons sit above it.
        MouseArea {
            anchors.fill: parent
            onClicked: { power.open = false; calBtn.open = false; tray.closeAll(); }
        }

        Column {
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
            anchors.topMargin: 10
            spacing: 8

            NixButton  { anchors.horizontalCenter: parent.horizontalCenter }
        }

        // fixed to the bar width, not centred: the tray pill grows past the
        // bar when a menu opens and must not drag the column with it
        Column {
            id: bottomCol
            anchors { bottom: parent.bottom; left: parent.left }
            anchors.bottomMargin: 12
            width: root.barWidth
            spacing: 12

            Clock    { anchors.horizontalCenter: parent.horizontalCenter }
            WhatsApp { anchors.horizontalCenter: parent.horizontalCenter }
            CalendarButton { id: calBtn; anchors.horizontalCenter: parent.horizontalCenter; barWindow: root }
            Tray     { id: tray; x: 6; barWindow: root }
            PowerMenu { id: power; anchors.horizontalCenter: parent.horizontalCenter; barWindow: root }
        }
    }
}
