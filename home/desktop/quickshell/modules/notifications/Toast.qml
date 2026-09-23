import QtQuick
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import "../../theme"
import "../../widgets"
import "../../services"

// One notification popup. Click anywhere dismisses; action buttons invoke.
// A progress line along the bottom shows the time left; hovering pauses it.
Rectangle {
    id: root
    required property Notification n

    width: 340
    readonly property real fullHeight: content.implicitHeight + 24 + (lifetime > 0 ? 6 : 0)
    property real slot: 1              // 1 = full slot, 0 = collapsed; the wrapper reads it
    height: fullHeight
    radius: 14
    color: Theme.c.ivory
    border.width: 1
    border.color: n.urgency === NotificationUrgency.Critical ? Theme.c.clay : Theme.c.mist
    clip: true

    readonly property int lifetime: Notifications.timeoutFor(n)

    // --- fly in / out ---------------------------------------------------------
    // The model is a plain array that gets replaced wholesale, so ListView
    // add/remove transitions never fire. The toast animates itself instead and
    // only closes the notification once it has left the screen.
    property real off: travel
    readonly property int travel: 420
    transform: Translate { x: root.off }
    Component.onCompleted: flyIn.start()
    NumberAnimation { id: flyIn; target: root; property: "off"; to: 0; duration: 340; easing.type: Easing.OutCubic }
    // fly out and give up the slot at the same time, so the toast below rises
    // smoothly instead of jumping once this one is removed
    SequentialAnimation {
        id: flyOut
        ParallelAnimation {
            NumberAnimation { target: root; property: "off"; to: root.travel; duration: 300; easing.type: Easing.InCubic }
            SequentialAnimation {
                PauseAnimation { duration: 140 }
                NumberAnimation { target: root; property: "slot"; to: 0; duration: 220; easing.type: Easing.OutCubic }
            }
        }
        ScriptAction { script: root.pending ? root.pending() : root.n.expire() }
    }
    property var pending: null
    function leave(action) { pending = action ?? null; flyOut.start(); }
    readonly property bool whatsapp: Notifications.isWhatsapp(n)

    // Sender-provided image (avatars etc.) or a glyph by app name. Icon
    // *names* are ignored on purpose: notify-send ships a placeholder
    // bitmap when it cannot resolve one, which is what the magenta square was.
    readonly property bool hasImage: n.image !== ""
    readonly property string glyph: {
        const a = n.appName.toLowerCase();
        if (a.includes("battery"))  return "battery_alert";
        if (n.urgency === NotificationUrgency.Critical) return "priority_high";
        if (a.includes("pomodoro")) return "timer";
        if (a.includes("calendar")) return "event";
        if (a.includes("whatsapp")) return "chat";
        if (a.includes("claude"))   return "smart_toy";
        if (a.includes("screenshot")) return "photo_camera";
        if (a.includes("airpods") || a.includes("bluetooth")) return "bluetooth";
        return "notifications";
    }

    // --- lifetime -------------------------------------------------------------
    // The progress line IS the clock: the toast expires when it reaches zero.
    // Hovering pauses it. Inset by the corner radius with rounded ends so it
    // stays inside the card's curve (clip is rectangular and would not help).
    HoverHandler { id: hover }
    Rectangle {
        visible: root.lifetime > 0
        anchors { left: parent.left; bottom: parent.bottom }
        anchors.leftMargin: root.radius; anchors.bottomMargin: 5
        height: 3
        radius: height / 2
        color: root.whatsapp ? Theme.c.onyx : Theme.c.pebble
        width: root.width - 2 * root.radius
        NumberAnimation on width {
            from: root.width - 2 * root.radius; to: 0
            duration: root.lifetime
            running: root.lifetime > 0
            paused: running && hover.hovered
            onFinished: root.leave()
        }
    }

    // --- open the app for WhatsApp: chromium's own action does not reach a
    //     window parked on a special workspace, so we bring it forward ourselves
    function open() {
        if (root.whatsapp) {
            Notifications.clearWhatsapp();
            Hyprland.dispatch("focuswindow class:^(chrome-web\\\\.whatsapp\\\\.com.*)$");
        }
        const n = root.n;
        root.leave(() => {
            for (const a of n.actions) if (a.identifier === "default") a.invoke();
            n.dismiss();
        });
    }

    Column {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top }
        anchors.margins: 12
        spacing: 6

        Row {
            width: parent.width
            spacing: 10

            Item {
                width: 28; height: 28
                anchors.verticalCenter: parent.verticalCenter
                ClippingRectangle {          // rounds the avatar
                    anchors.fill: parent
                    radius: 8
                    color: "transparent"
                    visible: root.hasImage
                    Image {
                        anchors.fill: parent
                        source: root.hasImage ? root.n.image : ""
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(56, 56)
                    }
                }
                Icon {
                    anchors.centerIn: parent
                    visible: !root.hasImage
                    name: root.glyph
                    size: 22
                    color: root.n.urgency === NotificationUrgency.Critical ? Theme.c.clay : Theme.c.onyx
                }
            }

            Column {
                width: parent.width - 38
                spacing: 2
                Text {
                    width: parent.width; elide: Text.ElideRight
                    text: root.n.summary
                    color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.DemiBold
                }
                Text {
                    width: parent.width
                    visible: text !== ""
                    text: root.n.body.replace(/^\s*<a[^>]*>web\.whatsapp\.com<\/a>\s*/, "")
                    textFormat: Text.StyledText
                    wrapMode: Text.WordWrap; maximumLineCount: 4; elide: Text.ElideRight
                    color: Theme.c.charcoal; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1
                }
                Text {
                    text: root.whatsapp ? "WhatsApp" : root.n.appName
                    visible: text !== ""
                    color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 3
                }
            }
        }

        // non-default actions as buttons (default is the click on the card)
        Row {
            readonly property var shown: root.n.actions.filter(a => a.identifier !== "default" && !(root.whatsapp && a.text === "Settings"))
            visible: shown.length > 0
            spacing: 6
            Repeater {
                model: parent.shown
                delegate: Rectangle {
                    required property var modelData
                    width: aLabel.implicitWidth + 20; height: 24; radius: 7
                    color: aH.containsMouse ? Theme.c.sand : Theme.c.linen
                    Text { id: aLabel; anchors.centerIn: parent; text: modelData.text; color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2 }
                    MouseArea { id: aH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: { if (root.whatsapp) { Notifications.clearWhatsapp(); Hyprland.dispatch("focuswindow class:^(chrome-web\\\\.whatsapp\\\\.com.*)$"); } modelData.invoke(); } }
                }
            }
        }
    }

    // left click = open (default action) ; right click = just dismiss
    MouseArea {
        anchors.fill: parent
        z: -1
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: (e) => e.button === Qt.RightButton ? root.leave(() => root.n.dismiss()) : root.open()
    }
}
