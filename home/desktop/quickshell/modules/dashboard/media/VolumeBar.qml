import QtQuick
import Quickshell.Services.Pipewire
import "../../../theme"

// Vertical system volume (default sink). Click or drag anywhere.
Item {
    id: root
    readonly property var sink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: [root.sink].filter(n => n) }
    readonly property real vol: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    implicitWidth: 28

    Rectangle {                                   // track
        anchors.fill: parent
        radius: width / 2
        color: Theme.c.sand
        Rectangle {                               // fill, from the bottom
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: parent.height * Math.max(0, Math.min(1, root.vol))
            radius: parent.radius
            color: root.muted ? Theme.c.pebble : Theme.c.onyx
            Behavior on height { enabled: !area.pressed; NumberAnimation { duration: 80 } }
        }
    }
    Text {
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 8 }
        text: Math.round(root.vol * 100)
        color: root.vol > 0.12 ? Theme.c.ivory : Theme.c.onyx
        font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 3; font.bold: true
    }

    MouseArea {
        id: area
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function set(y) { if (root.sink?.audio) root.sink.audio.volume = Math.max(0, Math.min(1, 1 - y / height)) }
        onPressed: e => set(e.y)
        onPositionChanged: e => { if (pressed) set(e.y) }
        onWheel: e => { if (root.sink?.audio) root.sink.audio.volume = Math.max(0, Math.min(1, root.vol + (e.angleDelta.y > 0 ? 0.05 : -0.05))) }
    }
}
