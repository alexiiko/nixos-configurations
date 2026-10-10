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
    ffmpeg
    vlc

    ################################################
    # Terminal & Shell
    ################################################
    kitty
    eza
    btop
    oh-my-posh
    zoxide
    tree

    ################################################
    # File Management
    ################################################
    nautilus
    ffmpegthumbnailer   # video thumbnails in nautilus
    file-roller
    eog

    ################################################
    # Wayland / Hyprland Tools
    ################################################
    libnotify
    wl-clipboard
    wtype
    libinput
    xclip
    swaybg
    hyprpolkitagent     # polkit prompts (fprintd enrol, mounts) need an agent
    nmgui
    glib-networking

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
    shared-mime-info
    glib
    desktop-file-utils

    ################################################
    # Development - Core
    ################################################
    gcc
    pkg-config
    openssl
    # Development - Languages - Programming
    ################################################
    # Claude Code Flake
    inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default

    opencode

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
      pandas
    ]))

    # Go
    go
    gopls

    # Rust
    rustc
    cargo

    # nix
    nil
    nixd

    # typst
    typst
    tinymist
    typstyle
    websocat

    ################################################
    # Browsers & Web
    ################################################
    google-chrome
    playwright-driver.browsers

    ################################################
    # Productivity
    ################################################
    obsidian
    anki
    readest
    onlyoffice-desktopeditors
    zotero

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
    turso-cli
    evince
    pv
    bun

    # Eigener Editor
    antigravity-ide

    ################################################
    # Misc
    ################################################
    localsend

    ################################################
    # Funny Stuff
    ################################################
    pipes
    fastfetch
  ];
}
