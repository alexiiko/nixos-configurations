import QtQuick
import Quickshell.Hyprland
import "../../theme"
import "../../widgets"

// Power button in the bar. Click grows a pill out of it — rightward and
// upward — holding the actions. Same construction as CalendarButton (constant
// oversized host, animated pill inside; see Tray.qml for why).
Item {
    id: root
    required property var barWindow
    property bool open: false

    implicitWidth: 28
    implicitHeight: 28

    readonly property int pillWidth: 36
    readonly property int panelWidth: 168
    readonly property int gap: 16
    readonly property int overhang: 0           // extra card height below the button
    readonly property int panelHeight: list.implicitHeight + 16

    // what the bar's input mask should cover, relative to this item
    readonly property real inputX: host.x
    readonly property real inputY: host.y + pill.y
    readonly property alias inputWidth: pill.width
    readonly property real inputHeight: pill.height + overhang

    HyprlandFocusGrab {
        windows: [root.barWindow]
        active: root.open
        onCleared: root.open = false
    }

    Item {
        id: host
        x: -(root.pillWidth - root.implicitWidth) / 2
        y: root.implicitHeight + (root.pillWidth - root.implicitWidth) / 2 - height
        width: root.pillWidth + root.gap + root.panelWidth + 12
        height: Math.max(root.pillWidth, root.panelHeight)

        Rectangle {
            id: pill
            anchors { left: parent.left; bottom: parent.bottom }
            width: root.open ? parent.width : root.pillWidth
            height: root.open ? parent.height : root.pillWidth
            color: "transparent"
            Behavior on width  { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            BarButton {
                anchors { left: parent.left; bottom: parent.bottom }
                anchors.margins: (root.pillWidth - width) / 2
                icon: "power_settings_new"
                active: root.open
                tooltip: "Power"
                onClicked: root.open = !root.open
            }

            // the card tracks the animated pill size, so it flies out itself
            Rectangle {
                x: root.pillWidth + root.gap
                width: Math.max(0, pill.width - x)
                height: pill.height - (root.pillWidth - root.implicitWidth) / 2 + root.overhang
                visible: width > 0
                clip: true
                radius: 12
                color: Theme.c.ivory

                Column {
                    id: list
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }
                    width: root.panelWidth - 16
                    spacing: 2

                    PowerAction { icon: "lock";                label: "Lock";      command: ["hyprlock"];              onTriggered: root.open = false }
                    PowerAction { icon: "bedtime";             label: "Sleep";     command: ["systemctl", "suspend"];  onTriggered: root.open = false }
                    PowerAction { icon: "restart_alt";         label: "Restart";   command: ["systemctl", "reboot"];   onTriggered: root.open = false }
                    PowerAction { icon: "power_settings_new";  label: "Shut down"; command: ["systemctl", "poweroff"]; onTriggered: root.open = false }
                }
            }
        }
    }
}
