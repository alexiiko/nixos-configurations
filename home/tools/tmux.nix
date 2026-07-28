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

      # Save the session state on every detach.
      set-hook -g client-detached 'run-shell -b "${resurrectScripts}/save.sh"'
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

      # Statusline: light gray background, dark text
      set -g status-style "bg=#d0d0d0,fg=#1c1c1c"
      set -g window-status-style "bg=#d0d0d0,fg=#1c1c1c"
      set -g window-status-current-style "bg=#5f87af,fg=#ffffff,bold"
      set -g status-left-length 40
      set -g status-right-length 60

      # Keep the statusline gray during rename / command-prompt / copy-mode
      # (tmux default paints these yellow).
      set -g message-style "bg=#d0d0d0,fg=#1c1c1c"
      set -g message-command-style "bg=#d0d0d0,fg=#1c1c1c"
      set -g mode-style "bg=#d0d0d0,fg=#1c1c1c"

      # Prefix indicator: gray pill when C-Space active (was yellow)
      set -g status-right "#{?client_prefix,#[bg=#d0d0d0#,fg=#1c1c1c#,bold] PREFIX #[default] ,}"
    '';
  };
}
