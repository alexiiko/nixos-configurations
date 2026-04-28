{ ... }:
{
  programs.waybar = {
    enable = true;

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Noto Sans", sans-serif;
        font-size: 14px;
        font-weight: 500;
      }

      window#waybar {
        background: transparent;  /* Leicht weißer Hintergrund */
      }

      #workspaces button {
        color: #000000;
        padding: 0 5px;
	margin: 0 2px;
	min-width: 28px;
      }

      #workspaces button.active {
        color: #ffffff;
        background: rgba(0, 0, 0, 0.4);
      }

      #pulseaudio, #network, #battery, #clock, #custom-bluetooth {
        padding: 0 12px;
      }

      /* Hover-Effekt auf allen Modulen */
      #pulseaudio:hover, #network:hover, #battery:hover, #clock:hover, #custom-bluetooth:hover {
        background: rgba(0, 0, 0, 0.2);
      }
    '';

    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        height = 16;           # etwas höher → schöner
        spacing = 4;

        modules-left = [ "hyprland/workspaces" ];
        modules-right = [ "pulseaudio" "custom/bluetooth" "network" "battery" "clock" ];

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
        };

        clock = {
          format = "{:%H:%M}";
          tooltip-format = "{:%A, %d. %B %Y}";
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "󰝟";
          format-icons = [ "" "" "" ];
          on-click = "pavucontrol";
        };

        network = {
          format-wifi = "";
          format-ethernet = "{ipaddr} ";
          format-disconnected = "⚠";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          on-click = "nm-connection-editor";
        };

        battery = {
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-icons = [ "" "" "" "" "" ];
          states = {
            warning = 30;
            critical = 15;
          };
        };

        "custom/bluetooth" = {
          format = "";
          on-click = "blueman-manager";
          tooltip = false;
        };
      };
    };
  };
}
