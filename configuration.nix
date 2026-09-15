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
  boot.kernelPackages = pkgs.linuxPackages_latest;

  ################################################
  # Power & Thermal Management
  ################################################
  services.thermald.enable = true;
  boot.kernel.sysctl."kernel.nmi_watchdog" = 0;

  boot.kernelParams = [
      "pcie_aspm=force"
      "i915.enable_psr=2"
      "i915.enable_fbc=1"
      "i915.enable_dc=4"
      "iwlwifi.power_save=1"
      "iwlwifi.power_level=5"
    ];

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 30;
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      INTEL_GPU_MIN_FREQ_ON_BAT = 100;
      INTEL_GPU_MAX_FREQ_ON_BAT = 800;
      WIFI_PWR_ON_BAT = "on";
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";
      USB_AUTOSUSPEND = 1;
      RUNTIME_PM_ON_BAT = "auto";
      PCIE_ASPM_ON_BAT = "powersupersave";
    };
  };

  services.power-profiles-daemon.enable = false;

  # Fan/thermal profile switch for the dashboard. platform_profile is root-only,
  # so a fixed, argument-validated helper (in systemPackages below) is allowed
  # through sudo without a password. TLP still applies its own profile on
  # AC/battery changes.
  security.sudo.extraRules = [{
    users = [ "alex" ];
    commands = [{ command = "/run/current-system/sw/bin/set-power-mode"; options = [ "NOPASSWD" ]; }];
  }];

  # Battery/AC state over D-Bus; the quickshell battery widget reads this.
  services.upower.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
  '';

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1 power_save_controller=Y
    options iwlwifi power_save=1 power_level=5
    options i915 enable_fbc=1 enable_psr=2 enable_dc=4
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
    # 1st and 15th of the month at 03:00; `persistent` runs a missed slot
    # at the next boot, so a laptop that was off still gets it.
    dates = "*-*-01,15 03:00";
    persistent = true;
    randomizedDelaySec = "45min";
  };

  # The upgrade runs as root against a repo owned by alex. libgit2 refuses
  # that ("not owned by current user") unless the path is marked safe, which
  # is why the timer fired for weeks without ever upgrading anything.
  programs.git = {
    enable = true;
    config.safe.directory = [ "/home/alex/Programming/nixos-config" ];
  };
  # `--update-input` rewrites flake.lock as root; hand it back so alex can
  # still commit and update it afterwards.
  systemd.services.nixos-upgrade.serviceConfig.ExecStopPost =
    "${pkgs.coreutils}/bin/chown alex:users /home/alex/Programming/nixos-config/flake.lock";

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
      "lp"
      "scanner"
      "input"
      "ydotool"
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
  # Printing & Scanning
  ################################################
  services.printing = {
    enable = true;
    drivers = with pkgs; [ hplip ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.hplip ];
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

    # see the sudo rule under Power & Thermal Management
    (writeShellScriptBin "set-power-mode" ''
      set -eu
      f=/sys/firmware/acpi/platform_profile
      case " $(cat "$f"_choices) " in
        *" $1 "*) printf '%s' "$1" > "$f" ;;
        *) echo "invalid mode: $1 (choices: $(cat "$f"_choices))" >&2; exit 2 ;;
      esac
    '')
  ];

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
  # Input synthesis daemon; the pen-button script uses it to emit right-clicks.
  programs.ydotool.enable = true;

  # Screen locker. The module wires PAM; without it hyprlock cannot
  # authenticate and you would be locked out.
  programs.hyprlock.enable = true;

  # Daemon starts on first use via socket activation, not at boot.
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

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
