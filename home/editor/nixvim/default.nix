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

    # system palette (home/theme); follows light/dark live
    extraFiles."colors/mono.lua".source = ./mono.lua;
    colorscheme = "mono";
    extraConfigLua = ''
      -- re-apply when the theme flips: `theme` sends SIGUSR1, and focus
      -- catches anything missed while the editor was in the background
      local function retheme()
        local f = io.open(vim.fn.expand("~/.config/theme/mode")); if not f then return end
        local mode = f:read("*l"); f:close()
        if mode ~= vim.o.background then vim.cmd.colorscheme("mono") end
      end
      vim.api.nvim_create_autocmd("Signal", { pattern = "SIGUSR1", callback = retheme })
      vim.api.nvim_create_autocmd("FocusGained", { callback = retheme })
    '';

    extraPackages = with pkgs; [
      stylua
      lua-language-server
      ripgrep
      fd
    ];
  };
}
