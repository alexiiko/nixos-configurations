import QtQuick
import Quickshell.Io
import "../../theme"
import "../../widgets"

// Logo button at the top: opens a terminal running fastfetch, then a shell.
Rectangle {
    id: root
    width: 28          // match the workspace pills
    height: 28
    radius: 8
    color: mouse.containsMouse ? Theme.c.sand : Theme.c.linen
    Behavior on color { ColorAnimation { duration: 200 } }

    NixLogo { anchors.centerIn: parent; size: 24 }

    Process {
        id: proc
        command: ["kitty", "-e", "zsh", "-ic", "fastfetch; exec zsh"]
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: proc.running = true
    }

    Tooltip { target: root; text: "System info"; hovered: mouse.containsMouse }
}
