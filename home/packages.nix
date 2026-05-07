{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pavucontrol
    kitty
    kdePackages.dolphin
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
    swaybg
    bibata-cursors
    oh-my-posh
    eza
    appimage-run
    eog
    zip
    unzip
    file-roller
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    shared-mime-info
    glib
    obsidian
    gtk4
    librsvg
    desktop-file-utils
    notion-app
  ];
}
