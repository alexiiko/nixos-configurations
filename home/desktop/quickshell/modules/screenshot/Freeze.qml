import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// Shows a frozen screenshot fullscreen under slurp, so the region picker
// operates on what was actually captured (hover states included).
// `qs ipc call freeze show /path.png` / `qs ipc call freeze hide`.
PanelWindow {
    id: root
    property string source: ""

    IpcHandler {
        target: "freeze"
        function show(path: string): void { root.source = path; }
        function hide(): void { root.source = ""; }
    }

    visible: source !== ""
    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    mask: Region {}                    // input-transparent: slurp gets the pointer
    color: "transparent"

    Image {
        anchors.fill: parent
        source: root.source ? "file://" + root.source : ""
        cache: false
        fillMode: Image.PreserveAspectFit
    }
}
