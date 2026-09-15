import QtQuick
import "../theme"

// Google Calendar mark from home/icons/google-calendar.svg, flattened to
// three palette tiers: frame + "31" in ink, side panels lighter, the folded
// corner in between. Generated inline so it recolours with the theme.
Image {
    id: root
    property int size: 22
    property color ink: Theme.c.onyx
    property color panel: Theme.c.driftwood
    property color fold: Theme.c.basalt

    readonly property var shapes: [
        ["polygon", "79.2,67.2 81.8,70.9 85.8,68 85.8,89 90.1,89 90.1,61.4 86.5,61.4  ", "ink"],
        ["path", "M72.3,74.4c1.6-1.4,2.6-3.5,2.6-5.7c0-4.4-3.9-8-8.6-8c-4,0-7.5,2.5-8.4,6.2l4.2,1.1c0.4-1.7,2.2-2.9,4.2-2.9   c2.4,0,4.3,1.6,4.3,3.6c0,2-1.9,3.6-4.3,3.6h-2.5v4.4h2.5c2.7,0,5,1.9,5,4.1c0,2.3-2.2,4.1-4.9,4.1c-2.4,0-4.5-1.5-4.8-3.6   l-4.2,0.7c0.7,4.1,4.6,7.2,9.1,7.2c5.1,0,9.2-3.8,9.2-8.5C75.6,78.2,74.3,75.9,72.3,74.4z", "ink"],
        ["polygon", "100.2,120.3 49.8,120.3 49.8,100.2 100.2,100.2  ", "panel"],
        ["polygon", "120.3,100.2 120.3,49.8 100.2,49.8 100.2,100.2  ", "panel"],
        ["path", "M100.2,49.8V29.7h-63c-4.2,0-7.6,3.4-7.6,7.6v63h20.1V49.8H100.2z", "ink"],
        ["polygon", "100.2,100.2 100.2,120.3 120.3,100.2  ", "fold"],
        ["path", "M112.8,29.7h-12.6v20.1h20.1V37.2C120.3,33,117,29.7,112.8,29.7z", "ink"],
        ["path", "M37.2,120.3h12.6v-20.1H29.7v12.6C29.7,117,33,120.3,37.2,120.3z", "ink"]
    ]

    readonly property string svg: {
        const col = { ink: root.ink, panel: root.panel, fold: root.fold };
        let body = "";
        for (const [tag, data, role] of root.shapes)
            body += `<${tag} ${tag === "path" ? "d" : "points"}="${data}" fill="${col[role].toString()}"/>`;
        return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="24 24 102 102">${body}</svg>`;
    }

    width: size
    height: size
    sourceSize: Qt.size(size * 2, size * 2)
    source: "data:image/svg+xml;utf8," + encodeURIComponent(svg)
    smooth: true
    mipmap: true
}
