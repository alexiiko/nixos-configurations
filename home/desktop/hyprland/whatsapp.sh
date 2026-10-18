#!/usr/bin/env bash
# Toggle WhatsApp (ZapFast) from the keyboard, like the sidebar button does:
# start it if it is not running (the window rule drops it on special:whatsapp),
# then show/hide that special workspace through the stack so other special
# workspaces underneath survive.
set -u
here=$(dirname "$(readlink -f "$0")")

hyprctl clients -j | grep -q '"class": "zapfast"' || "$here/launch-entry.sh" whatsapp
exec "$here/special-stack.sh" whatsapp
