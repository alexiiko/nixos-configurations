import QtQuick
import Quickshell.Io
import "../../../theme"
import "../../../widgets"

// Pomodoro. The icon is the only control: click starts/pauses. A finished
// phase notifies and arms the next one, but never starts it by itself.
// Hovering shows a pen that opens the duration editor in place.
Card {
    id: root

    property int focusMinutes: 50
    property int restMinutes: 15

    property bool onRest: false
    property bool running: false
    property bool editing: false
    property int remaining: focusMinutes * 60

    function phaseLength() { return (onRest ? restMinutes : focusMinutes) * 60; }
    function reset() { running = false; onRest = false; remaining = phaseLength(); }
    function phaseDone() {
        running = false;
        onRest = !onRest;
        remaining = phaseLength();
        notify.running = true;
    }
    // editing a duration while idle re-arms the current phase to the new length
    onFocusMinutesChanged: if (!running && !onRest) remaining = phaseLength()
    onRestMinutesChanged:  if (!running &&  onRest) remaining = phaseLength()

    Timer {
        interval: 1000; running: root.running; repeat: true
        onTriggered: { if (root.remaining > 1) root.remaining--; else root.phaseDone(); }
    }
    Process {
        id: notify
        command: ["notify-send", "-a", "Pomodoro",
                  root.onRest ? "Focus done" : "Rest done",
                  root.onRest ? "Time to rest. Press play when ready." : "Back to focus. Press play when ready."]
    }

    // MM:SS
    readonly property string clock: {
        const m = Math.floor(remaining / 60), s = remaining % 60;
        return `${m}:${s.toString().padStart(2, "0")}`;
    }
    // pause while running; play when paused mid-phase; coffee when rest is
    // armed but not started; the stopwatch only once a full cycle is done.
    readonly property bool started: remaining < phaseLength()
    readonly property string stateIcon: running ? "pause"
                                      : started ? "play_arrow"
                                      : onRest  ? "coffee"
                                      : "timer"

    // --- timer view ---------------------------------------------------------
    Row {
        anchors.centerIn: parent
        spacing: 12
        visible: !root.editing

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.stateIcon
            size: 30
            filled: root.running || root.started
            color: playHover.containsMouse ? Theme.c.onyx : Theme.c.obsidian
            Behavior on color { ColorAnimation { duration: 150 } }
            MouseArea { id: playHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.running = !root.running }
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: 96      // fixed so the row doesn't shift when the label changes
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.clock; color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: 22; font.weight: Font.Medium }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.running ? (root.onRest ? "Rest" : "Focus")
                    : root.started ? (root.onRest ? "Rest · paused" : "Focus · paused")
                    : root.onRest  ? "Rest · ready" : "Focus"
                color: Theme.c.charcoal; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1
            }
        }
    }

    // --- editor view --------------------------------------------------------
    Column {
        anchors.centerIn: parent
        spacing: 6
        visible: root.editing

        Stepper { label: "Focus"; value: root.focusMinutes; step: 1; min: 1;  onChanged: v => root.focusMinutes = v }
        Stepper { label: "Rest";  value: root.restMinutes;  step: 1; min: 1;  onChanged: v => root.restMinutes = v }
    }

    // --- pen / done, top-right, fades in on hover ---------------------------
    HoverHandler { id: cardHover }
    Icon {
        anchors { top: parent.top; right: parent.right }
        anchors.topMargin: -4; anchors.rightMargin: -4
        name: root.editing ? "check" : "edit"
        size: 18
        color: penHover.containsMouse ? Theme.c.onyx : Theme.c.slate
        opacity: root.editing || cardHover.hovered ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 180 } }
        Behavior on color   { ColorAnimation  { duration: 150 } }
        MouseArea {
            id: penHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: root.editing = !root.editing
        }
    }

    // reset lives in the editor so the timer face stays a single control
    Text {
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        anchors.bottomMargin: -6
        visible: root.editing
        text: "reset"
        color: resetHover.containsMouse ? Theme.c.onyx : Theme.c.slate
        font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 3
        MouseArea { id: resetHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.reset(); root.editing = false; } }
    }
}
