{ ... }:

{
  imports = [
    ./settings.nix
    ./keybinds.nix
    ./window-rules.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
  };
}
