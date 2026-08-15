#!/usr/bin/env bash
# Palm rejection for a laptop where pen and touchscreen are separate devices.
#
# libinput's built-in palm rejection only works when the stylus and the touch
# surface are the same kernel device. Here they are not (Wacom digitizer +
# Goodix panel), so it can't correlate them. This watches the stylus for
# proximity and disables the touchscreen while the pen is near the glass.
set -u

TOUCH_DEV="gxtp7936:00-27c6:0123"
STYLUS_NAME="WCOM0171:00 2D1F:020D Stylus"
GRACE=0.5   # seconds to keep touch off after the pen leaves proximity

touch_enabled() {
  hyprctl keyword "device[$TOUCH_DEV]:enabled" "$1" >/dev/null 2>&1
}

# Never leave the touchscreen disabled if this exits for any reason.
trap 'rc=$?; kill "${pending:-}" 2>/dev/null; touch_enabled true; exit $rc' EXIT INT TERM HUP

# Resolve the stylus event node by name; numbering is not stable across boots.
stylus_node() {
  awk -v want="$STYLUS_NAME" '
    /^N: Name=/ { name = $0; sub(/^N: Name="/, "", name); sub(/"$/, "", name) }
    /^H: Handlers=/ && name == want {
      for (i = 2; i <= NF; i++) {
        tok = $i; sub(/^Handlers=/, "", tok)          # $2 is "Handlers=eventN"
        if (tok ~ /^event[0-9]+$/) { print "/dev/input/" tok; exit }
      }
    }
  ' /proc/bus/input/devices
}

DEV=$(stylus_node)
if [ -z "$DEV" ]; then
  notify-send -a "Palm rejection" -u critical \
    "Stylus not found" "No input device named: $STYLUS_NAME" 2>/dev/null
  exit 1
fi
if [ ! -r "$DEV" ]; then
  notify-send -a "Palm rejection" -u critical \
    "Cannot read $DEV" "User needs to be in the 'input' group (re-login required)." 2>/dev/null
  exit 1
fi

pending=""

# ponytail: parse debug-events text rather than write an evdev client.
# One process, no bindings. Upgrade to python-evdev only if parsing proves flaky.
libinput debug-events --device "$DEV" 2>/dev/null | while IFS= read -r line; do
  case "${line,,}" in
    # out first: an out-line must never fall through to the in-branch
    *proximity-out*)
      [ -n "$pending" ] && kill "$pending" 2>/dev/null
      { sleep "$GRACE"; touch_enabled true; } &
      pending=$!
      ;;
    *proximity-in*)
      [ -n "$pending" ] && kill "$pending" 2>/dev/null
      pending=""
      touch_enabled false
      ;;
  esac
done

touch_enabled true
