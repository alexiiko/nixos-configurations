import QtQuick
import "../../../theme"
import "../../../widgets"

import "../../../services"

// Big clock with the date underneath. Ticks on the minute. Hovering shows
// a blue-light-filter toggle above the hour (hyprsunset does the filtering
// and its own 20:00/06:00 schedule; this just overrides by hand).
Card {
    id: root
    property date now: new Date()
    function refresh() { now = new Date(); }

    readonly property bool night: NightLight.on

    HoverHandler { id: hover }
    BarButton {
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 6 }
        icon: root.night ? "nightlight" : "wb_sunny"
        filled: root.night
        idleColor: Theme.c.ivory
        tooltip: root.night ? "Blue light filter on" : "Blue light filter off"
        opacity: hover.hovered ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
        onClicked: NightLight.toggle()
    }

    Timer {
        interval: 60000 - (Date.now() % 60000); running: true; repeat: false
        onTriggered: { root.now = new Date(); tick.start(); }
    }
    Timer { id: tick; interval: 60000; repeat: true; onTriggered: root.now = new Date() }

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
