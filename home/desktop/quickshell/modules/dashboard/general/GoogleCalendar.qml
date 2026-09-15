import QtQuick
import Quickshell.Io
import "../../../theme"
import "../../../widgets"

// Events for `date`, via the gcal-day wrapper around gcalcli. Refetches on
// date change and every 5 minutes. Shows a setup hint until gcalcli is
// authenticated (the wrapper exits non-zero then).
Card {
    id: root
    property date date: new Date()

    property var events: []          // [{start, end, title, calendar}]
    property bool loading: false
    property bool failed: false
    property string error: ""

    readonly property string dayArg: Qt.formatDate(date, "yyyy-MM-dd")
    readonly property bool isToday: Qt.formatDate(new Date(), "yyyy-MM-dd") === dayArg

    function refresh() { if (!fetch.running) { loading = true; fetch.running = true; } }
    onDayArgChanged: refresh()
    Timer { interval: 5 * 60 * 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }

    Process {
        id: fetch
        command: ["gcal-day", root.dayArg]
        stdout: StdioCollector { id: out }
        stderr: StdioCollector { id: err }
        onExited: (code) => {
            root.loading = false;
            if (code !== 0) { root.failed = true; root.error = err.text.trim().split("\n").pop() ?? ""; root.events = []; return; }
            root.failed = false;
            root.events = root.parse(out.text);
        }
    }

    // TSV from gcalcli. Column order is fixed by gcal-day's --details:
    // start_date start_time end_date end_time title calendar. A header row
    // may or may not be present depending on version; skip it if it is.
    function parse(text) {
        const rows = [];
        for (const line of text.split("\n")) {
            if (!line.trim()) continue;
            const c = line.split("\t");
            if (c[0] === "start_date") continue;
            if (c.length < 5) continue;
            const allDay = !c[1];
            rows.push({
                start: allDay ? "" : c[1],
                end:   allDay ? "" : c[3],
                allDay,
                title: c[4] || "(no title)",
                calendar: c[5] || "",
            });
        }
        return rows;
    }

    Column {
        anchors.fill: parent
        spacing: 6

        // header: "Today" or "Wed 17 Sep"
        Row {
            width: parent.width
            Text {
                text: root.isToday ? "Today" : Qt.formatDate(root.date, "ddd d MMM")
                color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.Medium
            }
            Item { width: 6; height: 1 }
            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: "sync"; size: 14; color: Theme.c.pebble
                visible: root.loading
            }
        }

        // states
        Text {
            visible: root.failed
            width: parent.width; wrapMode: Text.WordWrap
            text: root.error.includes("init") || root.error.includes("auth") || root.error.includes("credentials")
                  ? "Not connected.\nRun `gcalcli init` once."
                  : "Calendar unavailable"
            color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2
        }
        Text {
            visible: !root.failed && !root.loading && root.events.length === 0
            text: "No events"
            color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1
        }

        // events
        Flickable {
            id: list
            width: parent.width
            height: parent.height - y
            contentHeight: col.implicitHeight
            clip: true
            visible: !root.failed && root.events.length > 0
            Column {
                id: col
                width: list.width
                spacing: 6
                Repeater {
                    model: root.events
                    delegate: Item {
                        required property var modelData
                        width: col.width
                        height: 34
                        Rectangle {
                            anchors.fill: parent; radius: 8
                            color: Theme.c.linen
                        }
                        Rectangle {   // left accent stripe
                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                            anchors.margins: 6; anchors.leftMargin: 6
                            width: 3; radius: 2
                            color: Theme.c.onyx
                        }
                        Column {
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                            anchors.leftMargin: 16; anchors.rightMargin: 8
                            spacing: 1
                            Text {
                                width: parent.width; elide: Text.ElideRight
                                text: modelData.title
                                color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1; font.weight: Font.Medium
                            }
                            Text {
                                text: modelData.allDay ? "All day" : modelData.start + " – " + modelData.end
                                color: Theme.c.charcoal; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 3
                            }
                        }
                    }
                }
            }
        }
    }
}
