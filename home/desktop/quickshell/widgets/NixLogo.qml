import QtQuick
import "../theme"

// The NixOS snowflake, rebuilt from the official geometry (nixos-icons):
// one lambda drawn six times at 60 degree steps, alternating two palette
// tones. Generated as an inline SVG so it recolours with the theme.
Image {
    id: root
    property int size: 26
    property color primary: Theme.c.onyx
    property color secondary: Theme.c.slate

    readonly property string lambda:
        "m 309.54892,-710.38827 122.19683,211.67512 -56.15706,0.5268 -32.6236,-56.8692 " +
        "-32.85645,56.5653 -27.90237,-0.011 -14.29086,-24.6896 46.81047,-80.4901 -33.22946,-57.8257 z"

    readonly property string svg: {
        let parts = "";
        for (let k = 0; k < 6; k++) {
            const fill = (k % 2 === 0 ? root.primary : root.secondary).toString();
            parts += `<path d="${root.lambda}" fill="${fill}" transform="rotate(${k * 60}) translate(-407.3,715.8)"/>`;
        }
        return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="-251 -251 502 502">${parts}</svg>`;
    }

    width: size
    height: size
    sourceSize: Qt.size(size * 2, size * 2)   // render at 2x for the HiDPI scale
    source: "data:image/svg+xml;utf8," + encodeURIComponent(svg)
    smooth: true
    mipmap: true
}
