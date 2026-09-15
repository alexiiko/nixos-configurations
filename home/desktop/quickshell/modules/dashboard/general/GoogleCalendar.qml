import QtQuick
import Quickshell.Io
import "../../../theme"
import "../../../widgets"

// Day timeline for `date`: events placed by time, in their Google colours,
// with a now-line when the day is today. Data from gcal-day (JSON).
Card {
    id: root
    property date date: new Date()
    padding: 10

    property var events: []
    property bool loading: false
    property bool failed: false
    property string error: ""

    readonly property string dayArg: Qt.formatDate(date, "yyyy-MM-dd")
    readonly property bool isToday: Qt.formatDate(new Date(), "yyyy-MM-dd") === dayArg
    readonly property real hourH: 44                     // px per hour
    readonly property real gutter: 30                    // hour labels

    // ---- fetching (pinned per day; stale results dropped) ------------------
    property bool pending: false
    property string inflight: ""
    function refresh() {
        if (fetch.running) { pending = true; return; }
        inflight = dayArg; loading = true; fetch.running = true;
    }
    onDayArgChanged: { events = []; refresh(); }
    Timer { interval: root.failed ? 20 * 1000 : 5 * 60 * 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }

    Process {
        id: fetch
        command: ["gcal-day", root.inflight]
        stdout: StdioCollector { id: out }
        stderr: StdioCollector { id: err }
        onExited: (code) => {
            console.log(`gcal-day ${root.inflight}: exit ${code}`, code !== 0 ? err.text.trim().slice(0, 200) : "");
            if (root.inflight !== root.dayArg) { root.pending = false; root.refresh(); return; }
            root.loading = false;
            if (code !== 0) {
                root.failed = true; root.error = err.text.trim(); root.events = [];
            } else {
                try { root.events = JSON.parse(out.text).events; root.failed = false; }
                catch (e) { root.failed = true; root.error = "bad JSON"; root.events = []; }
                if (!root.failed) root.scrollToNow();
            }
            if (root.pending) { root.pending = false; root.refresh(); }
        }
    }

    // ---- now line ---------------------------------------------------------
    property int nowMin: { const d = new Date(); return d.getHours() * 60 + d.getMinutes(); }
    Timer { interval: 60000; running: true; repeat: true; onTriggered: root.nowMin = (() => { const d = new Date(); return d.getHours() * 60 + d.getMinutes(); })() }

    function scrollToNow() {
        if (!root.isToday) { flick.contentY = 8 * root.hourH; return; }   // other days: open at 08:00
        const y = root.nowMin / 60 * root.hourH - flick.height / 3;
        flick.contentY = Math.max(0, Math.min(y, flick.contentHeight - flick.height));
    }

    Column {
        anchors.fill: parent
        spacing: 4

        Row {
            width: parent.width
            spacing: 6
            Text {
                text: root.isToday ? "Today" : Qt.formatDate(root.date, "ddd d MMM")
                color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.Medium
            }
            Icon { anchors.verticalCenter: parent.verticalCenter; name: "sync"; size: 14; color: Theme.c.pebble; visible: root.loading }
        }

        Text {
            visible: root.failed
            width: parent.width; wrapMode: Text.WordWrap
            text: root.error.includes("authenticated") ? "Not connected.\nRun `gcalcli init` once." : "Calendar unavailable"
            color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2
        }

        Flickable {
            id: flick
            width: parent.width
            height: parent.height - y
            contentHeight: 24 * root.hourH
            clip: true
            visible: !root.failed
            boundsBehavior: Flickable.StopAtBounds

            // hour grid
            Repeater {
                model: 24
                delegate: Item {
                    required property int index
                    y: index * root.hourH; width: flick.width; height: root.hourH
                    Text {
                        x: 0; y: -6
                        text: (index < 10 ? "0" : "") + index
                        color: Theme.c.pebble; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 4
                    }
                    Rectangle { x: root.gutter; y: 0; width: parent.width - root.gutter; height: 1; color: Theme.c.mist }
                }
            }

            // events
            Repeater {
                model: root.events
                delegate: Rectangle {
                    required property var modelData
                    x: root.gutter + 2
                    width: flick.width - root.gutter - 2
                    y: modelData.startMin / 60 * root.hourH + 1
                    height: Math.max(14, (modelData.endMin - modelData.startMin) / 60 * root.hourH - 2)
                    radius: 6
                    color: Qt.alpha(modelData.color, 0.22)
                    Rectangle {   // solid stripe in the event colour
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        width: 3; radius: 2
                        color: modelData.color
                    }
                    Column {
                        anchors { left: parent.left; right: parent.right; top: parent.top }
                        anchors.leftMargin: 8; anchors.rightMargin: 4; anchors.topMargin: 2
                        clip: true; height: parent.height - 4
                        Text {
                            width: parent.width; elide: Text.ElideRight
                            text: modelData.title
                            color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 3; font.weight: Font.Medium
                        }
                        Text {
                            visible: parent.height > 26
                            text: modelData.allDay ? "All day" : modelData.start + " – " + modelData.end
                            color: Theme.c.charcoal; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 4
                        }
                    }
                }
            }

            // now line (today only)
            Item {
                visible: root.isToday
                x: root.gutter - 4; width: flick.width - root.gutter + 4
                y: root.nowMin / 60 * root.hourH
                z: 10
                Rectangle { anchors { left: parent.left; right: parent.right; verticalCenter: parent.top } height: 2; color: Theme.c.clay }
                Rectangle { x: 0; y: -4; width: 8; height: 8; radius: 4; color: Theme.c.clay }
            }
        }
    }
}
