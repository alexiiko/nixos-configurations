{ config, pkgs, ... }:

let
  wallpaperPath = "${config.home.homeDirectory}/Pictures/background.jpg";
in
{
  wayland.windowManager.hyprland.extraConfig = ''
    # swaybg setzt das Wallpaper direkt (kein Daemon, kein Race-Condition)
    exec-once = ${pkgs.swaybg}/bin/swaybg -i ${wallpaperPath} -m fill
  '';
}
