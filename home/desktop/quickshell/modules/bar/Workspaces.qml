import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../theme"

// Existing workspaces, sorted by id, focused one filled. Mirrors waybar's
// hyprland/workspaces: only workspaces that exist are shown, click focuses.
// Monochrome: state is carried by fill and text weight, not colour.
Column {
    id: root
    spacing: 6

    readonly property var sorted: [...Hyprland.workspaces.values]
        .filter(w => w.id > 0)               // drop special/scratch workspaces
        .sort((a, b) => a.id - b.id)

    Repeater {
        model: root.sorted

        delegate: Rectangle {
            id: pill
            required property var modelData
            readonly property bool focused: modelData.focused
            readonly property bool urgent: modelData.urgent
            readonly property bool hovered: mouse.containsMouse

            width: 28
            height: 28
            radius: 8
            anchors.horizontalCenter: parent.horizontalCenter

            color: focused ? Theme.c.onyx
                 : urgent  ? Theme.c.clay
                 : hovered ? Theme.c.sand
                 : Theme.c.linen     // bar bg, not "transparent": that is black@0 and
                                     // the animation would pass through it
            border.width: focused || urgent ? 0 : 1
            border.color: hovered ? Theme.c.cement : Theme.c.pebble

            Behavior on color        { ColorAnimation { duration: 200 } }
            Behavior on border.color { ColorAnimation { duration: 200 } }

            Text {
                anchors.centerIn: parent
                text: pill.modelData.id
                color: pill.focused || pill.urgent ? Theme.c.ivory
                     : pill.hovered ? Theme.c.onyx
                     : Theme.c.charcoal
                Behavior on color { ColorAnimation { duration: 200 } }
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: pill.focused ? Font.DemiBold : Font.Normal
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: pill.modelData.activate()
            }
        }
    }
}
