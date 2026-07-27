{ pkgs, ... }:

{
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
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];

    extraConfig = ''
      set -g renumber-windows on
      set -ga terminal-overrides ",*256col*:Tc"

      # Enable extended keys (CSI u) so Ctrl+Tab etc. are distinguishable
      set -s extended-keys on
      set -as terminal-features 'xterm*:extkeys'
      set -as terminal-features 'kitty*:extkeys'

      # Cycle windows without prefix (kitty sends CSI-u for Alt+[Shift+]Tab)
      bind -n M-Tab next-window
      bind -n M-S-Tab previous-window

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
      set -g status-right "#{?client_prefix,#[bg=#d0d0d0#,fg=#1c1c1c#,bold] PREFIX #[default] ,}#[fg=#1c1c1c]%Y-%m-%d %H:%M "
    '';
  };
}
