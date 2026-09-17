import QtQuick
import Quickshell
import Quickshell.Io
import "../../../theme"
import "../../../widgets"

import "../../../services"

// Big clock with the date underneath. Ticks on the minute. Hovering shows
// a blue-light-filter toggle above the hour (hyprsunset does the filtering
// and its own 20:00/06:00 schedule; this just overrides by hand).
Card {
    id: root
    SystemClock { id: clock; precision: SystemClock.Minutes }
    readonly property date now: clock.date

    readonly property bool night: NightLight.on

    HoverHandler { id: hover }
    Process { id: themeCmd; command: ["theme", "toggle"] }
    Row {
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 6 }
        spacing: 4
        opacity: hover.hovered ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        BarButton {
            icon: Theme.mode === "dark" ? "dark_mode" : "light_mode"
            filled: Theme.mode === "dark"
            idleColor: Theme.c.ivory
            tooltip: Theme.mode === "dark" ? "Turn dark mode off" : "Turn dark mode on"
            onClicked: themeCmd.running = true
        }
        BarButton {
            icon: "wb_twilight"           // sun on the horizon: the warm filter
            filled: root.night
            idleColor: Theme.c.ivory
            tooltip: root.night ? "Turn blue light filter off" : "Turn blue light filter on"
            onClicked: NightLight.toggle()
        }
    }


    Column {
        anchors.centerIn: parent
        spacing: 6
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(root.now, "HH")
            color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: 34; font.weight: Font.Medium
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(root.now, "mm")
            color: Theme.c.charcoal; font.family: Theme.fontFamily; font.pixelSize: 34
        }
        Rectangle { width: 24; height: 1; color: Theme.c.silverBirch; anchors.horizontalCenter: parent.horizontalCenter }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.now, "ddd")
            color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.Medium
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.now, "d MMM")
            color: Theme.c.charcoal; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1
        }
    }
}
