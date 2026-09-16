import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import "../../theme"
import "../../widgets"

// Wi-Fi button + popover: toggle, networks by signal, connect with password
// entry inline. Enterprise (802.1X) networks need certificates; those go
// through nmgui.
Item {
    id: root
    required property Item host          // tray's panel area
    property bool open: false
    signal requestOpen()

    implicitWidth: 28
    implicitHeight: 28

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property bool enabled: Networking.wifiEnabled
    readonly property var networks: (wifi?.networks?.values ?? [])
        .filter(n => n.name)
        .sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength))
    readonly property var current: networks.find(n => n.connected) ?? null

    // which network has the password field open
    property var pending: null
    readonly property bool wantsKeyboard: pending !== null
    property string lastFail: ""

    // scan only while the popover is open
    onOpenChanged: { if (wifi) wifi.scannerEnabled = open; if (!open) { pending = null; lastFail = ""; } }

    function isOpen(n)       { return n.security === WifiSecurityType.Open || n.security === WifiSecurityType.Owe; }
    function isEnterprise(n) { return n.security === WifiSecurityType.Wpa2Eap || n.security === WifiSecurityType.WpaEap
                                   || n.security === WifiSecurityType.Wpa3SuiteB192 || n.security === WifiSecurityType.Leap; }
    function signalGlyph(s)  { return s > 0.75 ? "signal_wifi_4_bar" : s > 0.5 ? "network_wifi_3_bar" : s > 0.25 ? "network_wifi_2_bar" : "network_wifi_1_bar"; }

    function tap(n) {
        root.lastFail = "";
        if (n.connected) { n.disconnect(); return; }
        if (n.known || root.isOpen(n)) { n.connect(); return; }
        if (root.isEnterprise(n)) { manage.running = true; root.open = false; return; }
        root.pending = (root.pending === n) ? null : n;      // open the password row
    }

    BarButton {
        anchors.fill: parent
        icon: !root.enabled ? "signal_wifi_off" : root.current ? root.signalGlyph(root.current.signalStrength) : "signal_wifi_statusbar_not_connected"
        iconColor: root.enabled ? Theme.c.onyx : Theme.c.graphite
        active: root.open
        idleColor: Theme.c.ivory
        tooltip: !root.enabled ? "Wi-Fi off" : root.current ? root.current.name : "Not connected"
        onClicked: root.open ? root.open = false : root.requestOpen()
    }

    Process { id: manage; command: ["nmgui"] }

    // content lives in the tray pill's expandable area; scrolls if taller
    Flickable {
        parent: root.host
        width: parent.width; height: parent.height
        // slides up/down toward the menu that replaced it (icon order)
        y: (2 - root.host.activeSlot) * root.host.height
        Behavior on y { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
        contentHeight: col.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: col
            width: parent.width
            spacing: 8

            // ---- toggle ---------------------------------------------------
            Item {
                width: parent.width; height: 22
                Text {
                    id: wifiTitle
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    text: "Wi-Fi"
                    color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.Medium
                }
                // rescan: bounce the scanner off and on; spins while a scan runs
                Icon {
                    anchors { left: wifiTitle.right; leftMargin: 8; verticalCenter: parent.verticalCenter }
                    visible: root.enabled
                    name: "refresh"; size: 18
                    color: rh.containsMouse ? Theme.c.onyx : Theme.c.slate
                    Behavior on color { ColorAnimation { duration: 150 } }
                    RotationAnimation on rotation { id: spin; from: 0; to: 360; duration: 700; loops: 1; running: false }
                    MouseArea {
                        id: rh; anchors.fill: parent; anchors.margins: -4; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: { if (!root.wifi) return; spin.restart(); root.wifi.scannerEnabled = false; rescan.restart(); }
                    }
                    Timer { id: rescan; interval: 150; onTriggered: if (root.wifi) root.wifi.scannerEnabled = true }
                    Tooltip { target: parent; hovered: rh.containsMouse; text: "Scan again" }
                }
                Toggle {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    checked: root.enabled
                    onToggled: (v) => Networking.wifiEnabled = v
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.c.mist }

            Text {
                visible: !root.enabled
                text: "Turn on to see networks"
                color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1
            }
            Text {
                visible: root.enabled && root.networks.length === 0
                text: "Searching…"
                color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1
            }

            // ---- networks -------------------------------------------------
            Column {
                width: parent.width
                spacing: 2
                visible: root.enabled
                Repeater {
                    model: root.networks
                    delegate: Column {
                        id: row
                        required property var modelData
                        readonly property bool busy: modelData.state === ConnectionState.Connecting || modelData.state === ConnectionState.Disconnecting
                        readonly property bool askingPw: root.pending === modelData
                        width: parent.width
                        spacing: 2

                        Rectangle {
                            width: parent.width; height: 36; radius: 8
                            color: modelData.connected ? Theme.c.sand : h.containsMouse || row.askingPw ? Theme.c.cream : Theme.c.linen
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Row {
                                anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                                spacing: 8
                                Icon { anchors.verticalCenter: parent.verticalCenter; name: row.busy ? "sync" : root.signalGlyph(modelData.signalStrength); size: 18; color: Theme.c.onyx }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text { text: modelData.name; color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1; elide: Text.ElideRight; width: 200 }
                                    Text {
                                        text: row.busy ? "Connecting…" : modelData.connected ? "Connected" : modelData.known ? "Saved" : root.isOpen(modelData) ? "Open" : root.isEnterprise(modelData) ? "Enterprise" : "Secured"
                                        color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 4
                                    }
                                }
                            }
                            Icon {
                                anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                                name: modelData.connected ? "check" : root.isOpen(modelData) ? "" : "lock"
                                size: 16; color: Theme.c.slate
                            }
                            MouseArea {
                                id: h; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: (e) => { if (e.button === Qt.RightButton) { if (modelData.known) modelData.forget(); } else root.tap(modelData); }
                            }
                            Tooltip { target: parent; hovered: h.containsMouse; text: modelData.known ? "Right-click: forget" : `Signal ${Math.round(modelData.signalStrength * 100)}%` }
                        }

                        // password row, only for the network that was tapped
                        Rectangle {
                            visible: row.askingPw
                            width: parent.width; height: 34; radius: 8
                            color: Theme.c.ivory; border.width: 1; border.color: pw.activeFocus ? Theme.c.stone : Theme.c.pebble
                            property bool reveal: false
                            TextInput {
                                id: pw
                                anchors { left: parent.left; right: eye.left; verticalCenter: parent.verticalCenter }
                                anchors.leftMargin: 10; anchors.rightMargin: 6
                                echoMode: parent.reveal ? TextInput.Normal : TextInput.Password
                                color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1
                                focus: row.askingPw
                                onVisibleChanged: if (visible) { text = ""; forceActiveFocus(); }
                                onAccepted: go.submit()
                                Text { visible: !pw.text; text: "Password"; color: Theme.c.slate; font: pw.font; anchors.verticalCenter: parent.verticalCenter }
                            }
                            Icon {
                                id: eye
                                anchors { right: go.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                name: parent.reveal ? "visibility_off" : "visibility"; size: 18
                                color: eh.containsMouse ? Theme.c.onyx : Theme.c.slate
                                MouseArea { id: eh; anchors.fill: parent; anchors.margins: -4; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: { parent.parent.reveal = !parent.parent.reveal; pw.forceActiveFocus(); } }
                            }
                            Icon {
                                id: go
                                anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                name: "arrow_forward"; size: 18
                                color: pw.text.length >= 8 ? Theme.c.onyx : Theme.c.pebble
                                function submit() { if (pw.text.length >= 8) { modelData.connectWithPsk(pw.text); root.pending = null; } }
                                MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor; onClicked: go.submit() }
                            }
                        }
                    }
                }
            }

            Text {
                visible: root.lastFail !== ""
                width: parent.width; wrapMode: Text.WordWrap
                text: root.lastFail
                color: Theme.c.clay; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 3
            }

            Rectangle { width: parent.width; height: 1; color: Theme.c.mist }

            Text {
                text: "Advanced (nmgui)…"
                color: mh.containsMouse ? Theme.c.onyx : Theme.c.slate
                font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2
                MouseArea { id: mh; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { manage.running = true; root.open = false; } }
            }
        }
    }
}
