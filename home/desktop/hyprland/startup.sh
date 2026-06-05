#!/usr/bin/env bash

# Workspace 1
hyprctl dispatch exec "[workspace 1 silent] appimage-run /home/alex/Applications/helium-0.11.5.1-x86_64.AppImage --app=https://web.whatsapp.com"
hyprctl dispatch exec "[workspace 1 silent] appimage-run /home/alex/Applications/helium-0.11.5.1-x86_64.AppImage --app=https://calendar.google.com/calendar/u/0/r"

# Workspace 2
hyprctl dispatch exec "[workspace 2 silent] appimage-run /home/alex/Applications/helium-0.11.5.1-x86_64.AppImage"

# Workspace 3
hyprctl dispatch exec "[workspace 3 silent] /etc/profiles/per-user/alex/bin/antigravity"

# Workspace 4
hyprctl dispatch exec "[workspace 4 silent] /etc/profiles/per-user/alex/bin/obsidian"

# Workspace 5
hyprctl dispatch exec "[workspace 5 silent] appimage-run /home/alex/Applications/helium-0.11.5.1-x86_64.AppImage --app=https://www.notion.so/"
