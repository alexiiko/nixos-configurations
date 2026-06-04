{ ... }:

{
  imports = [
    ./hyprland/settings.nix
    ./hyprland/keybinds.nix
    ./hyprland/window-rules.nix
    ./hyprland/workspace-rules.nix
  ];

  wayland.windowManager.hyprland.enable = true;
}
