{ pkgs, ... }:

# datalab marker (marker-pdf), the document→markdown converter. The ML stack
# (torch etc.) is too heavy for the store, so the tool itself is installed
# per-user with `uv tool install "marker-pdf[full]" --python 3.12` into
# ~/.local/share/uv/tools/marker-pdf. Its prebuilt torch expects a system
# libstdc++, which NixOS does not ship at the usual paths — these wrappers
# put ours on the loader path (referenced from the store, so gc keeps it).
# The uv-created symlinks in ~/.local/bin are removed so these take
# precedence; reinstalling the tool with uv recreates them, remove again.
let
  toolBin = ".local/share/uv/tools/marker-pdf/bin";
  wrap = name: pkgs.writeShellScriptBin name ''
    export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH
    exec "$HOME/${toolBin}/${name}" "$@"
  '';
in
{
  home.packages = map wrap [ "marker" "marker_single" "marker_gui" "marker_server" ];
}
