import QtQuick
import Quickshell
import "../../theme"
import "../../services"

// Top-right stack of toasts. Window is only as big as its content and
// input-masked to it, so it never blocks clicks when empty.
PanelWindow {
    id: root
    anchors { top: true; right: true }
    margins { top: 12; right: 12 }
    implicitWidth: 340
    implicitHeight: Math.max(1, col.implicitHeight)
    exclusiveZone: 0
    aboveWindows: true
    color: "transparent"
    mask: Region { item: col }
    visible: Notifications.active.length > 0

    Column {
        id: col
        width: parent.width
        spacing: 8
        Repeater {
            model: Notifications.active
            delegate: Toast {
                required property var modelData
                n: modelData
                // slide in from the right
                x: 0
                opacity: 1
                Component.onCompleted: { x = 40; opacity = 0; x = 0; opacity = 1; }
                Behavior on x       { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }
}
