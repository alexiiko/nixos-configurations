#!/usr/bin/env bash
# launch-entry <name>  — run ~/…/applications/<name>.desktop's Exec line,
# fully detached. Used by hyprland autostart and the quickshell buttons, so
# "how to start app X" lives only in desktop-entries.nix.
#
# Not `gio launch`: inside quickshell it exits 0 without launching. And stdio
# must go to /dev/null, or the app inherits pipes that close behind it and
# dies on SIGPIPE before it shows a window.
set -u
f="/etc/profiles/per-user/alex/share/applications/$1.desktop"
[ -r "$f" ] || { echo "no such entry: $1" >&2; exit 1; }
cmd=$(sed -n 's/^Exec=//p' "$f" | sed 's/ %[a-zA-Z]//g')
exec setsid -f sh -c "$cmd" </dev/null >/dev/null 2>&1
