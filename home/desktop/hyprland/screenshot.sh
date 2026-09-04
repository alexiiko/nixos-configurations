#!/usr/bin/env bash
# Area screenshot -> ~/Pictures/screenshots + clipboard.
#
# Done as a script, not a pipeline, because `grim ... | tee file-$(date).png`
# expands both ends concurrently: tee creates the file the moment the bind is
# pressed, so a cancelled selection leaves an empty (renders as white) PNG
# behind and the next attempt adds a second file.
set -uo pipefail

DIR="$HOME/Pictures/screenshots"

geom=$(slurp -b 00000080 -w 0) || exit 0   # cancelled: nothing written
[ -n "$geom" ] || exit 0

mkdir -p "$DIR"
tmp=$(mktemp -t screenshot-XXXXXX.png)
trap 'rm -f "$tmp"' EXIT

if ! grim -g "$geom" -s 2 -t png "$tmp"; then
  notify-send -a "Screenshot" -u critical "Screenshot failed" "grim could not capture the region" 2>/dev/null
  exit 1
fi
[ -s "$tmp" ] || { notify-send -a "Screenshot" -u critical "Screenshot failed" "Empty capture" 2>/dev/null; exit 1; }

out="$DIR/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"
mv "$tmp" "$out"
trap - EXIT
wl-copy -t image/png < "$out"
