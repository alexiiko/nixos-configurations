pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Single access point for colours. Reads the palette nix generates and the
// runtime mode file the `theme` command writes; flips live when the mode
// file changes, so Super+Shift+D recolours every widget without a restart.
Singleton {
    id: root

    readonly property string configDir: Quickshell.env("HOME") + "/.config/theme"

    property string mode: "light"
    property var palette: ({ light: {}, dark: {} })

    // Current palette. Usage: Theme.c.onyx, Theme.c.ivory, ...
    readonly property var c: palette[mode] || {}

    // Typography, kept here so a font change is one edit.
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property string iconFamily: "Material Symbols Rounded"
    readonly property int fontSize: 13

    // Glass treatment (iOS-style): translucent fills with a highlight rim.
    // Real backdrop blur is a compositor feature Hyprland lacks, so the
    // glass is simulated with translucency — the wallpaper really shows
    // through the panels. Rims read better inverted against the fill.
    readonly property real glassAlpha: mode === "dark" ? 0.55 : 0.52
    readonly property color glassRim: mode === "dark" ? "#2EFFFFFF" : "#24000000"
    // palette values are hex strings; Qt.lighter coerces one into a color
    // value so its channels can be recombined with our own alpha
    function glass(hex, a) {
        const c = Qt.lighter(hex, 1.0);
        return Qt.rgba(c.r, c.g, c.b, a === undefined ? glassAlpha : a);
    }

    FileView {
        id: paletteFile
        path: root.configDir + "/palette.json"
        blockLoading: true
        watchChanges: true
        onLoaded: root.palette = JSON.parse(text())
        onFileChanged: reload()
    }

    FileView {
        id: modeFile
        path: root.configDir + "/mode"
        blockLoading: true
        watchChanges: true
        onLoaded: root.mode = text().trim() === "dark" ? "dark" : "light"
        onFileChanged: reload()
    }

    Component.onCompleted: {
        root.palette = JSON.parse(paletteFile.text());
        root.mode = modeFile.text().trim() === "dark" ? "dark" : "light";
    }
}
