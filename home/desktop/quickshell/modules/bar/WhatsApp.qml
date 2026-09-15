import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../../theme"
import "../../widgets"

// WhatsApp button with an unread badge. The count comes from the window
// title: WhatsApp Web sets it to "(N) WhatsApp" when there are unread chats,
// which Hyprland exposes live. No API, no polling.
// Click toggles the special workspace the window lives on; launches it if
// it is not running.
Item {
    id: root
    implicitWidth: 28
    implicitHeight: 28

    readonly property var win: Hyprland.toplevels.values.find(t => (t.lastIpcObject?.class ?? "").startsWith("chrome-web.whatsapp.com")) ?? null
    readonly property bool running: win !== null
    readonly property int unread: {
        const m = /^\((\d+)\)/.exec(win?.title ?? "");
        return m ? parseInt(m[1]) : 0;
    }

    Process { id: launch; command: ["/home/alex/Programming/nixos-config/home/desktop/hyprland/launch-entry.sh", "whatsapp"] }

    BarButton {
        id: btn
        anchors.fill: parent
        icon: "chat"
        filled: root.unread > 0
        iconColor: root.running ? Theme.c.onyx : Theme.c.graphite
        tooltip: !root.running ? "WhatsApp: not running"
               : root.unread === 0 ? "WhatsApp"
               : `WhatsApp: ${root.unread} unread`
        onClicked: {
            if (root.running) Hyprland.dispatch("togglespecialworkspace whatsapp");
            else launch.running = true;
        }
    }

    // badge, top-right, only when there is something to say
    Rectangle {
        visible: root.unread > 0
        anchors { top: parent.top; right: parent.right }
        anchors.topMargin: -4; anchors.rightMargin: -6
        width: Math.max(16, label.implicitWidth + 8)
        height: 16
        radius: 8
        color: Theme.c.onyx
        border.width: 2
        border.color: Theme.c.linen         // ring in the bar colour so it reads as floating
        Text {
            id: label
            anchors.centerIn: parent
            text: root.unread > 99 ? "99+" : root.unread
            color: Theme.c.ivory
            font.family: Theme.fontFamily
            font.pixelSize: 9
            font.weight: Font.DemiBold
        }
    }
}
