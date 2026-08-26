#!/usr/bin/env bash
# Toggle the built-in display between upright (0) and upside-down (180).
#
# The pen and touchscreen do not follow the output transform on their own here
# (separate devices, see pen-palm-reject.sh), so rotate them explicitly or
# input lands mirrored.
set -u

STYLUS="wcom0171:00-2d1f:020d-stylus"
TOUCH="gxtp7936:00-27c6:0123"

read -r NAME SCALE CUR < <(
  hyprctl monitors -j | python3 -c '
import json, sys
m = json.load(sys.stdin)[0]
print(m["name"], m["scale"], m["transform"])
'
) || { notify-send -a "Rotate" -u critical "Rotate failed" "Could not read monitor state"; exit 1; }

# transform 2 = 180 degrees. Anything non-zero flips back to upright.
if [ "$CUR" -eq 0 ]; then NEW=2; else NEW=0; fi

hyprctl keyword monitor "$NAME,preferred,auto,$SCALE,transform,$NEW" >/dev/null
hyprctl keyword "device[$STYLUS]:transform" "$NEW" >/dev/null
hyprctl keyword "device[$TOUCH]:transform" "$NEW" >/dev/null
