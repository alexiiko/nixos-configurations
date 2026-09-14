import QtQuick
import "../theme"

// Material Symbols Rounded glyph by ligature name, e.g. Icon { name: "lock" }.
// Light weight + no fill = the "soft" look. Set `filled: true` for active states.
Text {
    property string name
    property bool filled: false
    property int size: 20

    text: name
    font.family: Theme.iconFamily
    font.pixelSize: size
    font.weight: Font.Light
    font.variableAxes: ({ "FILL": filled ? 1 : 0, "wght": 300, "GRAD": 0, "opsz": size })
    color: Theme.c.onyx
    renderType: Text.NativeRendering
}
