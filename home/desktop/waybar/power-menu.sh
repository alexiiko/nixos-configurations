#!/usr/bin/env bash

# Check if the powermenu is already open
if eww -c ~/Programming/nixos-config/home/desktop/waybar/eww active-windows | grep -q 'powermenu'; then
    eww -c ~/Programming/nixos-config/home/desktop/waybar/eww close powermenu
    hyprctl dispatch submap reset
else
    eww -c ~/Programming/nixos-config/home/desktop/waybar/eww open powermenu
    hyprctl dispatch submap powermenu
fi
