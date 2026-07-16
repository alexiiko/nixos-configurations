{ ... }:

{
  wayland.windowManager.hyprland.extraConfig = ''
    submap = powermenu
    bind = , escape, exec, eww -c ~/Programming/nixos-config/home/desktop/waybar/eww close powermenu && hyprctl dispatch submap reset
    submap = reset
  '';

  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";

    bind = [
      "$mainMod, Q, exec, $terminal"
      "$mainMod, W, killactive,"
      "$mainMod, Ü, exec, command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"
      "$mainMod, E, exec, $fileManager"
      "$mainMod, V, togglefloating,"
      "$mainMod, SPACE, exec, $menu"
      "$mainMod, P, pseudo,"
      "$mainMod, J, layoutmsg, togglesplit"

      # Focus
      "$mainMod, left, movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up, movefocus, u"
      "$mainMod, down, movefocus, d"

      # Workspaces
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod, 0, workspace, 10"

      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"
      "$mainMod SHIFT, 6, movetoworkspace, 6"
      "$mainMod SHIFT, 7, movetoworkspace, 7"
      "$mainMod SHIFT, 8, movetoworkspace, 8"
      "$mainMod SHIFT, 9, movetoworkspace, 9"
      "$mainMod SHIFT, 0, movetoworkspace, 10"

      "$mainMod, S, togglespecialworkspace, magic"
      "$mainMod, TAB, workspace, e+1"
      "$mainMod SHIFT, TAB, workspace, e-1"

      # Resize
      "$mainMod SHIFT, left, resizeactive, -10 0"
      "$mainMod SHIFT, right, resizeactive, 10 0"
      "$mainMod SHIFT, up, resizeactive, 0 -10"
      "$mainMod SHIFT, down, resizeactive, 0 10"

      # Swap
      "$mainMod CTRL, left, swapwindow, l"
      "$mainMod CTRL, right, swapwindow, r"
      "$mainMod CTRL, up, swapwindow, u"
      "$mainMod CTRL, down, swapwindow, d"

      "$mainMod, F, fullscreen, 0"

      # Screenshots
      "$mainMod SHIFT, S, exec, grim -g \"$(slurp -b 00000080 -w 0)\" -s 2 -t png - | tee ~/Pictures/screenshots/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy -t image/png"

      # Startup Script
      "$mainMod SHIFT CTRL ALT, S, exec, ~/Programming/nixos-config/home/desktop/hyprland/startup.sh"
    ];

    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    bindel = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ", XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
      ", XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
    ];

    bindl = [
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
    ];
  };
}
