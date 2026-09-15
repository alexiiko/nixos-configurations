{ pkgs, ... }:

let
  # ponytail: reuse tmux-resurrect's own scripts; restore.sh already skips
  # sessions that already exist (by name).
  resurrectScripts = "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts";
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "tmux-save" ''
      set -e
      ${resurrectScripts}/save.sh
      echo "Saved sessions:"
      tmux list-sessions -F '  #{session_name}'
    '')
    # restore.sh only works inside tmux (it reads the socket out of $TMUX), so
    # outside tmux: boot a scratch session, restore via run-shell.
    (pkgs.writeShellScriptBin "tmux-load" ''
      set -e
      if [ -n "''${TMUX:-}" ]; then
        ${resurrectScripts}/restore.sh
      else
        tmux new-session -d -s __resurrect__
        tmux run-shell ${resurrectScripts}/restore.sh
        tmux kill-session -t __resurrect__ 2>/dev/null || true
      fi
      echo "Restored sessions:"
      tmux list-sessions -F '  #{session_name}'
    '')
  ];

  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 0;
    terminal = "tmux-256color";
    historyLimit = 100000;
    prefix = "C-Space";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
    ];

    extraConfig = ''
      set -g renumber-windows on

      # Let apps reach the terminal through tmux (Claude Code wraps its desktop
      # notifications in DCS passthrough; without this tmux swallows them).
      set -g allow-passthrough on

      # Save the session state on every detach. "quiet" so the confirmation
      # doesn't pop up on some other terminal's client.
      set-hook -g client-detached 'run-shell -b "${resurrectScripts}/save.sh quiet"'
      set -ga terminal-overrides ",*256col*:Tc"

      # Enable extended keys (CSI u) so Ctrl+Tab etc. are distinguishable
      set -s extended-keys on
      set -as terminal-features 'xterm*:extkeys'
      set -as terminal-features 'kitty*:extkeys'

      # Cycle windows without prefix (kitty sends CSI-u for Alt+[Shift+]Tab)
      bind -n M-Tab next-window
      bind -n M-S-Tab previous-window
      bind -n M-BTab previous-window

      # Emacs-style editing in command prompt so Ctrl+W (from kitty's
      # Ctrl+Backspace mapping) deletes the previous word during rename etc.
      set -g status-keys emacs

      # colours: written by the `theme` command (see home/theme)
      source-file ~/.config/theme/tmux.conf
      set -g status-left-length 40
      set -g status-right-length 60
    '';
  };
}
