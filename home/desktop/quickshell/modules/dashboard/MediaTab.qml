import QtQuick
import QtQuick.Layouts
import "media"

// Visualizer on top; volume bar + MPRIS player below.
ColumnLayout {
    id: root
    property bool active: false      // dashboard open and this tab showing
    spacing: 8

    Visualizer { Layout.fillWidth: true; Layout.fillHeight: true; active: root.active }
    RowLayout {
        Layout.fillWidth: true; Layout.fillHeight: false; Layout.preferredHeight: 150; Layout.maximumHeight: 150   // nested layouts default to fillHeight
        spacing: 12
        VolumeBar { Layout.fillHeight: true }
        Player    { Layout.fillWidth: true; Layout.fillHeight: true; Layout.topMargin: 4 }
    }
}
