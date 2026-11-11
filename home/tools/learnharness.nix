{ pkgs, ... }:

# LearnHarness (Electron, "an agent harness for learning"), upstream
# github.com/amosblomqvist/learnharness. The AppImage is pinned by hash
# from the upstream release (byte-identical to the local file), so the app
# is reproducible from the flake alone. GitHub rejects git files over
# 100 MB, so the 179 MB AppImage cannot live in the repo. To update: bump
# `version` and the hash from the release asset. --no-sandbox is what
# upstream's own desktop entry passes; Electron needs it on NixOS.
let
  version = "0.6.0";
  appimage = pkgs.fetchurl {
    url = "https://github.com/amosblomqvist/learnharness/releases/download/v${version}/LearnHarness-${version}-x86_64.AppImage";
    hash = "sha256-6wvFKAGIOEVsWwT0+uBaqup5T5n/J1bMZ7pa5KIjJF0=";
  };
  learnharness = pkgs.writeShellScriptBin "learnharness" ''
    exec ${pkgs.appimage-run}/bin/appimage-run ${appimage} --no-sandbox "$@"
  '';
in
{
  home.packages = [ learnharness ];
}
