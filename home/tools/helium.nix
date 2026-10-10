{ pkgs, ... }:

let
  # Runs the Helium AppImage in ~/Applications, whatever its version. To update
  # Helium, drop the new AppImage there and delete the old one (if several are
  # present, the newest version wins). Every Helium launcher goes through this.
  helium = pkgs.writeShellScriptBin "helium" ''
    app=$(ls -1 "$HOME"/Applications/helium*.AppImage 2>/dev/null | sort -V | tail -n1)
    [ -n "$app" ] || { echo "no helium*.AppImage in ~/Applications" >&2; exit 1; }
    exec ${pkgs.appimage-run}/bin/appimage-run "$app" "$@"
  '';
in
{
  home.packages = [ helium ];

  xdg.desktopEntries.helium = {
    name = "Helium Browser";
    exec = "helium %U";
    icon = "helium";
    comment = "Schneller und privater Browser";
    categories = [ "Network" "WebBrowser" ];
    terminal = false;
  };
}
