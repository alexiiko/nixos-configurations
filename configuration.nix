{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  ################################################
  # Bootloader
  ################################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  ################################################
  # Power & Thermal Management
  ################################################
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;
  boot.kernel.sysctl."kernel.nmi_watchdog" = 0;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
  '';

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1
  '';

  ################################################
  # Networking
  ################################################
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  ################################################
  # Localization
  ################################################
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Keyboard
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };
  console.keyMap = "de";

  ################################################
  # Automatic Updates (flakes)
  ################################################
  system.autoUpgrade = {
    enable = true;
    flake = "/home/alex/Programming/nixos-config";
    flags = [
      "--update-input"
      "nixpkgs"
    ];
    dates = "weekly";
    randomizedDelaySec = "45min";
  };

  ################################################
  # Fonts
  ################################################
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

  ################################################
  # User
  ################################################
  users.users.alex = {
    isNormalUser = true;
    description = "Alexander Moseliani";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "docker"
    ];
    shell = pkgs.zsh;
  };

  ################################################
  # Nix
  ################################################
  nixpkgs.config.allowUnfreePredicate = _: true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  ################################################
  # Desktop Environment
  ################################################
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    defaultSession = "hyprland";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = [ "hyprland" "gtk" ];
  };

  ################################################
  # Shell
  ################################################
  programs.zsh.enable = true;

  ################################################
  # Audio
  ################################################
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  ################################################
  # Camera
  ################################################
  hardware.ipu6 = {
    enable = true;
    platform = "ipu6ep";
  };

  ################################################
  # Bluetooth
  ################################################
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  ################################################
  # System packages
  ################################################
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
    blueman
    git
    wget
    curl
  ];

  ################################################
  # Power Management
  ################################################
  services.power-profiles-daemon.enable = true;

  ################################################
  # Theming & Compatibility
  ################################################
  programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      stdenv.cc.cc.lib
      zlib
      openssl
      libgcc
      libxcrypt-legacy
      docker-compose
      libinput
      networkmanager
      libayatana-appindicator
      gtk3
      glib
      webkitgtk_4_1
      mesa
      libGL
      libGLU
      egl-wayland
      wayland
      libxkbcommon
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
    ];
  };

  ################################################
  # Virtualisation & Extras
  ################################################
  virtualisation.docker.enable = false;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.udisks2.enable = true;
  services.gvfs.enable = true;

  programs.chromium.enable = true;

  hardware.graphics.enable = true;

  ################################################
  # System
  ################################################
  hardware.enableAllFirmware = true;
  system.stateVersion = "26.05";
}
