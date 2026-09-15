import QtQuick
import "../theme"

// Horizontal slider, 0..1. Click or drag anywhere on the track.
Item {
    id: root
    property real value: 0
    property bool enabled: true
    signal moved(real v)

    implicitHeight: 20
    implicitWidth: 160

    Rectangle {                       // track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width; height: 4; radius: 2
        color: Theme.c.silverBirch
        Rectangle {                   // fill
            width: parent.width * Math.max(0, Math.min(1, root.value)); height: parent.height; radius: 2
            color: root.enabled ? Theme.c.onyx : Theme.c.pebble
            Behavior on width { enabled: !area.pressed; NumberAnimation { duration: 80 } }
        }
    }
    Rectangle {                       // handle
        x: (parent.width - width) * Math.max(0, Math.min(1, root.value))
        anchors.verticalCenter: parent.verticalCenter
        width: 14; height: 14; radius: 7
        color: root.enabled ? Theme.c.onyx : Theme.c.pebble
        border.width: 2; border.color: Theme.c.ivory
        scale: area.pressed ? 1.15 : area.containsMouse ? 1.08 : 1
        Behavior on scale { NumberAnimation { duration: 100 } }
    }
    MouseArea {
        id: area
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        function set(mx) { root.moved(Math.max(0, Math.min(1, (mx - 4) / root.width))); }
        onPressed: (e) => set(e.x)
        onPositionChanged: (e) => { if (pressed) set(e.x); }
        onWheel: (e) => root.moved(Math.max(0, Math.min(1, root.value + (e.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
