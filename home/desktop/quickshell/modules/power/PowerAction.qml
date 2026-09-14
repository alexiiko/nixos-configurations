import QtQuick
import Quickshell.Io
import "../../theme"
import "../../widgets"

// One row of the power popover.
Rectangle {
    id: row
    property string icon
    property string label
    property list<string> command
    signal triggered()

    width: parent.width
    height: 34
    radius: 8
    color: mouse.containsMouse ? Theme.c.cream : Theme.c.ivory
    Behavior on color { ColorAnimation { duration: 150 } }

    Row {
        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
        spacing: 10
        Icon { name: row.icon; size: 18; anchors.verticalCenter: parent.verticalCenter }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: row.label
            color: Theme.c.onyx
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    Process { id: proc; command: row.command }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: { row.triggered(); proc.running = true; }
    }
}
