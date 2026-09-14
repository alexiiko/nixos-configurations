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
