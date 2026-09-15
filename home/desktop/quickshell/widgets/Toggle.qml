import QtQuick
import "../theme"

// Pill switch. Emits toggled(v); the owner decides whether to apply it.
Item {
    id: root
    property bool checked: false
    signal toggled(bool v)
    implicitWidth: 40
    implicitHeight: 22

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.c.onyx : Theme.c.pebble
        Behavior on color { ColorAnimation { duration: 150 } }
        Rectangle {
            x: root.checked ? parent.width - width - 3 : 3
            anchors.verticalCenter: parent.verticalCenter
            width: 16; height: 16; radius: 8
            color: Theme.c.ivory
            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }
    }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.toggled(!root.checked) }
}
