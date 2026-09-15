import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../../theme"
import "../../widgets"
import "../../services"

// CPU | Memory | Power mode — three ring gauges.
RowLayout {
    id: root
    spacing: 8

    // CPU: temperature on the main arc (0..100 °C), usage on the inner arc
    Gauge {
        Layout.fillWidth: true; Layout.preferredWidth: 1; Layout.preferredHeight: 200; Layout.maximumHeight: 200; Layout.alignment: Qt.AlignVCenter
        value: System.cpuTemp / 100
        text: System.cpuTemp + "°C"
        label: "CPU temp"
        secondary: System.cpuUsage
        secondaryText: Math.round(System.cpuUsage * 100) + "%"
        secondaryLabel: "Usage"
    }

    // Middle column: fan profile on top, battery underneath
    ColumnLayout {
        Layout.fillWidth: true; Layout.preferredWidth: 1; Layout.fillHeight: true
        spacing: 0

    // Power / fan profile: arc shows the level, click cycles through modes
    Item {
        Layout.fillWidth: true; Layout.preferredHeight: 150; Layout.maximumHeight: 150; Layout.alignment: Qt.AlignHCenter
        readonly property int idx: Math.max(0, System.modes.indexOf(System.mode))
        readonly property var names: ({ "low-power": "Silent", "quiet": "Quiet", "balanced": "Balanced", "performance": "Performance" })
        readonly property var icons: ({ "low-power": "mode_fan_off", "quiet": "mode_fan", "balanced": "mode_fan", "performance": "mode_fan" })

        Gauge {
            id: powerGauge
            anchors.fill: parent
            value: (parent.idx + 1) / System.modes.length
            icon: parent.icons[System.mode] ?? "mode_fan"
            iconFilled: System.mode === "performance"
            label: parent.names[System.mode] ?? System.mode
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: (e) => {
                // left: next mode, right: previous
                const n = System.modes.length;
                const next = e.button === Qt.RightButton ? (parent.idx + n - 1) % n : (parent.idx + 1) % n;
                System.setPowerMode(System.modes[next]);
            }
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            Tooltip { target: parent; hovered: parent.containsMouse; text: "Fan profile — click to change" }
        }
    }

    // Battery: charge on the arc, remaining time as the label
    Gauge {
        Layout.fillWidth: true; Layout.preferredHeight: 150; Layout.maximumHeight: 150; Layout.alignment: Qt.AlignHCenter
        readonly property var dev: UPower.displayDevice
        readonly property int pct: Math.round((dev?.percentage ?? 0) * 100)
        readonly property bool charging: dev?.state === UPowerDeviceState.Charging
        readonly property bool full: dev?.state === UPowerDeviceState.FullyCharged
        function fmt(sec) { const m = Math.round(sec / 60), h = Math.floor(m / 60); return h > 0 ? `${h}h ${(m % 60).toString().padStart(2, "0")}m` : `${m}m`; }
        value: pct / 100
        text: pct + "%"
        label: !dev ? "" : full ? "Full" : charging ? (dev.timeToFull > 0 ? fmt(dev.timeToFull) + " to full" : "Charging") : (dev.timeToEmpty > 0 ? fmt(dev.timeToEmpty) + " left" : "Battery")
        arcColor: !charging && !full && pct <= 10 ? Theme.c.clay : Theme.c.onyx
    }
    }

    // Memory used on the main arc, storage on the inner arc
    Gauge {
        Layout.fillWidth: true; Layout.preferredWidth: 1; Layout.preferredHeight: 200; Layout.maximumHeight: 200; Layout.alignment: Qt.AlignVCenter
        value: System.memTotal > 0 ? System.memUsed / System.memTotal : 0
        text: System.gib(System.memUsed) + "GiB"
        label: "Memory"
        secondary: System.diskTotal > 0 ? System.diskUsed / System.diskTotal : -1
        secondaryText: Math.round(System.diskUsed / 1073741824) + "GiB"
        secondaryLabel: "Storage"
    }

}
