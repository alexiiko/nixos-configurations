import QtQuick
import Quickshell.Services.Pipewire
import "../../theme"
import "../../widgets"

// Title, mute button, slider, percentage — one audio node.
Column {
    id: root
    property string title
    property var node
    property string icon: "volume_up"
    readonly property bool has: node !== null && node !== undefined && node.audio
    spacing: 4

    Text {
        width: parent.width; elide: Text.ElideRight
        text: root.title
        color: Theme.c.charcoal; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2
    }
    Row {
        width: parent.width
        spacing: 8
        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.icon; size: 20
            color: root.has && root.node.audio.muted ? Theme.c.slate : Theme.c.onyx
            MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor
                onClicked: if (root.has) root.node.audio.muted = !root.node.audio.muted }
        }
        Slider {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 20 - 8 - 40 - 8
            value: root.has ? root.node.audio.volume : 0
            enabled: root.has && !root.node.audio.muted
            onMoved: (v) => { if (root.has) { root.node.audio.volume = v; if (root.node.audio.muted && v > 0) root.node.audio.muted = false; } }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: 40; horizontalAlignment: Text.AlignRight
            text: root.has ? Math.round(root.node.audio.volume * 100) + "%" : "—"
            color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1
        }
    }
}
