import QtQuick
import QtQuick.Shapes
import "../theme"

// Ring gauge in the style of the reference: an open arc (gap at the bottom
// left) with a light track and a dark progress arc, big value in the middle,
// label under it, and an optional secondary metric at the lower right.
Item {
    id: root
    property real value: 0                 // 0..1 -> main arc
    property string text: ""               // centre, big
    property string icon: ""               // centre glyph instead of text
    property bool iconFilled: false
    property string label: ""              // centre, under text
    property real secondary: -1            // 0..1 -> small inner arc; <0 hides
    property string secondaryText: ""
    property string secondaryLabel: ""
    property color arcColor: Theme.c.onyx
    property color trackColor: Theme.c.silverBirch
    property int stroke: 8

    implicitWidth: 150
    implicitHeight: 150

    // arc geometry: 270 degrees, opening at the bottom-left like the reference
    readonly property real startAngle: 135
    readonly property real sweep: 270
    readonly property real side: Math.min(width, height)
    readonly property real r: side / 2 - stroke

    Shape {
        anchors.fill: parent
        layer.enabled: true; layer.samples: 4            // smooth edges

        // track
        ShapePath {
            strokeColor: root.trackColor; strokeWidth: root.stroke; fillColor: "transparent"; capStyle: ShapePath.RoundCap
            PathAngleArc { centerX: root.width / 2; centerY: root.height / 2; radiusX: root.r; radiusY: root.r
                           startAngle: root.startAngle; sweepAngle: root.sweep }
        }
        // value
        ShapePath {
            strokeColor: root.arcColor; strokeWidth: root.stroke; fillColor: "transparent"; capStyle: ShapePath.RoundCap
            PathAngleArc { centerX: root.width / 2; centerY: root.height / 2; radiusX: root.r; radiusY: root.r
                           startAngle: root.startAngle; sweepAngle: Math.max(0.5, root.sweep * root.value)
                           Behavior on sweepAngle { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } } }
        }
        // secondary: thinner, inset, mirrored (grows from the other end)
        ShapePath {
            strokeColor: root.trackColor; strokeWidth: root.stroke * 0.5; fillColor: "transparent"; capStyle: ShapePath.RoundCap
            PathAngleArc { centerX: root.width / 2; centerY: root.height / 2; radiusX: root.r - root.stroke * 1.4; radiusY: radiusX
                           startAngle: root.startAngle; sweepAngle: root.secondary >= 0 ? root.sweep : 0 }
        }
        ShapePath {
            strokeColor: Theme.c.charcoal; strokeWidth: root.stroke * 0.5; fillColor: "transparent"; capStyle: ShapePath.RoundCap
            PathAngleArc { centerX: root.width / 2; centerY: root.height / 2; radiusX: root.r - root.stroke * 1.4; radiusY: radiusX
                           startAngle: root.startAngle + root.sweep
                           sweepAngle: root.secondary >= 0 ? -Math.max(0.5, root.sweep * root.secondary) : 0
                           Behavior on sweepAngle { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } } }
        }
    }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -4
        spacing: 2
        Text { visible: root.icon === ""; anchors.horizontalCenter: parent.horizontalCenter; text: root.text; color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: 26; font.weight: Font.Medium }
        Icon { visible: root.icon !== ""; anchors.horizontalCenter: parent.horizontalCenter; name: root.icon; filled: root.iconFilled; size: 34; color: Theme.c.onyx }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.label; color: Theme.c.charcoal; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1 }
    }

    // secondary readout: left-aligned just past the ring's lower-right end,
    // so a wide value grows outward instead of into the arc
    Column {
        visible: root.secondary >= 0
        // tucked inside the ring at the lower right: the box's right edge
        // meets the arc's end (45 degrees), both lines right-aligned to it
        width: 64
        x: root.width / 2 + root.r * Math.cos(Math.PI / 4) - width - 14
        y: root.height / 2 + root.r * Math.sin(Math.PI / 4) - 6
        spacing: 0
        Text { width: parent.width; horizontalAlignment: Text.AlignRight; text: root.secondaryText; color: Theme.c.onyx; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1; font.weight: Font.Medium }
        Text { width: parent.width; horizontalAlignment: Text.AlignRight; text: root.secondaryLabel; color: Theme.c.slate; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 3 }
    }
}
