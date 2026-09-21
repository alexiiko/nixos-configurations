import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../theme"
import "../../widgets"
import "../dashboard/general"

// Calendar button under WhatsApp. Click grows a pill out of the button —
// rightward and upward — with today's timeline (the dashboard card) inside.
// Same shape as the tray: a constant oversized host with an animated pill
// in it (see Tray.qml for why the host must not grow).
Item {
    id: root
    required property var barWindow
    property bool open: false

    implicitWidth: 28
    implicitHeight: 28

    readonly property int pillWidth: 36
    readonly property int panelWidth: 300
    readonly property int panelHeight: 440
    readonly property int gap: 16

    // what the bar's input mask should cover, relative to this item
    readonly property real inputX: host.x
    readonly property real inputY: host.y + pill.y
    readonly property alias inputWidth: pill.width
    readonly property alias inputHeight: pill.height

    SystemClock { id: clock; precision: SystemClock.Hours }

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
        height: root.panelHeight

        Rectangle {
            id: pill
            anchors { left: parent.left; bottom: parent.bottom }
            width: root.open ? parent.width : root.pillWidth
            height: root.open ? parent.height : root.pillWidth
            color: "transparent"           // no box: only the card itself grows
            Behavior on width  { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

            BarButton {
                id: btn
                anchors { left: parent.left; bottom: parent.bottom }
                anchors.margins: (root.pillWidth - width) / 2
                icon: ""                       // logo below
                active: root.open
                tooltip: "Calendar"
                onClicked: root.open = !root.open
            }
            GCalLogo { anchors.centerIn: btn; size: 20 }

            // the card tracks the animated pill size, so it flies out itself
            GoogleCalendar {
                x: root.pillWidth + root.gap
                width: Math.max(0, pill.width - x)
                // bottom edge level with the button, not the pill around it
                height: pill.height - (root.pillWidth - root.implicitWidth) / 2
                visible: width > 0
                clip: true
                date: clock.date            // follows the real day, not shell start
            }
        }
    }
}
