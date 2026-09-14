import QtQuick
import "../../theme"

// Vertical clock: hours over minutes. Ticks once a minute, not once a
// second, so the panel stays static and PSR keeps saving power.
Column {
    id: root
    spacing: 0

    property date now: new Date()

    Timer {
        interval: 60000 - (Date.now() % 60000)   // align to the minute boundary
        running: true
        repeat: false
        onTriggered: { root.now = new Date(); minuteTick.start(); }
    }
    Timer {
        id: minuteTick
        interval: 60000
        repeat: true
        onTriggered: root.now = new Date()
    }

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
