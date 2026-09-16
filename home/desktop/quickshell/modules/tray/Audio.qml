import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../../theme"
import "../../widgets"

// Audio button + popover: output volume/mute, output device picker, mic.
// Reads/writes Pipewire directly; pavucontrol stays reachable at the bottom.
Item {
    id: root
    required property Item host          // tray's panel area
    property bool open: false
    signal requestOpen()

    implicitWidth: 28
    implicitHeight: 28

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    // nodes must be tracked to get live property updates
    PwObjectTracker { objects: [root.sink, root.source].filter(n => n) }

    // Outputs from one card all start with the card name ("Meteor Lake-P HD
    // Audio Controller Speaker"). Drop the longest prefix common to all of
    // them so the list reads "Speaker", "HDMI / DisplayPort 1 Output", …
    readonly property var outputs: [...Pipewire.nodes.values].filter(n => n.isSink && !n.isStream && n.audio)
    readonly property string commonPrefix: {
        const names = outputs.map(n => n.description || n.nickname || n.name);
        if (names.length < 2) return "";
        let p = names[0];
        for (const n of names) { while (p && !n.startsWith(p)) p = p.slice(0, -1); }
        return p.slice(0, p.lastIndexOf(" ") + 1);      // cut at a word boundary
    }
    function shortName(n) {
        const full = n.description || n.nickname || n.name;
        const cut = commonPrefix && full.startsWith(commonPrefix) ? full.slice(commonPrefix.length) : full;
        return cut.replace(/ Output$/, "") || full;
    }

    readonly property real vol: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property string glyph: muted || vol === 0 ? "volume_off" : vol < 0.5 ? "volume_down" : "volume_up"

    BarButton {
        anchors.fill: parent
        icon: root.glyph
        active: root.open
        idleColor: Theme.c.ivory
        tooltip: root.muted ? "Muted" : `Volume ${Math.round(root.vol * 100)}%`
        onClicked: root.open ? root.open = false : root.requestOpen()
    }

    Process { id: manage; command: ["pavucontrol"] }

    // content lives in the tray pill's expandable area; scrolls if taller
    Flickable {
        parent: root.host
        width: parent.width; height: parent.height
        // slides up/down toward the menu that replaced it (icon order)
        y: (0 - root.host.activeSlot) * root.host.height
        Behavior on y { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
        contentHeight: col.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: col
            width: parent.width
            spacing: 10

            // ---- output --------------------------------------------------
            AudioLevel {
                width: parent.width
                title: root.sink ? root.shortName(root.sink) : "No output"
                node: root.sink
                icon: root.glyph
            }

            // output device picker (only when there is a choice)
            Column {
                width: parent.width
                spacing: 2
                visible: sinks.count > 1
                Repeater {
                    id: sinks
                    model: ScriptModel { values: root.outputs }
                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool current: modelData === root.sink
                        width: parent.width; height: 30; radius: 8
                        color: current ? Theme.c.sand : h.containsMouse ? Theme.c.cream : Theme.c.linen
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Row {
                            anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                            spacing: 8
                            Icon { name: current ? "check" : "speaker"; size: 16; color: Theme.c.onyx; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: root.shortName(modelData); color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1; elide: Text.ElideRight; width: 240 }
                        }
                        MouseArea { id: h; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Pipewire.preferredDefaultAudioSink = modelData }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.c.mist }

            // ---- input ---------------------------------------------------
            AudioLevel {
                width: parent.width
                title: root.source?.description ?? "No microphone"
                node: root.source
                icon: (root.source?.audio?.muted ?? true) ? "mic_off" : "mic"
            }

            Rectangle { width: parent.width; height: 1; color: Theme.c.mist }

            // ---- manage --------------------------------------------------
            Text {
                text: "Open mixer…"
                color: mh.containsMouse ? Theme.c.onyx : Theme.c.slate
                font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2
                MouseArea { id: mh; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { manage.running = true; root.open = false; } }
            }
        }
    }
}
