{ ... }:

{
  wayland.windowManager.hyprland.settings.windowrule = [
    # Maximize-Requests unterdrücken
    "match:class .*, suppress_event maximize"

    # XWayland Drag-Probleme beheben
    "match:class ^$, match:title ^$, match:xwayland 1, match:float 1, match:fullscreen 0, match:pin 0, no_focus 1"


    # WhatsApp (ZapFast) lives on its own special workspace; the sidebar and
    # the keybind toggle it. `silent` so it does not steal focus when it starts.
    "match:class ^zapfast$, workspace special:whatsapp silent"
  ];
}
