import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import "../../theme"
import "../dashboard/media"

// System volume on the right edge, vertically centred. Same auto-hide as the
// sidebar: a thin hot strip reveals it, sliding in from the right; leaving
// hides it. Reuses the dashboard's VolumeBar.
PanelWindow {
    id: root

    property bool revealed: false
    readonly property int hideDelay: 150
    readonly property int triggerWidth: 6
    readonly property int pad: 10
    readonly property int edgeGap: 25             // space between bar and screen edge

    anchors { right: true }                   // right only: layer-shell centres it vertically
    implicitWidth: 28 + pad + edgeGap
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
        HoverHandler { id: triggerHover }
    }

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

    readonly property bool wantVisible: triggerHover.hovered || surfaceHover.hovered || flash.running
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
        color: "transparent"                   // no card: only the bar slides in

        HoverHandler { id: surfaceHover }
        VolumeBar { anchors { fill: parent; margins: root.pad; rightMargin: root.edgeGap } }
    }
}
