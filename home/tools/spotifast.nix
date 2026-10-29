{ pkgs, ... }:

# Spotifast, a native Spotify client (Rust, upstream in the app's own
# metadata). The AppImage lives in the repo (18 MB, under GitHub's 100 MB
# file cap) so the app is reproducible from the flake; to update, replace
# the file and rebuild.
let
  spotifast = pkgs.writeShellScriptBin "spotifast" ''
    exec ${pkgs.appimage-run}/bin/appimage-run ${./spotifast/spotifast-0.14.2-x86_64.AppImage} "$@"
  '';
in
{
  home.packages = [ spotifast ];
}
