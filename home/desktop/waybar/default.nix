{ ... }:
{
  programs.waybar = {
    enable = true;
    style = builtins.readFile ./style.css;
    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        height = 28;
        spacing = 4;

        modules-left = [
          "group/power-battery"
          "hyprland/workspaces"
        ];

        modules-center = [
          "clock"
        ];

        modules-right = [
          "group/right-modules"
        ];

        "group/power-battery" = {
          orientation = "inherit";
          modules = [
            "custom/power"
            "battery"
          ];
        };

        "group/right-modules" = { 
          orientation = "inherit";
          modules = [
            "pulseaudio"
            "custom/bluetooth"
            "network"
          ];
        };

        "custom/power" = {
          format = "";
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
          cursor = true;
        };

        clock = {
          format = " {:%d.%m.%Y}";
          format-alt = " {:%H:%M}";
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
