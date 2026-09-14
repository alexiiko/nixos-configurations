import QtQuick
import "../theme"

// Square icon button for the sidebar. Same hover/active treatment everywhere.
Rectangle {
    id: root
    property string icon
    property bool filled: false
    property bool active: false
    property color iconColor: Theme.c.onyx
    property string tooltip: ""
    signal clicked()

    width: 28
    height: 28
    radius: 8
    property color idleColor: Theme.c.linen
    color: active || mouse.containsMouse ? Theme.c.sand : idleColor
    Behavior on color { ColorAnimation { duration: 200 } }

    Icon {
        anchors.centerIn: parent
        name: root.icon
        filled: root.filled
        size: 20
        color: root.iconColor
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Tooltip { target: root; text: root.tooltip; hovered: mouse.containsMouse }
}
