{ config, pkgs, lib, ... }:

let
  palette = import ../theme/palette.nix;
  # hyprlock wants rgb(RRGGBB) without the '#'
  rgb = hex: "rgb(${lib.removePrefix "#" hex})";
  # one colour file per mode; the `theme` command copies the active one to
  # hyprlock-theme.conf, which hyprlock.conf sources
  colours = c: ''
    $bg          = ${rgb c.linen}
    $surface     = ${rgb c.ivory}
    $border      = ${rgb c.pebble}
    $borderFocus = ${rgb c.stone}
    $text        = ${rgb c.onyx}
    $muted       = ${rgb c.slate}
    $check       = ${rgb c.charcoal}
    $fail        = ${rgb c.clay}
  '';
in
{
  programs.hyprlock = {
    enable = true;
    package = pkgs.hyprlock;    # PAM is wired by the NixOS module
    settings = {
      # colours come from the active theme, written by the `theme` command
      source = "${config.xdg.configHome}/hypr/hyprlock-theme.conf";

      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = [{
        monitor = "";
        path = "screenshot";
        color = "$bg";
        blur_passes = 3;
        blur_size = 10;
        brightness = 0.9;
      }];

      # time, above the input
      label = [
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +%H:%M)"'';
          color = "$text";
          font_size = 144;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 125";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          # LC_TIME overrides the system's German date locale
          text = ''cmd[update:60000] echo "$(LC_TIME=en_US.UTF-8 date +'%A, %-d %B %Y')"'';
          color = "$muted";
          font_size = 30;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 5";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [{
        monitor = "";
        size = "600, 92";
        position = "0, -145";
        halign = "center";
        valign = "center";
        rounding = 24;
        outline_thickness = 2;
        outer_color = "$border";
        inner_color = "$surface";
        font_color = "$text";
        font_family = "JetBrainsMono Nerd Font";
        placeholder_text = ''<span foreground="##8A8580">Password</span>'';
        fail_text = ''<span foreground="##9E6E62">Wrong password</span>'';
        fail_color = "$fail";
        check_color = "$check";
        capslock_color = "$fail";
        dots_size = 0.25;
        dots_spacing = 0.3;
        hide_input = false;
        fade_on_empty = false;
        # no layout indicator: nothing here references $LAYOUT
      }];
    };
  };

  xdg.configFile."hypr/hyprlock-light.conf".text = colours palette.light;
  xdg.configFile."hypr/hyprlock-dark.conf".text  = colours palette.dark;

  # Seed the active colour file from the current mode on activation, so a
  # lock right after a rebuild (before `theme` has run) still has colours.
  home.activation.hyprlockTheme = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    mode=$(cat "$HOME/.config/theme/mode" 2>/dev/null || echo light)
    cp -f "$HOME/.config/hypr/hyprlock-$mode.conf" "$HOME/.config/hypr/hyprlock-theme.conf"
  '';
}
