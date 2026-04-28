{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pavucontrol
    kitty
    firefox
    kdePackages.dolphin
    rofi
    waybar
    dunst
    libnotify
    pamixer
    wl-clipboard
    grim slurp
    brightnessctl
    networkmanagerapplet
    qpwgraph
    playerctl
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    xclip
    btop
    readest
    libreoffice-qt
  ];
}
