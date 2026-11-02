import QtQuick
import "../theme"

// Glass tile (iOS-style): translucent fill, soft top sheen, highlight rim,
// big radius. Content goes in the default property; `padding` insets it.
// Callers can still override color/border (e.g. make it fully transparent).
Rectangle {
    id: root
    default property alias content: inner.data
    property int padding: 14
    property int rightPadding: padding

    radius: 22
    color: Theme.glass(Theme.c.ivory)
    border.width: 1
    border.color: Theme.glassRim

    // gradient fade across the box — wanted on the general tab's cards, off
    // on the media tab's flat boxes (and never over a transparent card)
    property bool sheen: true
    Rectangle {
        visible: root.sheen && root.color.a > 0.01
        anchors.fill: parent
        radius: parent.radius
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1AFFFFFF" }
            GradientStop { position: 0.45; color: "#00FFFFFF" }
            GradientStop { position: 1.0; color: "#0D000000" }
        }
    }

    Item {
        id: inner
        anchors.fill: parent
        anchors.margins: root.padding
        anchors.rightMargin: root.rightPadding
    }
}
