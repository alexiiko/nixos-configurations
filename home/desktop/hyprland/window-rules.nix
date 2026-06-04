{ ... }:

{
  wayland.windowManager.hyprland.settings.windowrule = [
    # Maximize-Requests unterdrücken
    "match:class .*, suppress_event maximize"

    # XWayland Drag-Probleme beheben
    "match:class ^$, match:title ^$, match:xwayland 1, match:float 1, match:fullscreen 0, match:pin 0, no_focus 1"

    # hyprland-run Fenster float + positionieren
    "match:class hyprland-run, float 1"
    "match:class hyprland-run, move 20 monitor_h-120"
  ];
}
