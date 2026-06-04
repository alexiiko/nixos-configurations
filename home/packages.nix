{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ################################################
    # Audio & Media
    ################################################
    pavucontrol
    pamixer
    qpwgraph
    playerctl

    ################################################
    # Terminal & Shell
    ################################################
    kitty
    eza
    btop
    oh-my-posh

    ################################################
    # File Management
    ################################################
    kdePackages.dolphin
    file-roller
    eog

    ################################################
    # Wayland / Hyprland Tools
    ################################################
    waybar
    dunst
    libnotify
    wl-clipboard
    xclip
    swaybg
    networkmanagerapplet

    ################################################
    # Screenshots & Recording
    ################################################
    grim
    slurp
    satty
    wf-recorder

    ################################################
    # Theming & Fonts
    ################################################
    bibata-cursors
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    gtk4
    librsvg
    shared-mime-info
    glib
    desktop-file-utils

    ################################################
    # Development - Core
    ################################################
    gcc
    pkg-config
    openssl
    libiconv
    cairo
    pango
    fontconfig
    freetype

    ################################################
    # Development - Languages
    ################################################
    # Node.js
    nodejs
    vite
    tailwindcss
    typescript
    eslint
    tsx

    # Python
    (python3.withPackages (ps: with ps; [
      pip
      virtualenv
      requests
      weasyprint
      jinja2
      pillow
    ]))

    # Go
    go
    gopls

    # Rust
    rustc
    cargo

    ################################################
    # Browsers & Web
    ################################################
    chromium
    google-chrome
    playwright-driver.browsers
    vscode-fhs

    ################################################
    # Productivity
    ################################################
    obsidian
    anki
    readest
    libreoffice-qt

    ################################################
    # System & Utilities
    ################################################
    brightnessctl
    gnome-keyring
    appimage-run
    zip
    unzip
    filezilla
    potrace
    imagemagick
    inkscape

    # Eigener Editor
    antigravity
  ];
}
