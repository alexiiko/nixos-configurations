import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../../theme"
import "../../widgets"

// Power button in the bar + a popover that opens beside it.
// Click outside or Escape closes it (HyprlandFocusGrab).
Item {
    id: root
    required property var barWindow     // the PanelWindow to anchor to

    implicitWidth: 28
    implicitHeight: 28

    property bool open: false

    // --- the button in the bar ---------------------------------------------
    Rectangle {
        id: button
        anchors.fill: parent
        radius: 8
        color: root.open ? Theme.c.sand : hover.containsMouse ? Theme.c.sand : Theme.c.linen
        Behavior on color { ColorAnimation { duration: 200 } }

        Icon { anchors.centerIn: parent; name: "power_settings_new"; size: 20 }

        MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.open = !root.open
        }
    }

    // --- the popover -------------------------------------------------------
    PopupWindow {
        id: popup
        anchor {
            window: root.barWindow
            item: root
            edges: Edges.Right
            gravity: Edges.Right
            margins.left: 10
        }
        visible: root.open
        implicitWidth: 168
        implicitHeight: list.implicitHeight + 16
        color: "transparent"

        HyprlandFocusGrab {
            windows: [popup, root.barWindow]
            active: root.open
            onCleared: root.open = false
        }

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: Theme.c.ivory
            border.width: 1
            border.color: Theme.c.mist

            Column {
                id: list
                anchors { fill: parent; margins: 8 }
                spacing: 2

                PowerAction { icon: "lock";                label: "Lock";      command: ["hyprlock"];          onTriggered: root.open = false }
                PowerAction { icon: "bedtime";             label: "Sleep";     command: ["systemctl", "suspend"]; onTriggered: root.open = false }
                PowerAction { icon: "restart_alt";         label: "Restart";   command: ["systemctl", "reboot"];  onTriggered: root.open = false }
                PowerAction { icon: "power_settings_new";  label: "Shut down"; command: ["systemctl", "poweroff"]; onTriggered: root.open = false }
            }
        }

        // Escape closes
        Item {
            anchors.fill: parent
            focus: root.open
            Keys.onEscapePressed: root.open = false
        }
    }
}
