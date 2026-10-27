import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../theme"
import "../../widgets"

// Screen brightness OSD, horizontal, top-left in the gap between the sidebar
// and the dashboard. Same auto-hide as the volume bar: a hot strip on the top
// edge reveals it, sliding down from above; leaving hides it. Any brightness
// change from outside (Fn keys, the tray slider) flashes it for a moment,
// like the iOS volume HUD. The bar itself is also a slider.
PanelWindow {
    id: root

    property bool revealed: false
    readonly property int hideDelay: 150
    readonly property int triggerHeight: 6

    // flush to the top edge so the hover trigger lies on the screen edge;
    // the card sits 12 px below it. Right of the dashboard, clear of the
    // volume OSD on the right edge.
    anchors { top: true; right: true }
    margins { right: 25 }     // aligns with the volume card's edge gap
    implicitWidth: 300
    implicitHeight: 76
    exclusiveZone: 0
    aboveWindows: true
    WlrLayershell.layer: WlrLayer.Overlay   // above fullscreen windows too
    color: "transparent"

    // the trigger strip must stay in the mask once revealed: the card sits
    // below it, and hovering the edge would then lose hover and flap the panel
    mask: Region { item: root.revealed ? surface : trigger; regions: [ Region { item: trigger } ] }

    // brightness from sysfs, watched so external changes flash the OSD too
    // (same source as modules/tray/Brightness.qml)
    readonly property string dev: "/sys/class/backlight/intel_backlight"
    FileView { id: cur; path: root.dev + "/brightness"; watchChanges: true; onFileChanged: { reload(); flash.restart(); } }
    FileView { id: max; path: root.dev + "/max_brightness" }
    readonly property real level: Number(max.text()) > 0 ? Number(cur.text()) / Number(max.text()) : 0

    Item {
        id: trigger; x: 0; y: 0; width: parent.width; height: root.triggerHeight
        HoverHandler { id: triggerHover; onPointChanged: guard.moved() }
    }

    TapGuard { id: guard; anchors.fill: parent }   // taps leave sticky hover; see widgets/TapGuard.qml

    Timer { id: flash; interval: 1400 }

    readonly property bool wantVisible: ((triggerHover.hovered || surfaceHover.hovered) && guard.trusted) || flash.running
    onWantVisibleChanged: {
        if (wantVisible) { hideTimer.stop(); revealed = true; }
        else hideTimer.restart();
    }
    Timer { id: hideTimer; interval: root.hideDelay; onTriggered: root.revealed = false }

    Card {
        id: surface
        width: root.width
        height: root.height - 12
        y: root.revealed ? 12 : -height
        Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        rightPadding: 22                  // keep the percentage off the edge

        HoverHandler { id: surfaceHover; onPointChanged: guard.moved() }

        Row {
            anchors.fill: parent
            spacing: 12

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: Theme.mode === "dark" ? "dark_mode" : "light_mode"
                size: 22
                color: Theme.c.onyx
            }

            Rectangle {
                id: track
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 22 - 12 - 44 - 12
                height: 10; radius: height / 2
                color: Theme.c.sand
                Rectangle {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                    width: parent.width * Math.max(0, Math.min(1, root.level))
                    radius: parent.radius
                    color: Theme.c.onyx
                    Behavior on width { enabled: !area.pressed; NumberAnimation { duration: 80 } }
                }
                // drag to set, like the volume bar
                MouseArea {
                    id: area
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    function set(x) { setter.command = ["brightnessctl", "-q", "set", Math.round(Math.max(0.01, Math.min(1, x / width)) * 100) + "%"]; setter.running = true; }
                    onPressed: e => set(e.x)
                    onPositionChanged: e => { if (pressed) set(e.x) }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 44; horizontalAlignment: Text.AlignRight
                text: Math.round(root.level * 100) + "%"
                color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1
            }
        }
    }

    Process { id: setter }
}
