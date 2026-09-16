import QtQuick
import Quickshell.Hyprland
import "../../theme"

// Status pill: AirPods, audio, bluetooth, wifi, battery.
// A menu opens by growing the pill to the right — same height, wider —
// with the menu's content revealed in the new space. One menu at a time.
//
// The outer item is always full width and only the inner pill animates.
// Qt 6.11 caches, per item, whether all its event-handling children fit
// inside it (computed on the first pointer event, invalidated only when a
// child *moves*, not when it grows). If this item grew while the cursor
// was over the bar, the 48px-wide bar surface kept "everything fits" and
// dropped every event right of it. A constant, oversized child breaks
// that cache from the start.
Item {
    id: root
    required property var barWindow

    readonly property int pillWidth: 36
    readonly property int panelWidth: 300
    readonly property int gap: 16

    readonly property var active: audio.open ? audio : bt.open ? bt : wifi.open ? wifi : bright.open ? bright : null
    readonly property var menus: [audio, bt, wifi, bright]
    property int lastSlot: 0                      // keeps the exit direction after closing
    onActiveChanged: if (active) lastSlot = menus.indexOf(active)
    readonly property bool anyOpen: active !== null
    readonly property bool wantsKeyboard: wifi.open && wifi.wantsKeyboard
    readonly property alias inputWidth: pill.width      // what the bar's input mask should cover
    function closeAll() { audio.open = false; bt.open = false; wifi.open = false; bright.open = false; }
    // opening one closes the others
    function show(menu) { closeAll(); menu.open = true; }

    width: pillWidth + gap + panelWidth + 12
    height: col.implicitHeight + 16

    Rectangle {
        id: pill
        width: root.pillWidth + (root.anyOpen ? root.gap + root.panelWidth + 12 : 0)
        height: parent.height
        radius: 12
        color: Theme.c.ivory
        border.width: 1
        border.color: Theme.c.mist
        clip: true
        Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
    }

    // click-outside closes (not while a text field holds the keyboard:
    // exclusive focus reads as "lost" to the grab)
    HyprlandFocusGrab {
        windows: [root.barWindow]
        active: root.anyOpen && !root.wantsKeyboard
        onCleared: root.closeAll()
    }

    // the icon column, pinned to the left edge so it never moves
    Column {
        id: col
        parent: pill
        x: (root.pillWidth - 28) / 2
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        AirPods  { idleColor: Theme.c.ivory }
        Audio    { id: audio; host: panelHost; onRequestOpen: root.show(audio) }
        BluetoothMenu { id: bt; host: panelHost; onRequestOpen: root.show(bt) }
        WifiMenu { id: wifi; host: panelHost; onRequestOpen: root.show(wifi) }
        Brightness { id: bright; host: panelHost; onRequestOpen: root.show(bright) }
        Battery  {}
    }

    // where the active menu draws its content; fades in after the pill grows
    Item {
        id: panelHost
        parent: pill
        readonly property int activeSlot: root.lastSlot
        clip: true                                // menus slide through, no fading
        x: root.pillWidth + root.gap
        y: 8
        width: root.panelWidth
        height: parent.height - 16
        opacity: root.anyOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }
}
