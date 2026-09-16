pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Blue light filter state shared by the tray popover and the clock card.
// hyprsunset does the work (and its own 20:00/06:00 schedule); this holds
// the manual override and the chosen strength, persisted across restarts.
Singleton {
    id: root
    property bool on: new Date().getHours() >= 20 || new Date().getHours() < 6   // schedule guess until toggled
    property real strength: 0.5                 // 0 = 6500K (off-ish) .. 1 = 2500K
    readonly property int temperature: Math.round(6500 - strength * 4000)

    FileView {
        id: store
        path: Quickshell.env("HOME") + "/.config/theme/nightlight.json"
        blockLoading: true
        adapter: JsonAdapter {
            property bool on: root.on
            property real strength: root.strength
        }
    }
    Component.onCompleted: {
        if (store.loaded) { root.on = store.adapter.on; root.strength = store.adapter.strength; }
    }
    function save() { store.adapter.on = on; store.adapter.strength = strength; store.writeAdapter(); }

    Process { id: cmd }
    function apply() {
        cmd.command = on ? ["hyprctl", "hyprsunset", "temperature", String(temperature)]
                         : ["hyprctl", "hyprsunset", "identity"];
        cmd.running = true;
        save();
    }
    function toggle() { on = !on; apply(); }
    function setStrength(v) { strength = Math.max(0, Math.min(1, v)); if (!on) on = true; apply(); }
}
