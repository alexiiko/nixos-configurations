{ config, inputs, ... }:

{
  imports = [ inputs.walker.homeManagerModules.default ];

  programs.walker = {
    enable = true;
    runAsService = true;

    config = {
      theme = "custom-light";
      icons = true;
      hide_quick_activation = true;
      hide_action_hints = true;
      placeholder = "Suche...";
    };

    themes."custom-light".style = builtins.readFile ./style.css;
  };
}
