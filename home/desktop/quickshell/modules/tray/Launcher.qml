import QtQuick
import Quickshell.Io
import "../../widgets"

// A bar button that just launches a program (audio mixer, managers).
BarButton {
    id: root
    property list<string> command
    Process { id: proc; command: root.command }
    onClicked: proc.running = true
}
