{ config, pkgs, lib, ... }:

{
  ################################################
  # Imports
  ################################################
  imports = [
    # --- Core ---
    ./core/npm.nix

    # --- Theme (palette + light/dark switch) ---
    ./theme/default.nix

    # --- Desktop / WM ---
    ./desktop/hyprland/default.nix
    ./desktop/quickshell/default.nix
    ./desktop/hyprlock.nix
    ./desktop/swaybg.nix
    ./desktop/kitty.nix

    # --- Shell ---
    ./shell/zsh.nix
    ./shell/oh-my-posh/default.nix

    # --- Editor ---
    ./editor/nixvim/default.nix

    # --- Tools ---
    ./tools/power.nix
    ./tools/udiskie.nix
    ./tools/helium.nix
    ./tools/desktop-entries.nix
    ./tools/tmux.nix
    ./tools/direnv.nix
    ./tools/rust.nix
    ./tools/workspace.nix
    ./tools/git.nix
  ];

  ################################################
  # Home Manager Basics
  ################################################
  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  ################################################
  # GTK: icon theme (file-type icons in Nautilus) and thumbnails
  ################################################
  gtk = {
    enable = true;
    # Papirus with grey folders instead of the default blue
    iconTheme = { name = "Papirus"; package = pkgs.papirus-icon-theme.override { color = "grey"; }; };
    # Sidebar places in Nautilus and in every GTK file picker (uploads etc.)
    gtk3.bookmarks = map (d: "file://${config.home.homeDirectory}/${d}") [
      "Downloads" "Documents" "Pictures" "Programming" "Books" "obsidian-vault"
    ];
  };

  # Default apps: images in eog (not the browser); web/URL handlers as they
  # were in the hand-written mimeapps.list before this took over.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = builtins.listToAttrs (map (t: { name = "image/${t}"; value = "org.gnome.eog.desktop"; })
      [ "png" "jpeg" "gif" "webp" "bmp" "tiff" "svg+xml" "avif" "heic" ]) // {
      "text/html" = "helium.desktop";
      "x-scheme-handler/http" = "helium.desktop";
      "x-scheme-handler/https" = "helium.desktop";
      "x-scheme-handler/about" = "helium.desktop";
      "x-scheme-handler/unknown" = "helium.desktop";
      "x-scheme-handler/mailto" = "helium.desktop";
      "x-scheme-handler/notion" = "notion-app-enhanced.desktop";
      "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      "x-scheme-handler/claude" = "claude-desktop.desktop";
      "x-scheme-handler/tolaria" = "tolaria-handler.desktop";
    };
  };
  # the files apps wrote by hand would block activation
  xdg.configFile."mimeapps.list".force = true;
  xdg.dataFile."applications/mimeapps.list".force = true;
  dconf.settings."org/gnome/nautilus/preferences" = {
    show-image-thumbnails = "always";
    thumbnail-limit = lib.hm.gvariant.mkUint64 104857600;   # 100 MB; big videos still get one
  };

  ################################################
  # Cargo: link against the system loader
  ################################################
  # By default rustc on NixOS bakes a /nix/store glibc path into every binary;
  # once nix.gc removes that glibc the binary can't start ("command not
  # found"). /lib64/ld-linux-x86-64.so.2 is provided by programs.nix-ld and
  # always points at a live glibc, so `cargo install`ed tools survive GC.
  home.file.".cargo/config.toml".text = ''
    [target.x86_64-unknown-linux-gnu]
    rustflags = ["-C", "link-arg=-Wl,--dynamic-linker=/lib64/ld-linux-x86-64.so.2"]
  '';

  # ai-memory MCP server over HTTP, loopback only (no auth token needed there).
  # The binary comes from `cargo install`, see the cargo config above.
  systemd.user.services.ai-memory = {
    Unit.Description = "ai-memory server";
    Service = {
      ExecStart = "%h/.cargo/bin/ai-memory serve --transport http --bind 127.0.0.1:49374";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };

  ################################################
  # Global Cursor
  ################################################
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };
}
