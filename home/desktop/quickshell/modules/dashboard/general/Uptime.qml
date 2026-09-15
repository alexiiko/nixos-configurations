import QtQuick
import Quickshell.Io
import "../../../theme"
import "../../../widgets"

// System uptime from /proc/uptime, refreshed once a minute.
Card {
    id: root
    property int seconds: 0

    FileView {
        id: up
        path: "/proc/uptime"
        onLoaded: root.seconds = Math.floor(parseFloat(text()))
    }
    Timer { interval: 60000; running: true; repeat: true; onTriggered: up.reload() }

    readonly property string label: {
        const d = Math.floor(seconds / 86400), h = Math.floor(seconds % 86400 / 3600), m = Math.floor(seconds % 3600 / 60);
        return d > 0 ? `${d}d ${h}h` : h > 0 ? `${h}h ${m}m` : `${m}m`;
    }

    // Text is the anchor (centred on the card); the icon hangs off its left.
    // `iconGap` moves only the icon.
    property int iconGap: 14

    Column {
        id: textCol
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 12   // text right of centre so icon+text balance as a group
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.label; color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: 22; font.weight: Font.Medium }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Uptime"; color: Theme.c.charcoal; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1 }
    }
    Icon {
        anchors { right: textCol.left; rightMargin: root.iconGap; verticalCenter: textCol.verticalCenter }
        name: "schedule"; size: 24; color: Theme.c.onyx
    }
}
