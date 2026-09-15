import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../theme"
import "../../widgets"

// App launcher. Bottom-centre, same auto-hide as the dashboard but sliding
// up. Search box on top, alphabetical app list below, scrollable.
// Grabs the keyboard only while revealed, so typing goes to the search box.
PanelWindow {
    id: root

    property bool revealed: false
    property bool pinned: false            // opened by keybind: stays until closed
    readonly property int hideDelay: 150
    readonly property int triggerHeight: 6
    property string query: ""

    // `qs ipc call launcher toggle` (bound to Super+Space)
    IpcHandler {
        target: "launcher"
        function toggle(): void { root.pinned = !root.pinned; }
        function open(): void { root.pinned = true; }
        function close(): void { root.pinned = false; }
    }

    anchors { bottom: true }
    implicitWidth: 520
    implicitHeight: 440
    exclusiveZone: 0
    aboveWindows: true
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: revealed ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    mask: Region { item: root.revealed ? surface : trigger }

    Item {
        id: trigger; x: 0; y: parent.height - root.triggerHeight; width: parent.width; height: root.triggerHeight
        HoverHandler { id: triggerHover }
    }

    // stays while hovered or while a search is typed
    readonly property bool wantVisible: pinned || triggerHover.hovered || surfaceHover.hovered || query !== ""
    onWantVisibleChanged: {
        if (wantVisible) { hideTimer.stop(); revealed = true; }
        else hideTimer.restart();
    }
    Timer { id: hideTimer; interval: root.hideDelay; onTriggered: root.revealed = false }
    onRevealedChanged: {
        if (revealed) { search.text = ""; search.forceActiveFocus(); list.contentY = 0; }
    }

    // ---- data -------------------------------------------------------------
    readonly property var apps: [...DesktopEntries.applications.values]
        .filter(a => !a.noDisplay)
        .sort((a, b) => a.name.localeCompare(b.name, undefined, { sensitivity: "base" }))
    readonly property var shown: {
        const q = query.trim().toLowerCase();
        if (!q) return apps;
        return apps.filter(a => a.name.toLowerCase().includes(q)
                             || (a.genericName ?? "").toLowerCase().includes(q)
                             || (a.keywords ?? []).some(k => k.toLowerCase().includes(q)));
    }
    function launch(app) {
        // Terminal=true entries (btop, htop…) need a terminal; execute() ignores that flag
        if (app.runInTerminal) Quickshell.execDetached(["kitty", "-e", ...app.command]);
        else app.execute();
        root.query = ""; root.pinned = false; root.revealed = false;
    }

    Rectangle {
        id: surface
        width: root.width
        height: root.height
        y: root.revealed ? 0 : height
        Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        color: Theme.c.linen
        border.width: 1
        border.color: Theme.c.mist
        topLeftRadius: 14
        topRightRadius: 14
        clip: true

        HoverHandler { id: surfaceHover }

        // ---- search ----------------------------------------------------
        Rectangle {
            id: searchBox
            anchors { top: parent.top; left: parent.left; right: parent.right }
            anchors.margins: 14
            height: 40
            radius: 10
            color: Theme.c.ivory
            border.width: 1
            border.color: search.activeFocus ? Theme.c.stone : Theme.c.pebble

            Icon { id: sIcon; anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter } name: "search"; size: 20; color: Theme.c.slate }
            TextInput {
                id: search
                anchors { left: sIcon.right; right: parent.right; verticalCenter: parent.verticalCenter }
                anchors.leftMargin: 10; anchors.rightMargin: 12
                color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize + 1
                selectionColor: Theme.c.sand; selectedTextColor: Theme.c.onyx
                onTextChanged: { root.query = text; list.contentY = 0; list.currentIndex = 0; }
                onAccepted: if (root.shown.length > 0) root.launch(root.shown[Math.max(0, Math.min(list.currentIndex, root.shown.length - 1))])
                Keys.onEscapePressed: { if (text) text = ""; else { root.pinned = false; root.revealed = false; } }
                Keys.onDownPressed: list.incrementCurrentIndex()
                Keys.onUpPressed: list.decrementCurrentIndex()
                Text { visible: !search.text; text: "Search apps"; color: Theme.c.slate; font: search.font; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        // ---- list --------------------------------------------------------
        ListView {
            id: list
            anchors { top: searchBox.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
            anchors.margins: 14; anchors.topMargin: 10
            clip: true
            model: root.shown
            spacing: 2
            boundsBehavior: Flickable.StopAtBounds
            currentIndex: 0
            keyNavigationEnabled: false
            highlightMoveDuration: 0
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

            delegate: Rectangle {
                required property var modelData
                required property int index
                width: list.width; height: 44; radius: 10
                readonly property bool current: list.currentIndex === index && search.activeFocus
                color: current ? Theme.c.sand : h.containsMouse ? Theme.c.cream : Theme.c.linen
                Behavior on color { ColorAnimation { duration: 100 } }

                Row {
                    anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                    spacing: 12
                    Item {
                        width: 26; height: 26; anchors.verticalCenter: parent.verticalCenter
                        Image {
                            id: appIcon
                            anchors.fill: parent
                            source: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""
                            sourceSize: Qt.size(52, 52)
                            fillMode: Image.PreserveAspectFit
                            visible: status === Image.Ready
                        }
                        Icon { anchors.centerIn: parent; visible: appIcon.status !== Image.Ready; name: "apps"; size: 22; color: Theme.c.slate }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Text { text: modelData.name; color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; elide: Text.ElideRight; width: 430 }
                        Text {
                            visible: text !== ""
                            text: modelData.genericName || modelData.comment || ""
                            color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 3; elide: Text.ElideRight; width: 430
                        }
                    }
                }
                MouseArea { id: h; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.launch(modelData) }
            }

            Text {
                visible: root.shown.length === 0
                anchors.centerIn: parent
                text: "No matches"
                color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
            }
        }
    }
}
