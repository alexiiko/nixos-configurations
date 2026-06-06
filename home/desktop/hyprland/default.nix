{ ... }:

{
  imports = [
    ./settings.nix
    ./keybinds.nix
    ./window-rules.nix
    ./workspace-rules.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
  };
}
