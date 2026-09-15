import QtQuick
import Quickshell.Io
import "../../../theme"
import "../../../widgets"

// Current conditions from Open-Meteo (no API key). Polls every 15 minutes.
// Location is a plain property; change it here.
Card {
    id: root
    property real latitude: 51.48      // Halle (Saale)
    property real longitude: 11.97

    property real temperature: NaN
    property int code: -1
    property bool isDay: true
    property int rainChance: -1        // % for the current hour
    property bool failed: false

    // WMO weather codes -> Material Symbols glyph + label
    function describe(c, day) {
        if (c === 0)              return { icon: day ? "sunny" : "clear_night", label: "Clear" };
        if (c <= 2)               return { icon: day ? "partly_cloudy_day" : "partly_cloudy_night", label: "Partly cloudy" };
        if (c === 3)              return { icon: "cloud", label: "Overcast" };
        if (c === 45 || c === 48) return { icon: "foggy", label: "Fog" };
        if (c <= 57)              return { icon: "rainy_light", label: "Drizzle" };
        if (c <= 67)              return { icon: "rainy", label: "Rain" };
        if (c <= 77)              return { icon: "weather_snowy", label: "Snow" };
        if (c <= 82)              return { icon: "rainy_heavy", label: "Showers" };
        if (c <= 86)              return { icon: "weather_snowy", label: "Snow showers" };
        return                           { icon: "thunderstorm", label: "Thunderstorm" };
    }
    readonly property var now: describe(code, isDay)

    Process {
        id: fetch
        command: ["curl", "-sf", "--max-time", "8",
            `https://api.open-meteo.com/v1/forecast?latitude=${root.latitude}&longitude=${root.longitude}` +
            `&current=temperature_2m,weather_code,is_day&hourly=precipitation_probability&forecast_days=1&timezone=auto`]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const j = JSON.parse(text);
                    root.temperature = j.current.temperature_2m;
                    root.code = j.current.weather_code;
                    root.isDay = j.current.is_day === 1;
                    // hourly array is indexed by hour of today; current.time is "YYYY-MM-DDTHH:MM"
                    const i = j.hourly.time.indexOf(j.current.time.slice(0, 13) + ":00");
                    root.rainChance = i >= 0 ? j.hourly.precipitation_probability[i] : -1;
                    root.failed = false;
                } catch (e) { root.failed = true; }
            }
        }
    }
    Timer { interval: 15 * 60 * 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: fetch.running = true }

    // Text is the anchor (centred on the card); the icon hangs off its left.
    // `iconGap` moves only the icon.
    property int iconGap: 16

    Icon {
        anchors { right: textCol.left; rightMargin: root.iconGap; verticalCenter: textCol.verticalCenter }
        name: root.code < 0 ? "cloud" : root.now.icon
        size: 34
        color: Theme.c.onyx
    }
    Column {
            id: textCol
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 12   // text right of centre so icon+text balance as a group
            spacing: 0
            // temperature with the rain chance tucked beside it, smaller and
            // sitting on the baseline
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4
                Text {
                    id: temp
                    text: root.failed ? "—" : isNaN(root.temperature) ? "…" : Math.round(root.temperature) + "°"
                    color: Theme.c.onyx
                    font.family: Theme.fontFamily
                    font.pixelSize: 24
                    font.weight: Font.Medium
                }
                // Both are Text, so they can share the temperature's baseline
                // exactly instead of guessing with margins.
                Icon {
                    anchors.baseline: temp.baseline
                    anchors.baselineOffset: 2     // glyph has no descender; nudge it down to the digits
                    visible: root.rainChance >= 0
                    name: "water_drop"; size: 12; color: Theme.c.slate
                }
                Text {
                    anchors.baseline: temp.baseline
                    visible: root.rainChance >= 0
                    text: root.rainChance + "%"
                    color: Theme.c.slate
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.failed ? "Offline" : root.code < 0 ? "Loading" : root.now.label
                color: Theme.c.charcoal
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
            }
    }
}
