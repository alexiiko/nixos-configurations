{ pkgs, ... }:

{
  imports = [
    ./keymaps.nix
    ./ui.nix
    ./lsp.nix
  ];

  programs.nixvim = {
    enable = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
      have_nerd_font = true;
    };

    opts = {
      number = true;
      relativenumber = true;
      mouse = "a";
      showmode = false;
      clipboard = "unnamedplus";
      breakindent = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      signcolumn = "yes";
      updatetime = 250;
      timeoutlen = 300;
      splitright = true;
      splitbelow = true;
      list = true;
      listchars = { tab = "» "; trail = "·"; nbsp = "␣"; };
      inccommand = "split";
      cursorline = true;
      scrolloff = 10;
      confirm = true;
      termguicolors = true;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      autoread = true;
    };

    autoCmd = [
      {
        event = [ "FocusGained" "BufEnter" "CursorHold" "CursorHoldI" ];
        command = "if mode() !~ '\\v(c|r.?|!|t)' && getcmdwintype() == \"\" | checktime | endif";
      }
      {
        event = [ "FileChangedShellPost" ];
        command = "echohl WarningMsg | echo 'File changed on disk. Buffer reloaded.' | echohl None";
      }
    ];

    colorscheme = "ayu-light";
    colorschemes.ayu = {
      enable = true;
      settings.mirage = false;
    };

    extraPackages = with pkgs; [
      stylua
      lua-language-server
      ripgrep
      fd
    ];
  };
}
