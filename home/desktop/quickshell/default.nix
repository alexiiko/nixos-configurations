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
  ];

  fonts.fontconfig.enable = true;

  # ~/.config/quickshell/shell.qml -> repo, so plain `qs` finds it.
  xdg.configFile."quickshell".source =
    config.lib.file.mkOutOfStoreSymlink repoDir;
}
