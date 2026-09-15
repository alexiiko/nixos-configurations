{ ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 13;
    };
    settings = {
      # colours come from the active theme (see home/theme); `theme` sends
      # SIGUSR1 so running windows reload
      include = "~/.config/theme/kitty.conf";
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

      # Copy the selection AND forward the key, so kitty's own copy still works
      # while nvim can bind <C-S-c> to yank the buffer. zsh binds the escape to
      # a no-op so it doesn't echo "9;6u" at a shell prompt.
      "ctrl+shift+c"    = "combine : copy_to_clipboard : send_text all \\x1b[99;6u";

      # Font zoom in 10% steps. Terminal-level: nvim has no font size of its own.
      "ctrl+plus"       = "change_font_size all *1.1";
      "ctrl+equal"      = "change_font_size all *1.1";
      "ctrl+kp_add"     = "change_font_size all *1.1";
      "ctrl+minus"      = "change_font_size all /1.1";
      "ctrl+kp_subtract" = "change_font_size all /1.1";
      "ctrl+0"          = "change_font_size all 0";
    };
  };
}
