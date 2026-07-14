#!/usr/bin/env bash

# ============================================
# Workspace 1 - WhatsApp + Google Calendar
# ============================================
hyprctl dispatch workspace 1
hyprctl dispatch exec "appimage-run '/home/alex/Applications/helium-0.11.5.1-x86_64.AppImage' --app='https://web.whatsapp.com'"
sleep 1.5

hyprctl dispatch workspace 1
hyprctl dispatch exec "appimage-run '/home/alex/Applications/helium-0.11.5.1-x86_64.AppImage' --app='https://calendar.google.com/calendar/u/0/r'"
sleep 1.5

# ============================================
# Workspace 2 - Helium Browser
# ============================================
hyprctl dispatch workspace 2
hyprctl dispatch exec "appimage-run '/home/alex/Applications/helium-0.11.5.1-x86_64.AppImage'"
sleep 1.5

# ============================================
# Workspace 3 - Antigravity
# ============================================
hyprctl dispatch workspace 3
hyprctl dispatch exec "/etc/profiles/per-user/alex/bin/code"
sleep 1.5

# ============================================
# Workspace 4 - Obsidian
# ============================================
hyprctl dispatch workspace 4
hyprctl dispatch exec "/etc/profiles/per-user/alex/bin/obsidian"
sleep 1.5

# ============================================
# Workspace 5 - Notion
# ============================================
hyprctl dispatch workspace 5
hyprctl dispatch exec "/etc/profiles/per-user/alex/bin/claude"
