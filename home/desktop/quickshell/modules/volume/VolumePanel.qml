import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import "../../theme"
import "../../widgets"
import "../dashboard/media"

// System volume on the right edge, vertically centred. Same auto-hide as the
// sidebar: a thin hot strip reveals it, sliding in from the right; leaving
// hides it. Reuses the dashboard's VolumeBar.
PanelWindow {
    id: root

    property bool revealed: false
    readonly property int hideDelay: 150
    readonly property int triggerWidth: 6
    readonly property int edgeGap: 25             // space between card and screen edge

    anchors { right: true }                   // right only: layer-shell centres it vertically
    implicitWidth: 56 + edgeGap                  // card 56 wide (28 bar + 14 padding)
    implicitHeight: 220
    exclusiveZone: 0
    aboveWindows: true
    WlrLayershell.layer: WlrLayer.Overlay   // above fullscreen windows too
    color: "transparent"

    mask: Region { item: root.revealed ? surface : trigger }

    Item {
        id: trigger
        x: parent.width - root.triggerWidth; y: 0
        width: root.triggerWidth; height: parent.height
        HoverHandler { id: triggerHover; onPointChanged: guard.moved() }
    }

    TapGuard { id: guard; anchors.fill: parent }   // taps leave sticky hover; see widgets/TapGuard.qml

    // Any volume change from outside (AirPods buttons, media keys, another
    // app) flashes the bar for a moment, like the iOS volume HUD.
    readonly property var sink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: [root.sink].filter(n => n) }
    Connections {
        target: root.sink?.audio ?? null
        function onVolumeChanged() { flash.restart(); }
        function onMutedChanged() { flash.restart(); }
    }
    Timer { id: flash; interval: 1400 }

    readonly property bool wantVisible: ((triggerHover.hovered || surfaceHover.hovered) && guard.trusted) || flash.running
    onWantVisibleChanged: {
        if (wantVisible) { hideTimer.stop(); revealed = true; }
        else hideTimer.restart();
    }
    Timer { id: hideTimer; interval: root.hideDelay; onTriggered: root.revealed = false }

    Rectangle {
        id: surface
        width: root.width
        height: root.height
        x: root.revealed ? 0 : width
        Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        color: "transparent"

        HoverHandler { id: surfaceHover; onPointChanged: guard.moved() }

        // styled like the brightness bar: card, icon, bar, percentage
        Card {
            width: 56
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right; rightMargin: root.edgeGap }

            Column {
                anchors.fill: parent
                spacing: 10

                Icon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    name: bar.muted ? "volume_off" : bar.vol < 0.5 ? "volume_down" : "volume_up"
                    size: 22
                    color: Theme.c.onyx
                }
                VolumeBar {
                    id: bar
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 28
                    height: parent.height - 22 - 16 - 2 * parent.spacing
                    showValue: false
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Math.round(bar.vol * 100) + "%"
                    color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1
                }
            }
        }
    }
}
