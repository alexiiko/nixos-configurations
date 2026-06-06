{ ... }:
{
  programs.waybar = {
    enable = true;
    style = builtins.readFile ./style.css;
    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        height = 28;                    # Etwas höher machen (16 war sehr klein)
        spacing = 8;

        modules-left = [
          "custom/power"
          "battery"
          "hyprland/workspaces"
        ];

        modules-center = [
          "clock"
        ];

        modules-right = [
          "pulseaudio"
          "custom/bluetooth"
          "network"
        ];

        # === Module Konfigurationen ===

        "custom/power" = {
          format = "";                    # Power Symbol
          on-click = "bash -c 'nohup $HOME/Programming/nixos-config/home/desktop/waybar/power-menu.sh > /dev/null 2>&1 &'";
          tooltip = false;
        };

        battery = {
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-icons = [ "" "" "" "" "" ];
        };

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
        };

        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%d.%m.%Y}";
          tooltip-format = "{:%A, %d. %B %Y}";
          on-click = "mode";
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "󰝟";
          format-icons = [ "" "" "" ];
          on-click = "pavucontrol";
        };

        "custom/bluetooth" = {
          format = "";
          on-click = "blueman-manager";
          tooltip = false;
        };

        network = {
          format-wifi = "";
          format-ethernet = "{ipaddr} ";
          format-disconnected = "⚠";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          on-click = "kitty nmtui";
        };
      };
    };
  };
}
