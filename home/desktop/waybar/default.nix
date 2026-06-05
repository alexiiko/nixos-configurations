{ ... }:
{
  programs.waybar = {
    enable = true;
    style = builtins.readFile ./style.css;
    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        height = 16;
        spacing = 4;
        modules-left = [ "hyprland/workspaces" ];
        modules-right = [ "pulseaudio" "custom/bluetooth" "network" "battery" "power-profiles-daemon" "clock" ];
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
          # on-click = "nm-connection-editor";
          on-click = "kitty nmtui";
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

        "power-profiles-daemon" = {
          format = "{icon}";
          tooltip-format = "Leistungsmodus: {profile}\nDriver: {driver}";
          tooltip = true;
          format-icons = {
	    "power-saver" = "󰾆";
            "balanced"    = "󰾅";
            "performance" = "󰓅";
          };
        };
      };
    };
  };
}
