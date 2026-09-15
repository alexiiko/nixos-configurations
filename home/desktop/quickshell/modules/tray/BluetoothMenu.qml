import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import "../../theme"
import "../../widgets"

// Bluetooth button + popover: adapter toggle, paired devices with
// connect/disconnect and battery. Pairing new devices stays in blueman.
Item {
    id: root
    required property Item host          // tray's panel area
    property bool open: false
    signal requestOpen()

    implicitWidth: 28
    implicitHeight: 28

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter?.enabled ?? false
    readonly property var devices: [...Bluetooth.devices.values]
        .filter(d => d.paired || d.connected)
        .sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))
    readonly property int connectedCount: devices.filter(d => d.connected).length

    // unpaired devices seen by the scanner; nameless ones are noise
    readonly property bool scanning: adapter?.discovering ?? false
    readonly property var found: [...Bluetooth.devices.values]
        .filter(d => !d.paired && !d.connected && d.deviceName)       // no broadcast name = address noise
        .sort((a, b) => a.deviceName.localeCompare(b.deviceName))
    function setScanning(on) { if (root.adapter) root.adapter.discovering = on; }
    // scanning only while the popover is open; it costs radio time
    onOpenChanged: if (!open) setScanning(false)

    BarButton {
        anchors.fill: parent
        icon: root.powered ? (root.connectedCount > 0 ? "bluetooth_connected" : "bluetooth") : "bluetooth_disabled"
        iconColor: root.powered ? Theme.c.onyx : Theme.c.graphite
        active: root.open
        idleColor: Theme.c.ivory
        tooltip: !root.powered ? "Bluetooth off" : root.connectedCount === 0 ? "Bluetooth" : `${root.connectedCount} connected`
        onClicked: root.open ? root.open = false : root.requestOpen()
    }

    Process { id: manage; command: ["blueman-manager"] }

    // content lives in the tray pill's expandable area; scrolls if taller
    Flickable {
        parent: root.host
        anchors.fill: parent
        opacity: root.open ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 180 } }
        contentHeight: col.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: col
            width: parent.width
            spacing: 8

            // ---- adapter toggle ---------------------------------------
            Item {
                width: parent.width; height: 22
                Text {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    text: "Bluetooth"
                    color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.Medium
                }
                Toggle {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    checked: root.powered
                    onToggled: (v) => { if (root.adapter) root.adapter.enabled = v; }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.c.mist }

            // ---- devices ------------------------------------------------
            Text {
                visible: root.powered && root.devices.length === 0
                text: "No paired devices"
                color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1
            }
            Text {
                visible: !root.powered
                text: "Turn on to see devices"
                color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1
            }
            Column {
                width: parent.width
                spacing: 2
                visible: root.powered
                Repeater {
                    model: root.devices
                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool busy: modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting
                        width: parent.width; height: 36; radius: 8
                        color: modelData.connected ? Theme.c.sand : h.containsMouse ? Theme.c.cream : Theme.c.linen
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Row {
                            anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                            spacing: 8
                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: busy ? "sync" : deviceGlyph(modelData.icon)
                                size: 18; color: Theme.c.onyx
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Text { text: modelData.name; color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1; elide: Text.ElideRight; width: 170 }
                                Text {
                                    text: busy ? "Working…" : modelData.connected ? "Connected" : "Not connected"
                                    color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 4
                                }
                            }
                        }
                        // battery, when the device reports it
                        Text {
                            visible: modelData.connected && modelData.batteryAvailable
                            anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                            text: Math.round(modelData.battery * 100) + "%"
                            color: Theme.c.charcoal; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2
                        }
                        // left: connect/disconnect · right: forget (unpair)
                        MouseArea {
                            id: h; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: (e) => {
                                if (e.button === Qt.RightButton) { modelData.forget(); return; }
                                if (busy) return;
                                if (modelData.connected) modelData.disconnect(); else modelData.connect();
                            }
                        }
                        Tooltip { target: parent; hovered: h.containsMouse; text: "Click: " + (modelData.connected ? "disconnect" : "connect") + "\nRight-click: forget" }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.c.mist }

            // ---- pairing ----------------------------------------------
            Item {
                width: parent.width; height: 22
                visible: root.powered
                Text {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    text: root.scanning ? "Searching…" : "Pair new device"
                    color: Theme.c.charcoal; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2
                }
                Toggle {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    checked: root.scanning
                    onToggled: (v) => root.setScanning(v)
                }
            }
            Column {
                width: parent.width
                spacing: 2
                visible: root.powered && root.scanning
                Text {
                    visible: root.found.length === 0
                    text: "Nothing nearby yet — put the device in pairing mode"
                    color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 3
                    width: parent.width; wrapMode: Text.WordWrap
                }
                Repeater {
                    model: root.found
                    delegate: Rectangle {
                        required property var modelData
                        width: parent.width; height: 32; radius: 8
                        color: fh.containsMouse ? Theme.c.cream : Theme.c.linen
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Row {
                            anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                            spacing: 8
                            Icon { anchors.verticalCenter: parent.verticalCenter; name: modelData.pairing ? "sync" : deviceGlyph(modelData.icon); size: 18; color: Theme.c.onyx }
                            Text { anchors.verticalCenter: parent.verticalCenter; text: modelData.deviceName; color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1; elide: Text.ElideRight; width: 180 }
                        }
                        Text {
                            anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                            text: modelData.pairing ? "Pairing…" : "Pair"
                            color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 3
                        }
                        MouseArea {
                            id: fh; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: { if (modelData.pairing) modelData.cancelPair(); else modelData.pair(); }
                        }
                    }
                }
            }

            // devices that ask for a PIN need an agent to answer; that lives in blueman
            Text {
                visible: root.powered && root.scanning
                text: "Device wants a PIN? Use blueman…"
                color: mh.containsMouse ? Theme.c.onyx : Theme.c.pebble
                font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 4
                MouseArea { id: mh; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { manage.running = true; root.open = false; } }
            }
        }
    }

    // BlueZ icon names -> Material glyphs
    function deviceGlyph(i) {
        i = (i ?? "").toLowerCase();
        if (i.includes("headset") || i.includes("headphone")) return "headphones";
        if (i.includes("audio")) return "speaker";
        if (i.includes("phone")) return "smartphone";
        if (i.includes("keyboard")) return "keyboard";
        if (i.includes("mouse")) return "mouse";
        if (i.includes("computer")) return "laptop";
        return "bluetooth";
    }
}
