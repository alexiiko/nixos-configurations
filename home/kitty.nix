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
  };
}
