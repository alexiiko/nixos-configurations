import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import "../../../theme"
import "../../../widgets"

// MPRIS player: one tab per running player (browser, YouTube Music, ...),
// art + title + transport + seek bar for the selected one.
Card {
    color: "transparent"; border.width: 0
    id: root
    padding: 12

    readonly property var players: (soloist.uri !== "" ? [soloist] : []).concat(Mpris.players.values)
    property int selected: 0
    readonly property var player: players[Math.min(selected, players.length - 1)] ?? null
    // prefer whatever is playing when the selection is stale, but never
    // steal the Soloist tab while it has a track: the other players (e.g.
    // Spotifast) claim "playing" with dead metadata and freeze the line
    onPlayersChanged: {
        const i = players.findIndex(p => p.isPlaying);
        if (i >= 0 && !(players[selected]?.isPlaying) && !(soloist.uri !== "" && selected === 0)) selected = i;
    }

    // playback changes outside the UI (earbud gesture, phone): land on the
    // Soloist tab so the line and transport are never stale
    Connections {
        target: root.soloist
        function onIsPlayingChanged() { if (root.soloist.isPlaying) root.selected = 0; }
    }

    // MPRIS raise() is a no-op for browsers under Wayland; focus the window
    // ourselves: the one whose title carries the track, else by app id.
    function focusWindow(p) {
        const tops = Hyprland.toplevels.values;
        const names = [p.identity, p.desktopEntry].filter(n => n).map(n => n.toLowerCase());
        const win = (p.trackTitle && tops.find(t => t.title.includes(p.trackTitle)))
                 || tops.find(t => names.some(n => (t.wayland?.appId ?? "").toLowerCase().includes(n)));
        if (win) {
            // quickshell strips the 0x hyprland wants; warp off just for this
            // focus so the cursor stays on the dashboard
            Quickshell.execDetached(["hyprctl", "--batch",
                `keyword cursor:no_warps true; dispatch focuswindow address:0x${win.address}; keyword cursor:no_warps false`]);
        }
        else if (p.canRaise) p.raise();
    }

    function fmt(s) {
        s = Math.max(0, Math.round(s));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    // position only updates on demand; tick while playing
    Timer {
        interval: 500; repeat: true
        running: root.player?.isPlaying ?? false
        onTriggered: root.player.positionChanged()
    }

    // ---- Soloist adapter ------------------------------------------------
    // Soloist is the Connect receiver that actually plays (spotifast#283)
    // and exposes no MPRIS, so its state is polled and adapted into the
    // same player shape; it shows up as the first tab like any player.
    readonly property var soloist: QtObject {
        property string identity: "Soloist"
        readonly property string desktopEntry: ""
        property string uri: ""
        property string trackTitle: ""
        property string trackArtist: ""
        property string trackArtUrl: ""
        property bool isPlaying: false
        property real position: 0
        property real length: 0
        readonly property bool lengthSupported: true
        readonly property bool canGoNext: true
        readonly property bool canGoPrevious: true
        readonly property bool canTogglePlaying: true
        readonly property bool canSeek: true
        readonly property bool canRaise: false

        property real _lastPos: 0
        property bool _fromPoll: false
        function raise() {}
        function togglePlaying() { root.ctl(isPlaying ? "pause" : "play"); }
        function next() { root.ctl("next"); }
        function previous() { if (position > 3) root.ctl("seek", "0"); else root.ctl("prev"); }

        function _parse(t) {
            try {
                const d = JSON.parse(t);
                _fromPoll = true;
                uri = d.item?.uri ?? "";
                trackTitle = d.item?.decorations?.identity?.name ?? "";
                trackArtist = (d.item?.creators ?? []).map(c => c.entity?.decorations?.identity?.name).filter(n => n).join(", ");
                const covers = d.item?.decorations?.visual_identity?.cover ?? [];
                trackArtUrl = (covers.find(c => c.size === "default") ?? covers[0])?.url ?? "";
                isPlaying = d.status === "playing";
                length = (d.item?.decorations?.playback?.duration_ms ?? 0) / 1000;
                position = (d.position?.position_ms ?? 0) / 1000;
                _lastPos = position;
                _fromPoll = false;
            } catch (e) { uri = ""; }   // soloist not running: hide the tab
        }

        // the seek bar assigns position; ignore poll updates and the
        // positionChanged() re-read that MPRIS players need every tick
        onPositionChanged: {
            if (_fromPoll || Math.abs(position - _lastPos) < 0.25) return;
            _lastPos = position;
            root.ctl("seek", String(Math.round(position * 1000)));
        }
    }

    Process {
        id: soloistPoll
        command: ["soloist", "ctl", "now", "--json"]
        stdout: StdioCollector { onStreamFinished: root.soloist._parse(text) }
    }
    Process { id: soloistCmd }
    function ctl(...args) { soloistCmd.command = ["soloist", "ctl", ...args]; soloistCmd.running = true; }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: soloistPoll.running = true }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // ---- player tabs ------------------------------------------------
        Row {
            spacing: 6
            Layout.fillWidth: true
            Repeater {
                model: root.players
                Rectangle {
                    required property var modelData
                    required property int index
                    readonly property bool on: index === root.selected
                    width: tabText.implicitWidth + 20; height: 24; radius: 12
                    color: on ? Theme.c.sand : tabArea.containsMouse ? Theme.c.cream : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text {
                        id: tabText
                        anchors.centerIn: parent
                        text: modelData.identity || "Player"
                        color: parent.on ? Theme.c.onyx : Theme.c.basalt
                        font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2
                    }
                    MouseArea { id: tabArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.selected = index; root.focusWindow(modelData) } }
                }
            }
            Text {
                visible: root.players.length === 0
                text: "Nothing playing"
                color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
            }
        }

        // ---- track -----------------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12
            visible: root.player !== null

            Rectangle {
                id: art
                Layout.preferredWidth: 64; Layout.preferredHeight: 64
                radius: 8; color: Theme.c.cream
                // clip is rectangular; round the image through a mask
                Image {
                    anchors.fill: parent
                    source: root.player?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                    layer.enabled: true
                    layer.effect: MultiEffect { maskEnabled: true; maskSource: artMask }
                }
                Item {
                    id: artMask
                    anchors.fill: parent; visible: false
                    layer.enabled: true
                    Rectangle { anchors.fill: parent; radius: art.radius }
                }
                Icon { anchors.centerIn: parent; name: "music_note"; size: 28; color: Theme.c.slate; visible: !(root.player?.trackArtUrl) }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    Layout.fillWidth: true
                    text: root.player?.trackTitle || "Unknown title"
                    elide: Text.ElideRight
                    color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize + 1; font.bold: true
                }
                Text {
                    Layout.fillWidth: true
                    text: root.player?.trackArtist || ""
                    elide: Text.ElideRight
                    color: Theme.c.basalt; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1
                }
            }

            // transport
            Row {
                spacing: 4
                Layout.alignment: Qt.AlignVCenter
                BarButton { anchors.verticalCenter: parent.verticalCenter; icon: "skip_previous"; enabled: root.player?.canGoPrevious ?? false; iconColor: enabled ? Theme.c.onyx : Theme.c.pebble; onClicked: root.player.previous() }
                BarButton {
                    width: 36; height: 36; radius: 18
                    icon: root.player?.isPlaying ? "pause" : "play_arrow"; filled: true
                    enabled: root.player?.canTogglePlaying ?? false
                    onClicked: root.player.togglePlaying()
                }
                BarButton { anchors.verticalCenter: parent.verticalCenter; icon: "skip_next"; enabled: root.player?.canGoNext ?? false; iconColor: enabled ? Theme.c.onyx : Theme.c.pebble; onClicked: root.player.next() }
            }
        }

        // ---- seek --------------------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: root.player !== null && (root.player?.lengthSupported ?? false)
            Text { text: root.fmt(root.player?.position ?? 0); color: Theme.c.basalt; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2 }
            Slider {
                Layout.fillWidth: true
                value: (root.player?.length ?? 0) > 0 ? (root.player?.position ?? 0) / root.player.length : 0
                enabled: root.player?.canSeek ?? false
                onMoved: v => root.player.position = v * root.player.length
            }
            Text { text: "-" + root.fmt((root.player?.length ?? 0) - (root.player?.position ?? 0)); color: Theme.c.basalt; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2 }
        }
    }
}
