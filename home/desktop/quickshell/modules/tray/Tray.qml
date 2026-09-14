import QtQuick
import "../../theme"

// Status pill: AirPods, audio, bluetooth, wifi, battery.
// Its own surface (ivory on linen) so the group reads as one unit.
Rectangle {
    id: root
    width: 36
    height: col.implicitHeight + 16
    radius: 12
    color: Theme.c.ivory
    border.width: 1
    border.color: Theme.c.mist

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 6

        AirPods  { anchors.horizontalCenter: parent.horizontalCenter; idleColor: Theme.c.ivory }
        Launcher { anchors.horizontalCenter: parent.horizontalCenter; idleColor: Theme.c.ivory; icon: "tune";      command: ["pavucontrol"];     tooltip: "Audio mixer" }
        Launcher { anchors.horizontalCenter: parent.horizontalCenter; idleColor: Theme.c.ivory; icon: "bluetooth"; command: ["blueman-manager"]; tooltip: "Bluetooth" }
        Launcher { anchors.horizontalCenter: parent.horizontalCenter; idleColor: Theme.c.ivory; icon: "wifi";      command: ["nmgui"];           tooltip: "Wi-Fi" }
        Battery  { anchors.horizontalCenter: parent.horizontalCenter }
    }
}
