pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Stylus proximity, fed by the palm-rejection watcher
// (home/desktop/hyprland/pen-palm-reject.sh) via `qs ipc call pen …`.
// Wayland clients never learn that the pen left the glass: the emulated
// cursor parks where the pen lifted and Qt keeps hover "true" forever, so
// hover-revealed panels would never auto-hide. The stylus evdev stream is
// the only place proximity is visible, and that script already watches it
// for palm rejection.
Singleton {
    id: root

    property bool near: true      // pen is currently at the glass

    IpcHandler {
        target: "pen"
        function near(): void { root.near = true; }
        function away(): void { root.near = false; }
    }
}
