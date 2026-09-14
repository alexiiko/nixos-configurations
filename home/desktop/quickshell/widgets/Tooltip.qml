import QtQuick
import Quickshell
import "../theme"

// Hover tooltip that pops out to the right of `target` after a short delay.
// Anchors via the attached QsWindow, so any bar item can own one.
Item {
    id: root
    required property Item target
    property string text: ""
    property bool hovered: false

    Timer {
        id: delay
        interval: 450
        running: root.hovered && root.text !== ""
        onTriggered: {
            // Resolve at show time: at construction the target isn't in a
            // window yet, and a null anchor.window pins the popup to 0,0.
            popup.anchor.window = root.target.QsWindow.window;
            popup.anchor.item = root.target;
            popup.visible = true;
        }
    }
    onHoveredChanged: if (!hovered) popup.visible = false

    PopupWindow {
        id: popup
        anchor {
            edges: Edges.Right
            gravity: Edges.Right
            margins.left: 10
        }
        visible: false
        implicitWidth: label.implicitWidth + 20
        implicitHeight: label.implicitHeight + 12
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: Theme.c.onyx
            Text {
                id: label
                anchors.centerIn: parent
                text: root.text
                color: Theme.c.ivory
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
            }
        }
    }
}
