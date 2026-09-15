{ ... }:

{
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
      "$mainMod, T, layoutmsg, togglesplit"

      # Focus (vim keys)
      "$mainMod, H, movefocus, l"
      "$mainMod, J, movefocus, d"
      "$mainMod, K, movefocus, u"
      "$mainMod, L, movefocus, r"

      # Focus (arrow keys, same actions)
      "$mainMod, left, movefocus, l"
      "$mainMod, down, movefocus, d"
      "$mainMod, up, movefocus, u"
      "$mainMod, right, movefocus, r"

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
      "$mainMod SHIFT, W, togglespecialworkspace, whatsapp"
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
      "$mainMod SHIFT, S, exec, ~/Programming/nixos-config/home/desktop/hyprland/screenshot.sh"

      # Startup Script
      "$mainMod SHIFT CTRL ALT, S, exec, ~/Programming/nixos-config/home/desktop/hyprland/startup.sh"

      # Type a fixed string. -s lets Chromium-based apps apply the virtual
      # keymap before keys arrive, -d keeps them from outrunning it.
      "$mainMod CTRL SHIFT, A, exec, wtype -s 300 -d 45 -- yi57ikew"

      # Flip the display (and pen/touch) 180 degrees and back
      "$mainMod SHIFT, R, exec, ~/Programming/nixos-config/home/desktop/hyprland/rotate-screen.sh"

      # Light/dark theme toggle (runtime state, publishes via the portal)
      "$mainMod SHIFT, D, exec, theme toggle"
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
