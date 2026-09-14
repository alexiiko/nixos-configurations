import QtQuick
import Quickshell
import "../../theme"

// The sidebar. Left edge, full height, reserves its width so windows tile
// beside it rather than under it.
PanelWindow {
    id: root

    anchors { left: true; top: true; bottom: true }
    implicitWidth: 48
    exclusiveZone: implicitWidth
    color: Theme.c.linen

    Rectangle {
        anchors.fill: parent
        color: Theme.c.linen

        // right-edge hairline so the bar reads as a surface, not a gap
        Rectangle {
            anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
            width: 1
            color: Theme.c.mist
        }

        Clock {
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            anchors.bottomMargin: 16
        }
    }
}
