import QtQuick
import Quickshell.Io
import Quickshell.Bluetooth
import "../../theme"
import "../../widgets"

// Toggle the AirPods. State comes straight from BlueZ over D-Bus: no polling,
// and Connecting/Disconnecting are real states rather than a lockfile.
BarButton {
    id: root
    readonly property string mac: "34:0E:22:67:BE:2D"

    readonly property var dev: Bluetooth.devices.values.find(d => d.address === root.mac) ?? null
    readonly property bool connected: dev?.connected ?? false
    readonly property bool busy: dev?.state === BluetoothDeviceState.Connecting
                              || dev?.state === BluetoothDeviceState.Disconnecting

    icon: busy ? "sync" : "earbuds"
    filled: connected
    iconColor: connected ? Theme.c.onyx : Theme.c.graphite
    tooltip: !dev ? "AirPods: not paired" : busy ? "AirPods: working…" : connected ? "AirPods: connected" : "AirPods: disconnected"

    // The adapter is off after boot (powerOnBoot = false), so connecting
    // first powers it on. Disconnect goes through D-Bus directly.
    onClicked: {
        if (!dev || busy) return;
        if (connected) { dev.disconnect(); return; }
        const a = Bluetooth.defaultAdapter;
        if (a && !a.enabled) a.enabled = true;
        dev.connect();
    }
}
