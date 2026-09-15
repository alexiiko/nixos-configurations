{ config, pkgs, ... }:

let
  # The QML lives in the repo and is symlinked in, not copied to the store:
  # quickshell hot-reloads on save, so edits apply instantly without a rebuild.
  repoDir = "/home/alex/Programming/nixos-config/home/desktop/quickshell";
in
{
  home.packages = with pkgs; [
    quickshell
    material-symbols   # Material Symbols Rounded (variable: wght/FILL/GRAD/opsz)
    cava               # audio visualizer feed for the dashboard media tab
    gcalcli            # Google Calendar (OAuth token lives in ~/.config/gcalcli, outside the repo)

    # gcal-day YYYY-MM-DD -> JSON events with colours, for the dashboard card.
    # A small Python script that reuses gcalcli's stored token and talks to
    # the Calendar API directly (gcalcli's own output has no colour field).
    (writeShellScriptBin "gcal-day" ''
      exec ${python3.withPackages (ps: [ ps.google-api-python-client ps.google-auth ])}/bin/python3 \
        ${./scripts/gcal-day.py} "$@"
    '')
  ];

  fonts.fontconfig.enable = true;

  # ~/.config/quickshell/shell.qml -> repo, so plain `qs` finds it.
  xdg.configFile."quickshell".source =
    config.lib.file.mkOutOfStoreSymlink repoDir;
}
