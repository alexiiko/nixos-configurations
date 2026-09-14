import QtQuick
import Quickshell.Services.UPower
import "../../theme"
import "../../widgets"

// Battery glyph + percentage. Icon fills as charge rises; charging shows a
// bolt. Clay only when critical, per the palette rules.
Column {
    id: root
    spacing: 2

    readonly property var dev: UPower.displayDevice
    readonly property int pct: Math.round((dev?.percentage ?? 0) * 100)
    readonly property bool charging: dev?.state === UPowerDeviceState.Charging
                                  || dev?.state === UPowerDeviceState.FullyCharged
    readonly property bool critical: !charging && pct <= 10

    readonly property string glyph: {
        if (charging) return "battery_charging_full";
        if (pct >= 95) return "battery_full";
        if (pct >= 80) return "battery_6_bar";
        if (pct >= 65) return "battery_5_bar";
        if (pct >= 50) return "battery_4_bar";
        if (pct >= 35) return "battery_3_bar";
        if (pct >= 20) return "battery_2_bar";
        if (pct >= 10) return "battery_1_bar";
        return "battery_alert";
    }

    visible: dev?.isLaptopBattery ?? false

    Icon {
        anchors.horizontalCenter: parent.horizontalCenter
        name: root.glyph
        size: 20
        color: root.critical ? Theme.c.clay : Theme.c.onyx
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.pct
        color: root.critical ? Theme.c.clay : Theme.c.charcoal
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
    }
}
