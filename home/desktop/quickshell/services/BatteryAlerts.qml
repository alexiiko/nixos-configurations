import QtQuick
import Quickshell.Io
import Quickshell.Services.UPower

// Low-battery notifications: a warning at 15 %, critical at 8 %. Each fires
// once per discharge; plugging in resets them.
Item {
    id: root
    readonly property var dev: UPower.displayDevice
    readonly property int pct: Math.round((dev?.percentage ?? 1) * 100)
    readonly property bool discharging: dev?.state === UPowerDeviceState.Discharging
    property bool warned: false
    property bool critical: false

    Process { id: notify }
    function send(urgency, title, body) {
        notify.command = ["notify-send", "-a", "Battery", "-u", urgency, title, body];
        notify.running = true;
    }

    function check() {
        if (!discharging) { warned = false; critical = false; return; }
        if (pct <= 8 && !critical) { critical = true; send("critical", `Battery critical: ${pct}%`, "Plug in now"); }
        else if (pct <= 15 && !warned) { warned = true; send("normal", `Battery low: ${pct}%`, "Plug in soon"); }
    }
    onPctChanged: check()
    onDischargingChanged: check()
}
