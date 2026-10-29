import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../../theme"
import "../../widgets"

// Spotify button. Spotifast lives on its own special workspace (see
// window-rules.nix): click toggles that workspace, or launches the app if
// it is not running — same behaviour as the WhatsApp button. The mark is
// the Spotify glyph (simple-icons, CC0) as a palette-coloured path, like
// WhatsAppLogo.
Item {
    id: root
    implicitWidth: 28
    implicitHeight: 28

    readonly property string path: "M12 0C5.4 0 0 5.4 0 12s5.4 12 12 12 12-5.4 12-12S18.66 0 12 0zm5.521 17.34c-.24.359-.66.48-1.021.24-2.82-1.74-6.36-2.101-10.561-1.141-.418.122-.779-.179-.899-.539-.12-.421.18-.78.54-.9 4.56-1.021 8.52-.6 11.64 1.32.42.18.479.659.301 1.02zm1.44-3.3c-.301.42-.841.6-1.262.3-3.239-1.98-8.159-2.58-11.939-1.38-.479.12-1.02-.12-1.14-.6-.12-.48.12-1.021.6-1.141C9.6 9.9 15 10.561 18.72 12.84c.361.181.54.78.241 1.2zm.12-3.36C15.24 8.4 8.82 8.16 5.16 9.301c-.6.179-1.2-.181-1.38-.721-.18-.601.18-1.2.72-1.381 4.26-1.26 11.28-1.02 15.721 1.621.539.3.719 1.02.419 1.56-.299.421-1.02.599-1.559.3z"

    // Identify by the Wayland toplevel's appId, like the WhatsApp button.
    readonly property var win: Hyprland.toplevels.values.find(t => (t.wayland?.appId ?? "").startsWith("spotifast")) ?? null
    readonly property bool running: win !== null

    Component.onCompleted: Hyprland.refreshToplevels()
    Timer { interval: 30000; running: true; repeat: true; onTriggered: Hyprland.refreshToplevels() }

    Process { id: launch; command: ["/home/alex/Programming/nixos-config/home/desktop/hyprland/launch-entry.sh", "spotifast"] }

    BarButton {
        id: btn
        anchors.fill: parent
        icon: ""                       // glyph replaced by the logo below
        iconColor: root.running ? Theme.c.onyx : Theme.c.graphite
        tooltip: root.running ? "Spotify" : "Spotify: not running"
        onClicked: {
            if (root.running) Hyprland.dispatch("togglespecialworkspace spotify");
            else launch.running = true;
        }
    }

    Image {
        anchors.centerIn: btn
        width: 20
        height: 20
        sourceSize: Qt.size(40, 40)
        source: "data:image/svg+xml;utf8," + encodeURIComponent(
            `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="${root.path}" fill="${btn.iconColor.toString()}"/></svg>`)
        smooth: true
        mipmap: true
    }
}
