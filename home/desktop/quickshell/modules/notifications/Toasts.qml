import QtQuick
import Quickshell
import "../../theme"
import "../../services"

// Top-right stack of toasts. The window spans the screen width so a toast can
// start beyond the right edge (clipped, hence "from off-screen") and leave past
// the left; only the toast column takes input, so the rest never blocks clicks.
PanelWindow {
    id: root
    readonly property int toastWidth: 340
    readonly property int gap: 12

    anchors { top: true; left: true; right: true }
    margins { top: 12 }
    // fixed surface: resizing the layer every frame while a toast animates
    // made the card tear. Only the input mask follows the content.
    implicitHeight: screen ? screen.height - 24 : 900
    exclusiveZone: 0
    aboveWindows: true
    color: "transparent"
    mask: Region { item: maskArea }
    visible: Notifications.active.count > 0

    readonly property int restX: width - toastWidth - gap     // resting position

    Item {
        id: maskArea
        x: root.restX; width: root.toastWidth
        y: 0; height: list.implicitHeight
    }

    // plain Column + Repeater again: the toasts animate themselves (see
    // Toast.qml), the column only slides the stack when one leaves
    Column {
        id: list
        x: root.restX; y: 0
        width: root.toastWidth
        spacing: 8

        move: Transition { NumberAnimation { properties: "y"; duration: 220; easing.type: Easing.OutCubic } }

        Repeater {
            model: Notifications.active
            // wrapper holds the column slot: the card keeps its size while
            // leaving, only the space it occupies collapses
            delegate: Item {
                required property var notif
                width: root.toastWidth
                height: card.fullHeight * card.slot
                Toast { id: card; n: parent.notif; width: root.toastWidth }
            }
        }
    }
}
