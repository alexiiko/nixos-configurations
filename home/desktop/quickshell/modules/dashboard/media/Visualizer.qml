import QtQuick
import Quickshell.Io
import "../../../theme"
import "../../../widgets"

// Audio bars from cava (raw ascii over stdout, one frame per line).
// Runs only while `active`, so a hidden dashboard costs nothing.
Card {
    color: "transparent"; border.width: 0
    id: root
    property bool active: false
    property var levels: []           // 0..100 per bar

    Process {
        id: cava
        command: ["cava", "-p", Qt.resolvedUrl("cava.conf").toString().replace("file://", "")]
        running: root.active
        stdout: SplitParser {
            onRead: line => root.levels = line.split(";").filter(s => s !== "").map(Number)
        }
        onRunningChanged: if (!running) root.levels = []
    }

    Row {
        id: bars
        anchors { fill: parent; margins: root.padding }
        spacing: 3
        readonly property int n: Math.max(1, root.levels.length)
        readonly property real barW: (width - spacing * (n - 1)) / n

        Repeater {
            model: root.levels.length
            Rectangle {
                width: bars.barW
                anchors.bottom: parent.bottom
                height: Math.max(3, bars.height * root.levels[index] / 100)
                radius: 2
                color: Theme.c.obsidian
                Behavior on height { NumberAnimation { duration: 40 } }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: root.levels.length === 0
        text: "No audio"
        color: Theme.c.slate
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
