import QtQuick
import QtQuick.Layouts
import "../../theme"
import "general"

// Row 1: weather | uptime | pomodoro     (equal thirds)
// Row 2: clock   | month calendar | google calendar
ColumnLayout {
    spacing: 12

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: false      // nested Layouts default to fill; pin row 1
        Layout.preferredHeight: 84
        Layout.minimumHeight: 84
        Layout.maximumHeight: 84
        spacing: 12
        Weather  { Layout.fillWidth: true; Layout.fillHeight: true }
        Uptime   { Layout.fillWidth: true; Layout.fillHeight: true }
        Pomodoro { Layout.fillWidth: true; Layout.fillHeight: true }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 12
        ClockDate      { id: clock; Layout.preferredWidth: 100; Layout.fillHeight: true }
        MonthCalendar  { id: cal; Layout.fillWidth: true; Layout.fillHeight: true; onRefreshed: clock.refresh() }
        GoogleCalendar { Layout.preferredWidth: 190; Layout.fillHeight: true; date: cal.selected }
    }
}
