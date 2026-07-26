{ ... }:

{
  programs.nixvim = {
    keymaps = [
      { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; }
      { mode = "n"; key = "<leader>q"; action.__raw = "vim.diagnostic.setloclist"; options.desc = "Open diagnostic quickfix list"; }
      { mode = "t"; key = "<Esc><Esc>"; action = "<C-\\><C-n>"; options.desc = "Exit terminal mode"; }
      { mode = "n"; key = "<C-h>"; action = "<C-w><C-h>"; options.desc = "Move focus to the left window"; }
      { mode = "n"; key = "<C-l>"; action = "<C-w><C-l>"; options.desc = "Move focus to the right window"; }
      { mode = "n"; key = "<C-j>"; action = "<C-w><C-j>"; options.desc = "Move focus to the lower window"; }
      { mode = "n"; key = "<C-k>"; action = "<C-w><C-k>"; options.desc = "Move focus to the upper window"; }

      { mode = "n"; key = "<leader>e"; action = "<cmd>Neotree toggle<CR>"; options.desc = "Toggle file [E]xplorer"; }
      { mode = "n"; key = "<leader>o"; action = "<cmd>Neotree focus<CR>"; options.desc = "F[o]cus file explorer"; }

      { mode = "n"; key = "<leader>sh"; action = "<cmd>Telescope help_tags<CR>"; options.desc = "[S]earch [H]elp"; }
      { mode = "n"; key = "<leader>sk"; action = "<cmd>Telescope keymaps<CR>"; options.desc = "[S]earch [K]eymaps"; }
      { mode = "n"; key = "<leader>sf"; action = "<cmd>Telescope find_files<CR>"; options.desc = "[S]earch [F]iles"; }
      { mode = "n"; key = "<leader>ss"; action = "<cmd>Telescope builtin<CR>"; options.desc = "[S]earch [S]elect Telescope"; }
      { mode = [ "n" "v" ]; key = "<leader>sw"; action = "<cmd>Telescope grep_string<CR>"; options.desc = "[S]earch current [W]ord"; }
      { mode = "n"; key = "<leader>sg"; action = "<cmd>Telescope live_grep<CR>"; options.desc = "[S]earch by [G]rep"; }
      { mode = "n"; key = "<leader>sd"; action = "<cmd>Telescope diagnostics<CR>"; options.desc = "[S]earch [D]iagnostics"; }
      { mode = "n"; key = "<leader>sr"; action = "<cmd>Telescope resume<CR>"; options.desc = "[S]earch [R]esume"; }
      { mode = "n"; key = "<leader>s."; action = "<cmd>Telescope oldfiles<CR>"; options.desc = "[S]earch Recent Files"; }
      { mode = "n"; key = "<leader>sc"; action = "<cmd>Telescope commands<CR>"; options.desc = "[S]earch [C]ommands"; }
      { mode = "n"; key = "<leader><leader>"; action = "<cmd>Telescope buffers<CR>"; options.desc = "[ ] Find existing buffers"; }
      {
        mode = "n"; key = "<leader>/";
        action.__raw = ''
          function()
            require('telescope.builtin').current_buffer_fuzzy_find(
              require('telescope.themes').get_dropdown { winblend = 10; previewer = false; }
            )
          end
        '';
        options.desc = "[/] Fuzzily search in current buffer";
      }
      {
        mode = "n"; key = "<leader>s/";
        action.__raw = ''
          function()
            require('telescope.builtin').live_grep {
              grep_open_files = true,
              prompt_title = 'Live Grep in Open Files',
            }
          end
        '';
        options.desc = "[S]earch [/] in Open Files";
      }
      {
        mode = "n"; key = "<leader>sn";
        action.__raw = ''
          function()
            require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
          end
        '';
        options.desc = "[S]earch [N]eovim files";
      }
      {
        mode = [ "n" "v" ]; key = "<leader>f";
        action.__raw = ''
          function()
            require('conform').format { async = true, lsp_format = 'fallback' }
          end
        '';
        options.desc = "[F]ormat buffer";
      }
    ];

    autoCmd = [
      {
        event = [ "TextYankPost" ];
        group = "kickstart-highlight-yank";
        callback.__raw = "function() vim.highlight.on_yank() end";
        desc = "Highlight when yanking (copying) text";
      }
    ];

    autoGroups.kickstart-highlight-yank = { clear = true; };
  };
}
