{ pkgs, ... }:

{
  # Wallpapers live next to this file. The `theme` command links the one for
  # the active mode to ~/.config/theme/wallpaper and restarts swaybg, so the
  # background follows light/dark (manual toggle and the 06:00/20:00 switch).
  # vision-board.jpg is an alternative, not wired to a mode.
  xdg.configFile."theme/wallpapers".source = ./wallpapers;

  wayland.windowManager.hyprland.extraConfig = ''
    exec-once = ${pkgs.swaybg}/bin/swaybg -i ~/.config/theme/wallpaper -m fill
  '';
}
