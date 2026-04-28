{ config, pkgs, ... }:

{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;

    opts = {
      clipboard = "unnamedplus";
    };

    # Hier kannst du später alles Weitere reinpacken, z.B.:
    # colorscheme = "catppuccin";
    # plugins = [ ... ];
    # extraConfigLua = '' ... '';
  };
}
