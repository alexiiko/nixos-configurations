import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../../theme"
import "../../widgets"
import "../../services"

// WhatsApp button with an unread badge. The count is the number of WhatsApp
// notifications since the window was last shown (the app-mode window title
// is just the hostname, so the real count is not readable). Approximate,
// but a reliable "something new" signal.
// Click toggles the special workspace the window lives on; launches it if
// it is not running.
Item {
    id: root
    implicitWidth: 28
    implicitHeight: 28

    // Identify by the Wayland toplevel's appId, not Hyprland's IPC object:
    // the IPC enrichment (class/title) is often empty, the Wayland side is not.
    readonly property var win: Hyprland.toplevels.values.find(t => (t.wayland?.appId ?? "").startsWith("chrome-web.whatsapp.com")) ?? null
    readonly property bool running: win !== null
    readonly property int unread: Notifications.whatsappUnread

    // The toplevel list is not always populated on its own; ask for it
    // explicitly at start and now and then.
    Component.onCompleted: Hyprland.refreshToplevels()
    Timer { interval: 30000; running: true; repeat: true; onTriggered: Hyprland.refreshToplevels() }

    Process { id: launch; command: ["/home/alex/Programming/nixos-config/home/desktop/hyprland/launch-entry.sh", "whatsapp"] }

    BarButton {
        id: btn
        anchors.fill: parent
        icon: ""                       // glyph replaced by the logo below
        iconColor: root.running ? Theme.c.onyx : Theme.c.graphite
        tooltip: !root.running ? "WhatsApp: not running"
               : root.unread === 0 ? "WhatsApp"
               : `WhatsApp: ${root.unread} unread`
        onClicked: {
            Notifications.clearWhatsapp();
            if (root.running) Hyprland.dispatch("togglespecialworkspace whatsapp");
            else launch.running = true;
        }
    }

    WhatsAppLogo {
        anchors.centerIn: btn
        size: 22
        color: btn.iconColor
        Behavior on color { ColorAnimation { duration: 200 } }
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
