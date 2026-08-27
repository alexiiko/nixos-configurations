#!/usr/bin/env bash
# Map the stylus barrel button (BTN_STYLUS) to a real right mouse button.
#
# Hyprland has no config for this: its only tablet button options cover the
# eraser. Stylus buttons travel over the Wayland tablet protocol, which most
# apps ignore, so the press is synthesised as a pointer button instead.
# Press and release are sent separately, so holding the button holds the click.
set -u

STYLUS_NAME="WCOM0171:00 2D1F:020D Stylus"
RIGHT_DOWN=0x41
RIGHT_UP=0x81

# Resolve by name; event node numbers shift between boots.
stylus_node() {
  awk -v want="$STYLUS_NAME" '
    /^N: Name=/ { name = $0; sub(/^N: Name="/, "", name); sub(/"$/, "", name) }
    /^H: Handlers=/ && name == want {
      for (i = 2; i <= NF; i++) {
        tok = $i; sub(/^Handlers=/, "", tok)
        if (tok ~ /^event[0-9]+$/) { print "/dev/input/" tok; exit }
      }
    }
  ' /proc/bus/input/devices
}

DEV=$(stylus_node)
if [ -z "$DEV" ] || [ ! -r "$DEV" ]; then
  notify-send -a "Pen button" -u critical \
    "Stylus not readable" "Need the 'input' group and a paired stylus." 2>/dev/null
  exit 1
fi

# Release the button if this exits mid-press, so nothing gets stuck down.
trap 'ydotool click "$RIGHT_UP" >/dev/null 2>&1; exit 0' EXIT INT TERM HUP

libinput debug-events --device "$DEV" 2>/dev/null | while IFS= read -r line; do
  case "$line" in
    # Parenthesised so BTN_STYLUS2 (second barrel button) doesn't also match.
    *"(BTN_STYLUS)"*pressed*)  ydotool click "$RIGHT_DOWN" >/dev/null 2>&1 ;;
    *"(BTN_STYLUS)"*released*) ydotool click "$RIGHT_UP"   >/dev/null 2>&1 ;;
  esac
done
