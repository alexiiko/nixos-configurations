import QtQuick
import "../../../theme"
import "../../../widgets"

// "Label  −  25 min  +"  — steppers instead of a text field, which needs
// keyboard focus on a layer surface and is fiddly to get right.
// Press-and-hold repeats: one step, a short pause, then fast.
Row {
    id: root
    property string label
    property int value
    property int step: 1
    property int min: 1
    property int max: 180
    signal changed(int v)

    spacing: 8

    function bump(dir) { root.changed(Math.min(root.max, Math.max(root.min, root.value + dir * root.step))); }

    component HoldButton: Icon {
        id: btn
        property int dir: 1
        size: 18
        color: area.containsMouse ? Theme.c.onyx : Theme.c.slate
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            id: area
            anchors.fill: parent
            anchors.margins: -4          // easier to hit / hold
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onPressed: { root.bump(btn.dir); initial.restart(); }
            onReleased: { initial.stop(); repeat.stop(); }
            onCanceled: { initial.stop(); repeat.stop(); }
        }
        Timer { id: initial; interval: 400; onTriggered: repeat.start() }
        Timer { id: repeat;  interval: 70; repeat: true; onTriggered: root.bump(btn.dir) }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        width: 44
        text: root.label
        color: Theme.c.charcoal; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1
    }
    HoldButton { name: "remove"; dir: -1 }
    Text {
        anchors.verticalCenter: parent.verticalCenter
        width: 56; horizontalAlignment: Text.AlignHCenter
        text: root.value + " min"
        color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.Medium
    }
    HoldButton { name: "add"; dir: 1 }
}
