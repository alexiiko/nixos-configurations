import QtQuick
import Quickshell
import "../../theme"
import "../power"
import "../tray"

// The sidebar. Left edge, full height, reserves its width so windows tile
// beside it rather than under it. The window is transparent and the surface
// is drawn inside it, so the outer corners can be rounded.
PanelWindow {
    id: root

    anchors { left: true; top: true; bottom: true }
    implicitWidth: 48
    exclusiveZone: implicitWidth
    color: "transparent"

    Rectangle {
        id: surface
        anchors.fill: parent
        color: Theme.c.linen
        border.width: 1
        border.color: Theme.c.mist

        // Only the outer corners: the left edge sits on the screen edge.
        topRightRadius: 14
        bottomRightRadius: 14

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

            Clock   { anchors.horizontalCenter: parent.horizontalCenter }
            Tray    { anchors.horizontalCenter: parent.horizontalCenter }
            PowerMenu { anchors.horizontalCenter: parent.horizontalCenter; barWindow: root }
        }
    }
}
