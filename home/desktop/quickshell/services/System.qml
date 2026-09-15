pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// CPU / memory / storage / power-mode readings for the Performance tab.
// Everything is read from /proc and /sys; nothing is polled faster than 2 s.
Singleton {
    id: root

    // --- cpu usage: delta of /proc/stat's first line ------------------------
    property real cpuUsage: 0            // 0..1
    property var _prev: null
    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            const f = text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = f[3] + f[4], total = f.reduce((a, b) => a + b, 0);
            if (root._prev) {
                const dt = total - root._prev.total, di = idle - root._prev.idle;
                if (dt > 0) root.cpuUsage = Math.max(0, Math.min(1, 1 - di / dt));
            }
            root._prev = { idle, total };
        }
    }

    // --- cpu temp: coretemp package sensor, resolved by hwmon name ----------
    property int cpuTemp: 0              // °C
    Process {
        id: temp
        command: ["sh", "-c", "for h in /sys/class/hwmon/hwmon*; do [ \"$(cat $h/name 2>/dev/null)\" = coretemp ] && cat $h/temp1_input && break; done"]
        stdout: StdioCollector { onStreamFinished: { const v = parseInt(text); if (!isNaN(v)) root.cpuTemp = Math.round(v / 1000); } }
    }

    // --- memory -----------------------------------------------------------------
    property real memTotal: 0            // bytes
    property real memUsed: 0
    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: {
            const kb = (k) => parseInt((text().match(new RegExp(`^${k}:\\s+(\\d+)`, "m")) ?? [0, 0])[1]) * 1024;
            root.memTotal = kb("MemTotal");
            root.memUsed = root.memTotal - kb("MemAvailable");
        }
    }

    // --- storage (root fs) ------------------------------------------------------
    property real diskTotal: 0
    property real diskUsed: 0
    Process {
        id: disk
        command: ["df", "-B1", "--output=used,size", "/"]
        stdout: StdioCollector { onStreamFinished: {
            const l = text.trim().split("\n").pop().trim().split(/\s+/).map(Number);
            if (l.length === 2) { root.diskUsed = l[0]; root.diskTotal = l[1]; }
        } }
    }

    // --- power / fan profile ----------------------------------------------------
    readonly property var modes: ["low-power", "quiet", "balanced", "performance"]
    property string mode: "balanced"
    FileView {
        id: profile
        path: "/sys/firmware/acpi/platform_profile"
        onLoaded: root.mode = text().trim()
    }
    Process { id: setMode }
    function setPowerMode(m) {
        if (!modes.includes(m)) return;
        setMode.command = ["sudo", "-n", "set-power-mode", m];
        setMode.running = true;
        root.mode = m;                  // optimistic; re-read confirms
        confirm.restart();
    }
    Timer { id: confirm; interval: 600; onTriggered: profile.reload() }

    // --- polling ----------------------------------------------------------------
    Timer { interval: 2000;  running: true; repeat: true; triggeredOnStart: true; onTriggered: { stat.reload(); temp.running = true; } }
    Timer { interval: 5000;  running: true; repeat: true; triggeredOnStart: true; onTriggered: { meminfo.reload(); profile.reload(); } }
    Timer { interval: 60000; running: true; repeat: true; triggeredOnStart: true; onTriggered: disk.running = true }

    function gib(bytes) { return (bytes / 1073741824).toFixed(1); }
}
