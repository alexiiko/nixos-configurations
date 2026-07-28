{ pkgs, ... }:

{
  home.packages = [
    # Drops the rust devShell template into the current directory and trusts it.
    (pkgs.writeShellScriptBin "nix-rust-init" ''
      set -e
      flake=~/Programming/nixos-config
      if [ -e flake.nix ] || [ -e .envrc ]; then
        # nix flake init refuses to overwrite, so copy explicitly.
        cp "$flake"/templates/rust/{flake.nix,.envrc} .
      else
        nix flake init -t "$flake"#rust
      fi
      direnv allow
    '')
  ];
}
