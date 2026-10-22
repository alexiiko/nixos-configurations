import QtQuick
import "../services"

// Tap-stick filter for hover-driven auto-hide. Qt synthesizes a hover-enter
// when a finger or stylus taps, but never sends the matching hover-leave, so
// `hovered` used to stick forever and the edge panels never auto-hid (only a
// shell restart cleared it). Semantics here: a touch/stylus press that ends
// without the pointer having moved just before it is a tap — its synthetic
// hover is distrusted (`trusted` goes false) until the pointer really moves
// or presses again. A real mouse is unaffected: it always moves before it
// clicks, so its hover is never distrusted.
//
// Usage: cover the panel with this item, call moved() from the panel's
// HoverHandlers' onPointChanged, and AND the hover terms with `trusted`.
//
// The pen needs proximity, not taps: lifting it parks the emulated cursor
// inside the panel and hover stays "true" with no further events ever.
// services/Pen.qml (fed by the palm-reject watcher over IPC) marks the
// moment the pen leaves the glass, which distrusts hover the same way.
Item {
    id: root

    readonly property bool trusted: !guarded && !penAway
    property bool guarded: false      // hover is currently distrusted
    property bool penAway: false      // pen left the glass since last activity
    property bool pressing: false
    property real pressStart: 0
    property real lastMotion: 0

    // Hover point updates mean a pointer is really moving. The tap's own
    // synthetic hover-enter is ignored: it arrives while the press is down.
    function moved() {
        if (pressing) return;
        lastMotion = Date.now();
        guarded = false;
        penAway = false;
    }

    // pen proximity: away distracts hover. Coming back must NOT re-trust by
    // itself: the pen's previous hover is stuck (a leave is never delivered)
    // and would resurrect every panel at once. Only real pointer events over
    // this panel (moved(), which includes a fresh hover) re-trust it.
    Connections {
        target: Pen
        function onNearChanged() { if (!Pen.near) root.penAway = true; }
    }

    // TapHandler only for its press edges; its grab is passive, so buttons
    // and Flickables inside the panel still get their own gestures.
    TapHandler {
        id: th
        acceptedDevices: PointerDevice.TouchScreen | PointerDevice.Stylus
        onPressedChanged: {
            if (th.pressed) {
                root.pressing = true;
                root.guarded = false;           // held: visible while the contact lasts
                root.pressStart = Date.now();
                // the synthetic hover-enter can be reported just before the
                // press; motion that close to the press is that, not hover
                if (root.pressStart - root.lastMotion < 30) root.lastMotion = 0;
            } else if (root.pressing) {         // release (or a child claimed the tap)
                root.pressing = false;
                // tap = no hover motion in the 250 ms before the press. A
                // stylus that hovered, paused longer, then tapped counts as
                // a tap too — the next real motion re-trusts hover at once.
                if (root.pressStart - root.lastMotion > 250) root.guarded = true;
            }
        }
    }
}
