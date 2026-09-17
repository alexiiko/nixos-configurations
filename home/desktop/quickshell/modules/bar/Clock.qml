import QtQuick
import Quickshell
import "../../theme"

// Vertical clock: hours over minutes. Minute precision, not seconds, so
// the panel stays static and PSR keeps saving power. SystemClock follows
// the real clock across suspend and time changes.
Column {
    id: root
    spacing: 0

    SystemClock { id: clock; precision: SystemClock.Minutes }
    readonly property date now: clock.date

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatTime(root.now, "HH")
        color: Theme.c.onyx
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 1
        font.weight: Font.Medium
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatTime(root.now, "mm")
        color: Theme.c.charcoal
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 1
    }
}
