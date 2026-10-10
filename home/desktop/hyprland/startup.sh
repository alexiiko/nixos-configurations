#!/usr/bin/env bash

# ============================================
# Workspace 1 - WhatsApp + Google Calendar
# ============================================
hyprctl dispatch workspace 1
hyprctl dispatch exec "helium --app='https://web.whatsapp.com'"
sleep 1.5

hyprctl dispatch workspace 1
hyprctl dispatch exec "helium --app='https://calendar.google.com/calendar/u/4/r'"
sleep 1.5

# ============================================
# Workspace 2 - Helium Browser
# ============================================
hyprctl dispatch workspace 2
hyprctl dispatch exec "helium"
sleep 1.5

# ============================================
# Workspace 3 - Kitty
# ============================================
hyprctl dispatch workspace 3
hyprctl dispatch exec "/etc/profiles/per-user/alex/bin/kitty"
sleep 1.5

# ============================================
# Workspace 4 - Obsidian
# ============================================
hyprctl dispatch workspace 4
hyprctl dispatch exec "/etc/profiles/per-user/alex/bin/obsidian"
sleep 1.5

# ============================================
# Workspace 5 - Claude Desktop
# ============================================
hyprctl dispatch workspace 5
hyprctl dispatch exec "/run/current-system/sw/bin/claude-desktop --enable-features=UseOzonePlatform,WaylandWindowDecorations,WaylandFractionalScaleV1 --ozone-platform=wayland --enable-wayland-ime"
