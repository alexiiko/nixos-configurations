import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../theme"

// Top-centre dashboard. Same auto-hide as the sidebar (see Bar.qml for the
// hover/mask reasoning), sliding down from the top edge.
PanelWindow {
    id: root

    property bool revealed: false
    property int currentTab: 0
    readonly property int hideDelay: 150
    readonly property int triggerHeight: 6

    anchors { top: true }           // top only: layer-shell centres it horizontally
    implicitWidth: 680
    implicitHeight: 470
    exclusiveZone: 0
    aboveWindows: true
    color: "transparent"

    mask: Region { item: root.revealed ? surface : trigger }

    Item {
        id: trigger; x: 0; y: 0; width: parent.width; height: root.triggerHeight
        HoverHandler { id: triggerHover }
    }

    readonly property bool wantVisible: triggerHover.hovered || surfaceHover.hovered
    onWantVisibleChanged: {
        if (wantVisible) { hideTimer.stop(); revealed = true; }
        else hideTimer.restart();
    }
    Timer { id: hideTimer; interval: root.hideDelay; onTriggered: root.revealed = false }

    Rectangle {
        id: surface
        width: root.width
        height: root.height
        y: root.revealed ? 0 : -height
        Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        color: Theme.c.linen
        bottomLeftRadius: 14
        bottomRightRadius: 14
        clip: true                 // content can never draw outside the panel

        HoverHandler { id: surfaceHover }

        // --- tab header ---------------------------------------------------
        RowLayout {
            id: tabs
            anchors { top: parent.top; left: parent.left; right: parent.right }
            anchors.topMargin: 14
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            spacing: 0

            Repeater {
                model: [
                    { label: "General", icon: "dashboard" },
                    { label: "Media",   icon: "queue_music" },
                    { label: "Performance", icon: "speed" },
                ]
                delegate: TabButton {
                    required property int index
                    required property var modelData
                    Layout.fillWidth: true
                    label: modelData.label
                    icon: modelData.icon
                    selected: root.currentTab === index
                    onClicked: root.currentTab = index
                }
            }
        }

        Rectangle {
            id: divider
            anchors { top: tabs.bottom; left: parent.left; right: parent.right }
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            height: 1
            color: Theme.c.silverBirch
        }

        // --- tab content ------------------------------------------------
        Item {
            anchors { top: divider.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
            anchors.margins: 16

            GeneralTab { anchors.fill: parent; opacity: root.currentTab === 0 ? 1 : 0; visible: opacity > 0; Behavior on opacity { NumberAnimation { duration: 180 } } }
            MediaTab   { anchors.fill: parent; active: root.revealed && root.currentTab === 1; opacity: root.currentTab === 1 ? 1 : 0; visible: opacity > 0; Behavior on opacity { NumberAnimation { duration: 180 } } }
            PerformanceTab { anchors.fill: parent; opacity: root.currentTab === 2 ? 1 : 0; visible: opacity > 0; Behavior on opacity { NumberAnimation { duration: 180 } } }
        }
    }
}
