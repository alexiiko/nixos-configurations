import QtQuick
import Quickshell.Services.UPower
import "../../theme"
import "../../widgets"

// Battery glyph (on its side) + "54%". Tooltip shows remaining time.
// Clay only when critical, per the palette rules.
Item {
    id: root
    implicitWidth: 28
    implicitHeight: col.implicitHeight

    readonly property var dev: UPower.displayDevice
    readonly property int pct: Math.round((dev?.percentage ?? 0) * 100)
    readonly property bool charging: dev?.state === UPowerDeviceState.Charging
    readonly property bool full: dev?.state === UPowerDeviceState.FullyCharged
    readonly property bool critical: !charging && !full && pct <= 10

    readonly property string glyph: {
        if (charging || full) return "battery_charging_full";
        if (pct >= 95) return "battery_full";
        if (pct >= 80) return "battery_6_bar";
        if (pct >= 65) return "battery_5_bar";
        if (pct >= 50) return "battery_4_bar";
        if (pct >= 35) return "battery_3_bar";
        if (pct >= 20) return "battery_2_bar";
        if (pct >= 10) return "battery_1_bar";
        return "battery_alert";
    }

    function fmt(seconds) {
        const m = Math.round(seconds / 60);
        const h = Math.floor(m / 60), r = m % 60;
        return h > 0 ? `${h}h ${r.toString().padStart(2, "0")}m` : `${r}m`;
    }
    readonly property string tooltip: {
        if (!dev) return "";
        if (full) return "Fully charged";
        if (charging) return dev.timeToFull > 0 ? `${fmt(dev.timeToFull)} until full` : "Charging";
        return dev.timeToEmpty > 0 ? `${fmt(dev.timeToEmpty)} remaining` : `${pct}%`;
    }

    visible: dev?.isLaptopBattery ?? false

    Column {
        id: col
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2

        Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: root.glyph
            size: 20
            color: root.critical ? Theme.c.clay : Theme.c.onyx
            rotation: 90
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.pct + "%"
            color: root.critical ? Theme.c.clay : Theme.c.charcoal
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 2
        }
    }

    MouseArea { id: hover; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
    Tooltip { target: root; text: root.tooltip; hovered: hover.containsMouse }
}
