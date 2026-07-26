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
      "ctrl+tab" = "send_text all \\x1b[9;5u";
      "ctrl+shift+tab" = "send_text all \\x1b[9;6u";
    };
    extraConfig = ''
      # Enable kitty extended keyboard protocol (CSI u)
      # Lets Ctrl+Tab, Ctrl+Backspace etc pass through as distinct codes
    '';
  };
}
