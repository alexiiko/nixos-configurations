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

    themes = {
      # Dein normales Theme
      "custom-light" = {
        style = builtins.readFile ./style.css;
      };

      # Neues Theme speziell für das Power-Menü
      "power-menu" = {
        style = ''
          .box-wrapper {
            background-color: #1e1e2e;
            border: 2px solid #89b4fa;
            border-radius: 16px;
            padding: 12px;
          }

          .input {
            background-color: #313244;
            color: #cdd6f4;
            border: 1px solid #89b4fa;
            border-radius: 10px;
            padding: 10px;
          }

          .item-box {
            color: #cdd6f4;
            padding: 10px 14px;
            border-radius: 10px;
          }

          .item-box:hover,
          .item-box:selected {
            background-color: #45475a;
          }
        '';
      };
    };
  };
}
