#!/usr/bin/env bash
# Area screenshot -> ~/Pictures/screenshots + clipboard.
#
# Done as a script, not a pipeline, because `grim ... | tee file-$(date).png`
# expands both ends concurrently: tee creates the file the moment the bind is
# pressed, so a cancelled selection leaves an empty (renders as white) PNG
# behind and the next attempt adds a second file.
set -uo pipefail

DIR="$HOME/Pictures/screenshots"

# Capture the whole screen *before* slurp: its overlay takes the pointer, so
# anything hover-dependent (tooltips, hovered buttons) would vanish. The
# frozen frame (no cursor) is cropped to the selection afterwards.
full=$(mktemp -t screenshot-full-XXXXXX.png)
tmp=$(mktemp -t screenshot-XXXXXX.png)
trap 'rm -f "$full" "$tmp"' EXIT
grim -s 2 -t png "$full" || exit 1

# show the frozen frame under slurp so the selection matches the capture
qs ipc call -- freeze show "$full" >/dev/null 2>&1
geom=$(slurp -b 00000080 -w 0)
qs ipc call freeze hide >/dev/null 2>&1
[ -n "$geom" ] || exit 0                   # cancelled: nothing written
# "x,y wxh" in logical px; the capture is at scale 2
read -r x y w h <<< "$(echo "$geom" | tr ',x' '  ')"
crop="$((w*2))x$((h*2))+$((x*2))+$((y*2))"

mkdir -p "$DIR"
if ! magick "$full" -crop "$crop" +repage "$tmp"; then
  notify-send -a "Screenshot" -u critical "Screenshot failed" "could not crop the capture" 2>/dev/null
  exit 1
fi
[ -s "$tmp" ] || { notify-send -a "Screenshot" -u critical "Screenshot failed" "Empty capture" 2>/dev/null; exit 1; }

out="$DIR/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"
mv "$tmp" "$out"
trap - EXIT; rm -f "$full"
wl-copy -t image/png < "$out"
