{ config, pkgs, ... }:

{
  ################################################
  # Imports
  ################################################
  imports = [
    # --- Core ---
    ./core/npm.nix

    # --- Desktop / WM ---
    ./desktop/hyprland/default.nix
    ./desktop/waybar/default.nix
    ./desktop/swaybg.nix
    ./desktop/kitty.nix

    # --- Shell ---
    ./shell/zsh.nix
    ./shell/oh-my-posh/default.nix

    # --- Editor ---
    ./editor/nixvim.nix

    # --- Tools ---
    ./tools/walker/default.nix
    ./tools/power.nix
    ./tools/udiskie.nix
    ./tools/helium.nix
    ./tools/desktop-entries.nix
  ];

  ################################################
  # Home Manager Basics
  ################################################
  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  ################################################
  # Global Cursor
  ################################################
  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };
}
