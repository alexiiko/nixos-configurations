{ config, pkgs, ... }:

{
  programs.nodejs = {
    enable = true;
    package = pkgs.nodejs;
  };

  home.packages = with pkgs; [
    nodejs
  ];

  # Global npm Konfiguration
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin"
  ];

  # .npmrc Datei anlegen
  home.file.".npmrc".text = ''
    prefix=~/.npm-global
  '';
}
