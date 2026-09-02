{ ... }:

{
  programs.nixvim = {
    keymaps = [
      { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; }

      { mode = "i"; key = "<C-BS>"; action = "<C-w>"; options.desc = "Delete word before cursor"; }
      { mode = "i"; key = "<C-h>"; action = "<C-w>"; options.desc = "Delete word before cursor (terminal C-BS)"; }
      { mode = "c"; key = "<C-BS>"; action = "<C-w>"; }
      { mode = "c"; key = "<C-h>"; action = "<C-w>"; }
      { mode = "n"; key = "<leader>q"; action.__raw = "vim.diagnostic.setloclist"; options.desc = "Open diagnostic quickfix list"; }
      { mode = "t"; key = "<Esc><Esc>"; action = "<C-\\><C-n>"; options.desc = "Exit terminal mode"; }
      { mode = "n"; key = "<C-h>"; action = "<C-w><C-h>"; options.desc = "Move focus to the left window"; }
      { mode = "n"; key = "<C-l>"; action = "<C-w><C-l>"; options.desc = "Move focus to the right window"; }
      { mode = "n"; key = "<C-j>"; action = "<C-w><C-j>"; options.desc = "Move focus to the lower window"; }
      { mode = "n"; key = "<C-k>"; action = "<C-w><C-k>"; options.desc = "Move focus to the upper window"; }

      # Screen-line motion only without a count: `5j` must stay a real 5 lines,
      # otherwise it disagrees with the relative line numbers.
      {
        mode = [ "n" "v" ]; key = "j";
        action.__raw = "function() return vim.v.count == 0 and 'gj' or 'j' end";
        options = { expr = true; silent = true; desc = "Down (screen line without count)"; };
      }
      {
        mode = [ "n" "v" ]; key = "k";
        action.__raw = "function() return vim.v.count == 0 and 'gk' or 'k' end";
        options = { expr = true; silent = true; desc = "Up (screen line without count)"; };
      }

      { mode = "n"; key = "<C-Tab>"; action = "<cmd>BufferLineCycleNext<CR>"; options.desc = "Next buffer tab"; }
      { mode = "n"; key = "<C-S-Tab>"; action = "<cmd>BufferLineCyclePrev<CR>"; options.desc = "Prev buffer tab"; }
      { mode = "i"; key = "<C-Tab>"; action = "<Esc><cmd>BufferLineCycleNext<CR>"; options.desc = "Next buffer tab"; }
      { mode = "i"; key = "<C-S-Tab>"; action = "<Esc><cmd>BufferLineCyclePrev<CR>"; options.desc = "Prev buffer tab"; }
      { mode = "n"; key = "<leader>bc"; action = "<cmd>bdelete<CR>"; options.desc = "Close buffer"; }
      { mode = "n"; key = "<leader>bo"; action = "<cmd>BufferLineCloseOthers<CR>"; options.desc = "Close other buffers"; }
      { mode = "n"; key = "<leader>bl"; action = "<cmd>BufferLineCloseRight<CR>"; options.desc = "Close buffers right"; }
      { mode = "n"; key = "<leader>bh"; action = "<cmd>BufferLineCloseLeft<CR>"; options.desc = "Close buffers left"; }

      { mode = "n"; key = "<C-n>"; action = "<cmd>Neotree toggle<CR>"; options.desc = "Toggle file [E]xplorer"; }
      { mode = "n"; key = "<leader>e"; action = "<cmd>Neotree focus<CR>"; options.desc = "Focus file [E]xplorer"; }
      { mode = "n"; key = "<leader>x"; action = "<cmd>bdelete<CR>"; options.desc = "Close current buffer"; }
      {
        mode = "n"; key = "<C-S-c>";
        action.__raw = ''
          function()
            -- In neo-tree copy the directory listing, elsewhere the buffer.
            if vim.bo.filetype ~= "neo-tree" then
              vim.cmd("%y+")
              vim.notify("Copied buffer to clipboard")
              return
            end
            local root
            local ok, mgr = pcall(require, "neo-tree.sources.manager")
            if ok then
              local state = mgr.get_state("filesystem")
              root = state and state.path
            end
            root = root or vim.uv.cwd()
            -- Flags mirror the neo-tree filters: dotfiles shown, gitignored hidden.
            local out = vim.fn.systemlist({ "tree", "-a", "--gitignore", "-I", ".git", root })
            if vim.v.shell_error ~= 0 then
              vim.notify("tree failed: " .. table.concat(out, " "), vim.log.levels.ERROR)
              return
            end
            vim.fn.setreg("+", table.concat(out, "\n"))
            vim.notify("Copied file tree (" .. #out .. " lines)")
          end
        '';
        options.desc = "Copy buffer, or the file tree when in neo-tree";
      }

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
        event = [ "FocusLost" ];
        callback.__raw = "function() if vim.fn.mode():sub(1,1) == 'i' then vim.cmd('stopinsert') end end";
        desc = "Leave insert mode when the window loses focus";
      }
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
