{ ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 13;
    };
    settings = {
      background = "#ffffff";
      foreground = "#000000";
      cursor     = "#000000";
      cursor_shape = "block";
      
      window_padding_width = "8";
      confirm_os_window_close = "0";
    };
    keybindings = {
      "ctrl+tab"        = "send_text all \\x1b[9;5u";
      "ctrl+shift+tab"  = "send_text all \\x1b[9;6u";
      "alt+tab"         = "send_text all \\x1b[9;3u";
      "alt+shift+tab"   = "send_text all \\x1b[9;4u";
      # Ctrl+Backspace -> Ctrl+W (word delete). Works in zsh, tmux command-prompt,
      # and TUIs like Claude Code inside tmux without needing per-app CSI-u wiring.
      "ctrl+backspace"  = "send_text all \\x17";
    };
  };
}
