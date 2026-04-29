{ config, pkgs, inputs, ... }:

{
  imports = [
    ./home/packages.nix
    ./home/hyprland.nix
    ./home/waybar.nix
    ./home/default.nix
    ./home/zsh.nix
    ./home/nixvim.nix
    ./home/swaybg.nix
    ./home/kitty.nix
    ./home/oh-my-posh.nix
    ./home/walker.nix
    ./home/power.nix
    ./home/helium.nix
    ./home/webapps.nix
  ];

  home.username = "alex";
  home.homeDirectory = "/home/alex";

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };
}
