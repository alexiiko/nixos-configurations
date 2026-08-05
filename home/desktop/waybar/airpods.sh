#!/usr/bin/env bash
# Waybar module: toggle AirPods Pro connection, report state as JSON.
#   airpods.sh status   -> JSON for waybar
#   airpods.sh toggle   -> connect if down, disconnect if up
set -u

MAC="34:0E:22:67:BE:2D"
NAME="AirPods Pro"
BUSY="${XDG_RUNTIME_DIR:-/tmp}/waybar-airpods.busy"

# Nerd Font glyphs as escapes, so the literal bytes survive any editing tool.
ICON_ON=$(printf '')       # headphones
ICON_OFF=$(printf '\U000F07CE')  # headphones-off
ICON_BUSY=$(printf '')     # refresh

connected() {
  bluetoothctl info "$MAC" 2>/dev/null | grep -q "Connected: yes"
}

# Waybar rereads the module on RTMIN+8, so the icon updates on the click
# instead of waiting out the poll interval.
refresh() { pkill -RTMIN+8 waybar 2>/dev/null || true; }

notify() {
  notify-send -a "AirPods" -i audio-headphones "$@" 2>/dev/null || true
}

case "${1:-status}" in
  status)
    if [ -e "$BUSY" ]; then
      printf '{"text":"%s","class":"busy","tooltip":"%s: working…"}\n' "$ICON_BUSY" "$NAME"
    elif connected; then
      printf '{"text":"%s","class":"connected","tooltip":"%s: connected"}\n' "$ICON_ON" "$NAME"
    else
      printf '{"text":"%s","class":"disconnected","tooltip":"%s: disconnected"}\n' "$ICON_OFF" "$NAME"
    fi
    ;;

  toggle)
    # ponytail: lockfile is also the spinner state, one file does both jobs.
    # Second click while busy is ignored rather than queued.
    if ! (set -o noclobber; : > "$BUSY") 2>/dev/null; then
      exit 0
    fi
    trap 'rm -f "$BUSY"; refresh' EXIT
    refresh

    if connected; then
      if bluetoothctl disconnect "$MAC" >/dev/null 2>&1; then
        notify "$NAME" "Disconnected"
      else
        notify -u critical "$NAME" "Disconnect failed"
      fi
    else
      # powerOnBoot = false, so the adapter is usually off after a boot.
      bluetoothctl power on >/dev/null 2>&1
      if bluetoothctl connect "$MAC" >/dev/null 2>&1; then
        notify "$NAME" "Connected"
      else
        notify -u critical "$NAME" "Connection failed"
      fi
    fi
    ;;
esac
