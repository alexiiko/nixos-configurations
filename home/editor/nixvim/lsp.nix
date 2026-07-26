{ pkgs, ... }:

{
  programs.nixvim.extraPackages = with pkgs; [
    # Formatters
    gofmt                # go (comes with go toolchain, but explicit here)
    nodePackages.prettier # astro, html, css, svelte
    ruff                 # python format + lint
    rustfmt              # rust
    clang-tools          # clang-format for c
    google-java-format   # java
    shfmt                # bash
    # Extra tooling
    go
  ];

  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      settings = {
        ensure_installed = [
          "bash" "c" "diff" "html" "css" "lua" "luadoc"
          "markdown" "markdown_inline" "query" "vim" "vimdoc"
          "go" "astro" "python" "svelte" "rust" "java"
        ];
        auto_install = false;
        highlight = {
          enable = true;
          additional_vim_regex_highlighting = [ "ruby" ];
        };
        indent = {
          enable = true;
          disable = [ "ruby" ];
        };
      };
    };

    lsp = {
      enable = true;
      inlayHints = true;
      servers = {
        lua_ls = {
          enable = true;
          settings.Lua.completion.callSnippet = "Replace";
        };
        gopls.enable = true;
        astro.enable = true;
        html.enable = true;
        cssls.enable = true;
        pyright.enable = true;
        svelte.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
        clangd.enable = true;
        jdtls.enable = true;
        bashls.enable = true;
      };
      keymaps.lspBuf = {
        "grn" = "rename";
        "gra" = "code_action";
        "grr" = "references";
        "gri" = "implementation";
        "grd" = "definition";
        "grD" = "declaration";
        "grt" = "type_definition";
        "gO" = "document_symbol";
        "gW" = "workspace_symbol";
      };
    };

    conform-nvim = {
      enable = true;
      settings = {
        notify_on_error = false;
        format_on_save.__raw = ''
          function(bufnr)
            local disable_filetypes = { c = true, cpp = true }
            if disable_filetypes[vim.bo[bufnr].filetype] then
              return nil
            end
            return { timeout_ms = 500, lsp_format = 'fallback' }
          end
        '';
        formatters_by_ft = {
          lua = [ "stylua" ];
          go = [ "gofmt" ];
          astro = [ "prettier" ];
          html = [ "prettier" ];
          css = [ "prettier" ];
          svelte = [ "prettier" ];
          python = [ "ruff_format" ];
          rust = [ "rustfmt" ];
          c = [ "clang_format" ];
          java = [ "google-java-format" ];
          sh = [ "shfmt" ];
          bash = [ "shfmt" ];
        };
      };
    };

    luasnip.enable = true;

    blink-cmp = {
      enable = true;
      settings = {
        keymap.preset = "default";
        appearance.nerd_font_variant = "mono";
        completion.documentation.auto_show = false;
        sources = {
          default = [ "lsp" "path" "snippets" "lazydev" ];
          providers.lazydev = {
            module = "lazydev.integrations.blink";
            score_offset = 100;
          };
        };
        snippets.preset = "luasnip";
        fuzzy.implementation = "lua";
        signature.enabled = true;
      };
    };

    lazydev = {
      enable = true;
      settings.library = [
        { path = "\${3rd}/luv/library"; words = [ "vim%.uv" ]; }
      ];
    };
  };
}
