import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../theme"

// Popover beside a bar button. A layer surface, not an xdg popup: under
// Hyprland a popup never receives keyboard input, a layer surface with
// exclusive focus does (needed for the Wi-Fi password field). Positioned
// by geometry: right of the bar, bottom edge level with the button.
// Closes on click-outside / Escape.
PanelWindow {
    id: root
    required property var barWindow
    required property Item item
    property bool open: false
    property bool keyboard: false          // grab the keyboard (text fields)
    default property alias content: inner.data
    property int padding: 12

    // Position is computed when opening (and if the size changes while
    // open): mapToItem is not a reactive binding, so a plain binding would
    // freeze at the pre-layout value of 0 and pin the popover top-left.
    property real topMargin: 8
    function place() {
        const itemBottom = item.mapToItem(null, 0, item.height).y;
        const maxTop = (screen?.height ?? 900) - implicitHeight - 8;
        topMargin = Math.max(8, Math.min(itemBottom - implicitHeight, maxTop));
    }
    onOpenChanged: if (open) place()
    onImplicitHeightChanged: if (open) place()

    anchors { left: true; top: true }
    margins { left: barWindow.width + 10; top: topMargin }
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open && keyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    visible: open
    color: "transparent"

    // Click-outside closes. Not while the keyboard is grabbed: switching a
    // layer to exclusive keyboard focus reads as "focus lost" to the grab and
    // would close the popover the moment a text field opens. While typing,
    // Escape / the bar click / the field's own submit close it instead.
    HyprlandFocusGrab {
        windows: [root, root.barWindow]
        active: root.open && !root.keyboard
        onCleared: root.open = false
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: Theme.c.linen
        border.width: 1
        border.color: Theme.c.mist
        Item { id: inner; anchors.fill: parent; anchors.margins: root.padding }
    }
    Item { anchors.fill: parent; focus: root.open; Keys.onEscapePressed: root.open = false }
}
