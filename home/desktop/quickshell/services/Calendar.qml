pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// One source of calendar data for everything: the dashboard card, the
// sidebar popover, the reminders. Caches events per day, fetches one day
// at a time through a queue, refreshes cached days every 5 minutes.
Singleton {
    id: root

    property var days: ({})              // "YYYY-MM-DD" -> [events]
    property var loadingDays: ({})       // "YYYY-MM-DD" -> true while in flight
    property bool failed: false
    property string error: ""

    function eventsFor(day) { return days[day] ?? []; }
    function isLoading(day) { return loadingDays[day] === true; }

    // ---- queue ------------------------------------------------------------
    property var queue: []
    property string inflight: ""

    function request(day) {
        if (inflight === day || queue.includes(day)) return;
        queue = [...queue, day];
        loadingDays = Object.assign({}, loadingDays, { [day]: true });
        pump();
    }
    function refresh(day) { request(day); }     // alias, reads better at call sites
    function pump() {
        if (fetch.running || queue.length === 0) return;
        inflight = queue[0]; queue = queue.slice(1);
        fetch.running = true;
    }

    Process {
        id: fetch
        command: ["gcal-day", root.inflight]
        stdout: StdioCollector { id: out }
        stderr: StdioCollector { id: err }
        onExited: (code) => {
            const day = root.inflight;
            console.log(`gcal-day ${day}: exit ${code}`, code !== 0 ? err.text.trim().slice(0, 200) : "");
            const l = Object.assign({}, root.loadingDays); delete l[day]; root.loadingDays = l;
            if (code !== 0) { root.failed = true; root.error = err.text.trim(); }
            else {
                try { root.days = Object.assign({}, root.days, { [day]: JSON.parse(out.text).events }); root.failed = false; }
                catch (e) { root.failed = true; root.error = "bad JSON"; }
            }
            root.inflight = "";
            root.pump();
        }
    }

    // periodic refresh of whatever is cached; 20 s retry while failing
    Timer {
        interval: root.failed ? 20 * 1000 : 5 * 60 * 1000
        running: true; repeat: true
        onTriggered: { for (const d of Object.keys(root.days)) root.request(d); }
    }
}
