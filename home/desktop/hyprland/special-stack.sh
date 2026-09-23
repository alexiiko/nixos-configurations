#!/usr/bin/env bash
# Toggle a special workspace, but keep the ones underneath.
#
# Hyprland shows at most one special workspace per monitor: opening a second
# hides the first and it does not come back. This keeps a stack of what was
# open, so closing the top one reveals the previous instead of the plain
# workspace underneath.
set -uo pipefail

name="$1"
stack="${XDG_RUNTIME_DIR:-/tmp}/hypr-special-stack"
touch "$stack"

current=$(hyprctl monitors -j | python3 -c \
  'import json,sys; print((json.load(sys.stdin)[0]["specialWorkspace"]["name"] or "").removeprefix("special:"))')

drop() { grep -vx "$1" "$stack" > "$stack.tmp" || true; mv "$stack.tmp" "$stack"; }   # grep exits 1 on empty
top()  { tail -n1 "$stack"; }

if [ "$current" = "$name" ]; then
  hyprctl dispatch togglespecialworkspace "$name"     # close it
  drop "$name"
  prev=$(top)
  [ -n "$prev" ] && hyprctl dispatch togglespecialworkspace "$prev"
else
  # this one goes on top; anything below stays remembered
  drop "$name"
  echo "$name" >> "$stack"
  hyprctl dispatch togglespecialworkspace "$name"
fi
