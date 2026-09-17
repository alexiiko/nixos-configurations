import QtQuick
import "../../../theme"
import "../../../services"
import "../../../widgets"

// Month grid, Monday-first. Today is a filled onyx pill; days outside the
// month are dimmed. Arrows step months; the title click returns to today.
Card {
    id: root
    padding: 12

    property date today: new Date()
    property date selected: today           // the day whose events the gcal card shows
    property int year: today.getFullYear()
    property int month: today.getMonth()   // 0-11

    function goToday() {
        today = new Date();
        year = today.getFullYear(); month = today.getMonth(); selected = today;
        Calendar.refresh(Qt.formatDate(today, "yyyy-MM-dd"));
    }
    function select(d) {
        selected = d;
        if (d.getMonth() !== month || d.getFullYear() !== year) { year = d.getFullYear(); month = d.getMonth(); }
    }
    function step(n) {
        const d = new Date(year, month + n, 1);
        year = d.getFullYear(); month = d.getMonth();
    }

    // 42 cells (6 weeks) starting on the Monday on/before the 1st
    readonly property var cells: {
        const first = new Date(year, month, 1);
        const offset = (first.getDay() + 6) % 7;          // Mon=0 … Sun=6
        const start = new Date(year, month, 1 - offset);
        const out = [];
        for (let i = 0; i < 42; i++) {
            const d = new Date(start.getFullYear(), start.getMonth(), start.getDate() + i);
            const same = (a, b) => a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
            out.push({
                date: d,
                day: d.getDate(),
                inMonth: d.getMonth() === month,
                isToday: same(d, today),
                isSelected: same(d, selected),
            });
        }
        return out;
    }

    Timer { interval: 60 * 60 * 1000; running: true; repeat: true; onTriggered: root.today = new Date() }

    Column {
        anchors.fill: parent
        spacing: 4

        // header: ‹ Month YYYY ›
        Item {
            width: parent.width; height: 24
            Icon {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                name: "chevron_left"; size: 20; color: prevH.containsMouse ? Theme.c.onyx : Theme.c.slate
                MouseArea { id: prevH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.step(-1) }
            }
            Row {
                anchors.centerIn: parent
                spacing: 8
                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "today"; size: 18
                    color: todayH.containsMouse ? Theme.c.onyx : Theme.c.slate
                    Behavior on color { ColorAnimation { duration: 150 } }
                    MouseArea { id: todayH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.goToday() }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatDate(new Date(root.year, root.month, 1), "MMMM yyyy")
                    color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.Medium
                }
            }
            Icon {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                name: "chevron_right"; size: 20; color: nextH.containsMouse ? Theme.c.onyx : Theme.c.slate
                MouseArea { id: nextH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.step(1) }
            }
        }

        // weekday row
        Grid {
            columns: 7; width: parent.width
            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                delegate: Item {
                    required property string modelData
                    width: parent.width / 7; height: 18
                    Text { anchors.centerIn: parent; text: modelData; color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 3 }
                }
            }
        }

        // day grid
        Grid {
            id: days
            columns: 7; width: parent.width
            readonly property real cell: width / 7
            readonly property real rowH: (root.height - 2 * root.padding - 24 - 18 - 12) / 6
            Repeater {
                model: root.cells
                delegate: Item {
                    required property var modelData
                    width: days.cell; height: days.rowH
                    Rectangle {
                        anchors.centerIn: parent
                        width: 24; height: 24; radius: 7
                        // today = filled; selected = ring; hover = light fill
                        color: modelData.isToday ? Theme.c.onyx
                             : dayH.containsMouse ? Theme.c.sand
                             : Theme.c.ivory
                        border.width: modelData.isSelected && !modelData.isToday ? 1.5 : 0
                        border.color: Theme.c.onyx
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text {
                            anchors.centerIn: parent
                            text: modelData.day
                            color: modelData.isToday ? Theme.c.ivory : modelData.inMonth ? Theme.c.onyx : Theme.c.pebble
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 2
                            font.weight: modelData.isToday || modelData.isSelected ? Font.DemiBold : Font.Normal
                        }
                        MouseArea { id: dayH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.select(modelData.date) }
                    }
                }
            }
        }
    }
}
