{ config, pkgs, inputs, ... }:

{
  programs.nixvim.nixpkgs.source = inputs.nixpkgs;
  imports = [
    ./home/default.nix
    ./home/packages.nix
  ];
}
