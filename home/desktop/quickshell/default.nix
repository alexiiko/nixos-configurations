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
    gcalcli            # Google Calendar (OAuth token lives in ~/.config/gcalcli, outside the repo)

    # gcal-day YYYY-MM-DD -> TSV of that day's events, for the dashboard card.
    # Fixed --details so the column order is known: start_date start_time
    # end_date end_time title calendar. Exit code is gcalcli's, so "not
    # authenticated" surfaces as a failure rather than an empty day.
    (writeShellScriptBin "gcal-day" ''
      set -euo pipefail
      day="$1"
      next="$(${coreutils}/bin/date -d "$day + 1 day" +%F)"
      exec ${gcalcli}/bin/gcalcli --nocolor agenda --tsv --military --nodeclined \
        --details end --details calendar "$day" "$next"
    '')
  ];

  fonts.fontconfig.enable = true;

  # ~/.config/quickshell/shell.qml -> repo, so plain `qs` finds it.
  xdg.configFile."quickshell".source =
    config.lib.file.mkOutOfStoreSymlink repoDir;
}
