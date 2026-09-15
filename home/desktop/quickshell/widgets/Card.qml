import QtQuick
import "../theme"

// Dashboard tile: ivory surface, hairline border, rounded. Content goes in
// the default property; `padding` insets it.
Rectangle {
    id: root
    default property alias content: inner.data
    property int padding: 14
    property int rightPadding: padding

    radius: 14
    color: Theme.c.ivory
    border.width: 1
    border.color: Theme.c.mist

    Item {
        id: inner
        anchors.fill: parent
        anchors.margins: root.padding
        anchors.rightMargin: root.rightPadding
    }
}
