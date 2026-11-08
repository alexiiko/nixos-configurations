{ pkgs, ... }:

let
  # ZapFast, a native WhatsApp client (Rust/egui). The AppImage is pinned by
  # hash from the upstream release, so the app is reproducible from the flake
  # alone (unlike Helium, which is picked up from ~/Applications). To update:
  # bump `version` and the hash from upstream's packaging-checksums.txt.
  version = "0.21.1";
  appimage = pkgs.fetchurl {
    url = "https://github.com/crmne/zapfast/releases/download/v${version}/zapfast-${version}-x86_64.AppImage";
    hash = "sha256-C+YlVb98l2x1XDyM1yeK83w2UDl09f8D4tUopNnOcwg=";
  };
  zapfast = pkgs.writeShellScriptBin "zapfast" ''
    exec ${pkgs.appimage-run}/bin/appimage-run ${appimage} "$@"
  '';
in
{
  home.packages = [ zapfast ];
}
