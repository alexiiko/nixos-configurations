import QtQuick
import Quickshell.Io
import "../../theme"
import "../../widgets"
import "../../services"

// Screen brightness button + slider. Reads the backlight from sysfs (watched,
// so the Fn keys keep it in sync), writes through brightnessctl.
Item {
    id: root
    required property Item host
    property bool open: false
    signal requestOpen()

    implicitWidth: 28
    implicitHeight: 28

    readonly property string dev: "/sys/class/backlight/intel_backlight"
    FileView { id: cur; path: root.dev + "/brightness"; watchChanges: true; onFileChanged: reload() }
    FileView { id: max; path: root.dev + "/max_brightness" }
    readonly property real level: Number(max.text()) > 0 ? Number(cur.text()) / Number(max.text()) : 0
    readonly property string glyph: level < 0.34 ? "brightness_5" : level < 0.67 ? "brightness_6" : "brightness_7"   // sun-with-rays set; brightness_low/high look like cogs

    Process { id: setter }
    function set(v) {
        setter.command = ["brightnessctl", "-q", "set", Math.round(Math.max(0.01, Math.min(1, v)) * 100) + "%"];
        setter.running = true;
    }

    BarButton {
        anchors.fill: parent
        icon: root.glyph
        active: root.open
        idleColor: Theme.c.ivory
        tooltip: `Brightness ${Math.round(root.level * 100)}%`
        onClicked: root.open ? root.open = false : root.requestOpen()
    }

    Column {
        parent: root.host
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
        opacity: root.open ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 180 } }
        spacing: 4

        Text {
            text: "Brightness"
            color: Theme.c.charcoal; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2
        }
        Row {
            width: parent.width
            spacing: 8
            Icon { anchors.verticalCenter: parent.verticalCenter; name: root.glyph; size: 20; color: Theme.c.onyx }
            Slider {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 20 - 8 - 40 - 8
                value: root.level
                onMoved: v => root.set(v)
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 40; horizontalAlignment: Text.AlignRight
                text: Math.round(root.level * 100) + "%"
                color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1
            }
        }

        Item { width: 1; height: 8 }

        // ---- blue light filter ------------------------------------------
        Row {
            width: parent.width
            Text {
                width: parent.width - 40
                anchors.verticalCenter: parent.verticalCenter
                text: "Blue light filter"
                color: Theme.c.charcoal; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2
            }
            Toggle { anchors.verticalCenter: parent.verticalCenter; checked: NightLight.on; onToggled: NightLight.toggle() }
        }
        Row {
            width: parent.width
            spacing: 8
            Icon { anchors.verticalCenter: parent.verticalCenter; name: "nightlight"; size: 20; color: NightLight.on ? Theme.c.onyx : Theme.c.slate }
            Slider {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 20 - 8 - 40 - 8
                value: NightLight.strength
                enabled: NightLight.on
                onMoved: v => NightLight.setStrength(v)
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 40; horizontalAlignment: Text.AlignRight
                text: NightLight.temperature + "K"
                color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2
            }
        }
    }
}
