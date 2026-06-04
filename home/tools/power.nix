{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeShellScriptBin "suspend"  "exec systemctl suspend")
    (writeShellScriptBin "reboot"   "exec systemctl reboot")
    (writeShellScriptBin "shutdown" "exec systemctl poweroff")
  ];

  home.file = {
    ".local/share/icons/hicolor/scalable/apps/energie-sparen.svg".source = ../icons/energie-sparen.svg;
    ".local/share/icons/hicolor/scalable/apps/restart.svg".source        = ../icons/restart.svg;
    ".local/share/icons/hicolor/scalable/apps/shutdown.svg".source       = ../icons/shutdown.svg;
    ".local/share/icons/hicolor/scalable/apps/notion.svg".source = ../icons/notion.svg;
  };
}
