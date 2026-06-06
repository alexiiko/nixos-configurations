#!/usr/bin/env bash

# Menü-Einträge
options="Shutdown\nReboot\nSuspend\nPower Profile: Balanced\nPower Profile: Power Saver\nPower Profile: Performance"

# Walker als dmenu-ähnliches Menü starten
chosen=$(echo -e "$options" | walker --dmenu --prompt "Power Menu")

case "$chosen" in
    "Shutdown")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Suspend")
        systemctl suspend
        ;;
    "Power Profile: Balanced")
        powerprofilesctl set balanced
        ;;
    "Power Profile: Power Saver")
        powerprofilesctl set power-saver
        ;;
    "Power Profile: Performance")
        powerprofilesctl set performance
        ;;
esac
