import QtQuick
import "../../theme"
import "../../widgets"

// Dashboard tab: icon over label, underline when selected. No pill; the
// tabs share the row width evenly and the underline sits on the divider.
Item {
    id: root
    property string label
    property string icon
    property bool selected: false
    signal clicked()

    implicitHeight: 62

    readonly property color tone: selected ? Theme.c.onyx
                                 : mouse.containsMouse ? Theme.c.obsidian
                                 : Theme.c.graphite

    Column {
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top }
        spacing: 4

        Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: root.icon
            size: 22
            filled: root.selected
            color: root.tone
            Behavior on color { ColorAnimation { duration: 200 } }
        }
        Text {
            id: text
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            color: root.tone
            Behavior on color { ColorAnimation { duration: 200 } }
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 1
            font.weight: root.selected ? Font.Medium : Font.Normal
        }
    }

    // Underline: its bottom edge is flush with the divider's bottom edge
    // (divider is the 1px row directly below this item), so it covers the
    // divider without poking past it. Fades rather than snapping.
    Rectangle {
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        anchors.bottomMargin: -1
        width: text.implicitWidth + 32
        height: 3
        radius: 2
        color: Theme.c.onyx
        opacity: root.selected ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
