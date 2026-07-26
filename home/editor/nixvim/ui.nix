{ ... }:

{
  programs.nixvim.plugins = {
    web-devicons.enable = true;
    guess-indent.enable = true;
    fidget.enable = true;
    nvim-autopairs.enable = true;

    bufferline = {
      enable = true;
      settings.options = {
        mode = "buffers";
        diagnostics = "nvim_lsp";
        show_buffer_close_icons = false;
        show_close_icon = false;
        separator_style = "thin";
        always_show_bufferline = true;
        offsets = [
          { filetype = "neo-tree"; text = "File Explorer"; highlight = "Directory"; separator = true; }
        ];
      };
    };

    neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        filesystem = {
          follow_current_file.enabled = true;
          use_libuv_file_watcher = true;
          filtered_items = {
            hide_dotfiles = false;
            hide_gitignored = true;
          };
        };
        window = {
          width = 32;
          mappings = {
            "<space>" = "none";
          };
        };
      };
    };

    gitsigns = {
      enable = true;
      settings.signs = {
        add.text = "+";
        change.text = "~";
        delete.text = "_";
        topdelete.text = "‾";
        changedelete.text = "~";
      };
    };

    which-key = {
      enable = true;
      settings = {
        delay = 0;
        icons.mappings = false;
        spec = [
          { __unkeyed-1 = "<leader>s"; group = "[S]earch"; }
          { __unkeyed-1 = "<leader>t"; group = "[T]oggle"; }
          { __unkeyed-1 = "<leader>h"; group = "Git [H]unk"; mode = [ "n" "v" ]; }
        ];
      };
    };

    todo-comments = {
      enable = true;
      settings.signs = false;
    };

    telescope = {
      enable = true;
      extensions = {
        fzf-native.enable = true;
        ui-select.enable = true;
      };
      settings.defaults.mappings.i = {
        "<C-enter>" = { __raw = "require('telescope.actions.layout').toggle_preview"; };
      };
    };

    mini = {
      enable = true;
      modules = {
        ai = { n_lines = 500; };
        surround = { };
        statusline = { use_icons = true; };
      };
    };
  };
}
