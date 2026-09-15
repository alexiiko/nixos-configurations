{ config, pkgs, lib, ... }:

let
  palette = import ./palette.nix;

  # Runtime state lives outside nix so a keybind can flip it without a rebuild.
  stateDir  = "$HOME/.config/theme";
  modeFile  = "${stateDir}/mode";

  schemas = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";

  # Per-app colour files, one per mode. `theme` copies the active one to
  # ~/.config/theme/<app>.conf and pokes the running app; the apps only ever
  # read the un-suffixed file.
  ansiOrder = [ "black" "red" "green" "yellow" "blue" "magenta" "cyan" "white"
                "brightBlack" "brightRed" "brightGreen" "brightYellow" "brightBlue" "brightMagenta" "brightCyan" "brightWhite" ];
  kittyConf = c: ''
    foreground ${c.onyx}
    background ${c.ivory}
    cursor ${c.onyx}
    cursor_text_color ${c.ivory}
    selection_foreground ${c.onyx}
    selection_background ${c.sand}
    url_color ${c.basalt}
    active_border_color ${c.stone}
    inactive_border_color ${c.mist}
    active_tab_foreground ${c.onyx}
    active_tab_background ${c.sand}
    inactive_tab_foreground ${c.slate}
    inactive_tab_background ${c.linen}
    tab_bar_background ${c.linen}
  '' + lib.concatImapStrings (i: n: "color${toString (i - 1)} ${c.ansi.${n}}\n") ansiOrder;
  tmuxConf = c: ''
    set -g status-style "bg=${c.cream},fg=${c.onyx}"
    set -g window-status-style "bg=${c.cream},fg=${c.basalt}"
    set -g window-status-current-style "bg=${c.pebble},fg=${c.onyx},bold"
    set -g message-style "bg=${c.cream},fg=${c.onyx}"
    set -g message-command-style "bg=${c.cream},fg=${c.onyx}"
    set -g mode-style "bg=${c.sand},fg=${c.onyx}"
    set -g pane-border-style "fg=${c.mist}"
    set -g pane-active-border-style "fg=${c.stone}"
    set -g status-right "#{?client_prefix,#[bg=${c.pebble}#,fg=${c.onyx}#,bold] PREFIX #[default] ,}"
  '';
  perMode = name: gen: {
    "theme/${name}-light.conf".text = gen palette.light;
    "theme/${name}-dark.conf".text  = gen palette.dark;
  };
in
{

  # First-run/rebuild: make sure the un-suffixed files exist for the current
  # mode before any app starts (the `theme` command keeps them current after).
  home.activation.themeFiles = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    mode=$(cat "$HOME/.config/theme/mode" 2>/dev/null || echo light)
    for app in kitty tmux; do
      cp -f "$HOME/.config/theme/$app-$mode.conf" "$HOME/.config/theme/$app.conf"
    done
  '';

  # Palette as JSON for runtime consumers (Quickshell reads this; anything
  # that can't take nix directly can too). Regenerated on rebuild.
  xdg.configFile = { "theme/palette.json".text = builtins.toJSON palette; }
    // perMode "kitty" kittyConf // perMode "tmux" tmuxConf;

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
      # coreutils too: the theme script needs mkdir/cat/cp and the user profile does not carry them
      Environment = "PATH=${config.home.profileDirectory}/bin:${pkgs.coreutils}/bin";
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

      # hyprlock reads its colours from a plain file at launch
      cp -f "$HOME/.config/hypr/hyprlock-$mode.conf" "$HOME/.config/hypr/hyprlock-theme.conf"

      # terminal stack: swap the active file, then poke what is running
      for app in kitty tmux; do
        cp -f "${stateDir}/$app-$mode.conf" "${stateDir}/$app.conf"
      done
      # kitty: SIGUSR1 reloads the config, but windows whose colours an app
      # touched via escape codes keep them; set-colors over the socket
      # overrides those too
      ${pkgs.procps}/bin/pkill -USR1 -x kitty || true
      for s in /tmp/kitty-*; do
        [ -S "$s" ] && ${pkgs.kitty}/bin/kitten @ --to "unix:$s" set-colors -a -c "${stateDir}/kitty.conf" 2>/dev/null || true
      done
      ${pkgs.tmux}/bin/tmux source-file "${stateDir}/tmux.conf" 2>/dev/null || true
      ${pkgs.procps}/bin/pkill -USR1 -x nvim || true      # nvim re-reads the mode file on SIGUSR1

      # Claude Code: own themes only (dark/light), follows its settings file
      cc="$HOME/.claude/settings.json"
      if [ -f "$cc" ]; then
        ${pkgs.jq}/bin/jq --arg t "$mode" '.theme = $t' "$cc" > "$cc.tmp" && mv "$cc.tmp" "$cc"
      fi

      [ "$mode" = dark ] && scheme=prefer-dark || scheme=prefer-light
      GSETTINGS_SCHEMA_DIR="${schemas}" \
        ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "$scheme"

      echo "$mode"
    '')
  ];
}
