{ config, pkgs, lib, ... }:

let
  palette = import ./palette.nix;

  # Runtime state lives outside nix so a keybind can flip it without a rebuild.
  stateDir  = "$HOME/.config/theme";
  modeFile  = "${stateDir}/mode";

  schemas = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
in
{
  # Palette as JSON for runtime consumers (Quickshell reads this; anything
  # that can't take nix directly can too). Regenerated on rebuild.
  xdg.configFile."theme/palette.json".text = builtins.toJSON palette;

  # Automatic light/dark by time of day: dark from 20:00, light from 06:00.
  # A oneshot picks the right mode for "now" (also on login, so a session
  # started at 22:00 comes up dark); timers fire it at both boundaries.
  # Super+Shift+D still overrides until the next boundary.
  systemd.user.services.theme-auto = {
    Unit.Description = "Apply light/dark theme for the current time";
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      Type = "oneshot";
      ExecStart = toString (pkgs.writeShellScript "theme-auto" ''
        h=$(${pkgs.coreutils}/bin/date +%H)
        if [ "$h" -ge 20 ] || [ "$h" -lt 6 ]; then theme dark; else theme light; fi
      '');
      Environment = "PATH=${config.home.profileDirectory}/bin";
    };
  };
  systemd.user.timers.theme-auto = {
    Unit.Description = "Switch theme at 06:00 and 20:00";
    Install.WantedBy = [ "timers.target" ];
    Timer = { OnCalendar = [ "*-*-* 06:00:00" "*-*-* 20:00:00" ]; Persistent = true; };
  };

  home.packages = [
    pkgs.gsettings-desktop-schemas

    # theme light|dark|toggle|get
    # Writes the mode file and publishes the choice through the portal
    # (org.freedesktop.appearance color-scheme), which is what browsers and
    # GTK/Qt apps read for prefers-color-scheme.
    (pkgs.writeShellScriptBin "theme" ''
      set -euo pipefail
      mode_file="${modeFile}"
      mkdir -p "${stateDir}"

      current() { cat "$mode_file" 2>/dev/null || echo light; }

      case "''${1:-get}" in
        get)    current; exit 0 ;;
        light)  mode=light ;;
        dark)   mode=dark ;;
        toggle) [ "$(current)" = dark ] && mode=light || mode=dark ;;
        *) echo "usage: theme [light|dark|toggle|get]" >&2; exit 2 ;;
      esac

      printf '%s\n' "$mode" > "$mode_file"

      [ "$mode" = dark ] && scheme=prefer-dark || scheme=prefer-light
      GSETTINGS_SCHEMA_DIR="${schemas}" \
        ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "$scheme"

      echo "$mode"
    '')
  ];
}
