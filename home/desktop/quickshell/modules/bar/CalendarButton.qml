import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../theme"
import "../../widgets"
import "../dashboard/general"

// Calendar button under WhatsApp. Click opens today's timeline (the same
// card as the dashboard) in a popover beside the bar.
Item {
    id: root
    required property var barWindow

    implicitWidth: 28
    implicitHeight: 28
    property bool open: false

    BarButton {
        id: btn
        anchors.fill: parent
        icon: ""                       // logo below
        active: root.open
        tooltip: "Calendar"
        onClicked: root.open = !root.open
    }
    GCalLogo { anchors.centerIn: btn; size: 20 }

    PopupWindow {
        id: popup
        anchor {
            window: root.barWindow
            item: root
            edges: Edges.Right
            gravity: Edges.Right | Edges.Top      // grow upward from the button
            margins.left: 10
        }
        visible: root.open
        implicitWidth: 300
        implicitHeight: 440
        color: "transparent"

        HyprlandFocusGrab {
            windows: [popup, root.barWindow]
            active: root.open
            onCleared: root.open = false
        }

        Rectangle {
            anchors.fill: parent
            radius: 14
            color: Theme.c.linen
            border.width: 1
            border.color: Theme.c.mist

            GoogleCalendar {
                anchors { fill: parent; margins: 10 }
                date: new Date()
            }
        }

        Item { anchors.fill: parent; focus: root.open; Keys.onEscapePressed: root.open = false }
    }
}
