{ pkgs, lib, ... }:

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
