import QtQuick
import Quickshell
import Quickshell.Io

// Notifies `leadMinutes` before each of today's calendar events. Independent
// of the dashboard: refetches today every 10 minutes and checks once a
// minute, so it works with the dashboard hidden and picks up new events.
Scope {
    id: root
    property int leadMinutes: 30

    property string today: Qt.formatDate(new Date(), "yyyy-MM-dd")
    property var notified: ({})          // "title@startMin" -> true, reset daily
    readonly property var events: Calendar.eventsFor(today)

    Component.onCompleted: Calendar.request(today)
    Timer { interval: 10 * 60 * 1000; running: true; repeat: true; onTriggered: Calendar.request(root.today) }

    Process { id: notify }

    function check() {
        const d = new Date();
        const day = Qt.formatDate(d, "yyyy-MM-dd");
        if (day !== root.today) { root.today = day; root.notified = {}; Calendar.request(day); return; }
        const now = d.getHours() * 60 + d.getMinutes();

        for (const e of root.events) {
            if (e.allDay) continue;
            const key = `${e.title}@${e.startMin}`;
            const lead = e.startMin - now;
            // window rather than exact match, so a late tick can't skip it
            if (lead <= root.leadMinutes && lead > root.leadMinutes - 5 && !root.notified[key]) {
                root.notified[key] = true;
                notify.command = ["notify-send", "-a", "Calendar",
                                  `In ${lead} min: ${e.title}`, `${e.start} – ${e.end}`];
                notify.running = true;
            }
        }
    }
    Timer { interval: 60 * 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.check() }
    onEventsChanged: check()
}
