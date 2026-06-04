{ config, pkgs, inputs, ... }:

{
  imports = [
    ./home/default.nix
    ./home/packages.nix
  ];
}
