{ ... }:

{
  programs.waybar = {
    enable = true;

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Noto Sans", sans-serif;
        font-size: 13px;
        font-weight: 500;
      }
      window#waybar {
        background: transparent;
        color: #ffffff;
      }
    '';

    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        height = 16;
        spacing = 0;
        modules-left = [ "hyprland/workspaces" ];
        modules-right = [ "pulseaudio" "network" "battery" "clock" ];

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
        };

        clock = {
          format = "{:%H:%M}";
          tooltip-format = "{:%d. %B %Y}";
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "";
          on-click = "pavucontrol";
        };
      };
    };
  };
}
