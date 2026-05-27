{ config, ... }:

{
  # === NPM Global Configuration ===
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin"
  ];

  # .npmrc anlegen
  home.file.".npmrc".text = ''
    prefix=~/.npm-global
  '';
}
