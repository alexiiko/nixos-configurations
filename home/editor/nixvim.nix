{ config, pkgs, ... }:

{

  programs.nixvim = {
    enable = true;

    opts = {
      number = true;
      relativenumber = true;
      clipboard = "unnamedplus";
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      swapfile = false;
      backup = false;
      undofile = true;
      hlsearch = false;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
    };

    colorscheme = "ayu-light"; 

    colorschemes.ayu = {
      enable = true;
      settings = {
      	mirage = true;
      };
    };
  };
}
