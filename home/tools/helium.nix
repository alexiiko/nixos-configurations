{ pkgs, ... }:
{
  # AppImage-Runner muss installiert sein
  home.packages = with pkgs; [ appimage-run ];

  # Desktop-Eintrag für Walker (sehr zuverlässig)
  xdg.desktopEntries.helium = {
    name = "Helium Browser";
    exec = "appimage-run /home/alex/Applications/helium-0.11.5.1-x86_64.AppImage";
    icon = "helium";                    # später kannst du hier ein echtes Icon einbauen
    comment = "Schneller und privater Browser";
    categories = [ "Network" "WebBrowser" ];
    terminal = false;
  };
}
