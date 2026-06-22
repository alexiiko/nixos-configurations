{ pkgs, inputs, ... }:

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
    # Camera
    ################################################
    v4l-utils
    cheese
    ipu6-camera-hal
    ipu6-camera-bins

    ################################################
    # Terminal & Shell
    ################################################
    kitty
    eza
    btop
    oh-my-posh
    zoxide

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
    eww

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
    # Claude Code Flake
    inputs.claude-code-nix.packages.${pkgs.system}.default

    # Node.js
    nodejs
    vite
    tailwindcss
    typescript
    eslint
    tsx

    # Python
    (pkgs.python312.withPackages (ps: with ps; [
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
    firefox
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

    ################################################
    # Funny Stuff
    ################################################
    pipes
    fastfetch
  ];
}
