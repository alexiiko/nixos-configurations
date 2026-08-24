{ pkgs, ... }:

{
  programs.nixvim.extraPackages = with pkgs; [
    go                   # provides gofmt
    prettier             # astro, html, css, svelte
    ruff                 # python format + lint
    rustfmt              # rust
    typstyle             # typst
    clang-tools          # clang-format for c
    google-java-format   # java
    shfmt                # bash
  ];

  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      settings = {
        ensure_installed = [
          "bash" "c" "diff" "html" "css" "lua" "luadoc"
          "markdown" "markdown_inline" "query" "vim" "vimdoc"
          "go" "astro" "python" "svelte" "rust" "java" "typst"
        ];
        auto_install = false;
        highlight = {
          enable = true;
          additional_vim_regex_highlighting = [ "ruby" ];
        };
      };
      # Native (modern nvim-treesitter main branch) indentation options.
      indent = {
        enable = true;
        disable = [ "ruby" ];
      };
    };

    lsp = {
      enable = true;
      inlayHints = true;
      luaConfig.post = ''
        vim.o.winborder = "rounded"
        vim.diagnostic.config({
          float = { border = "rounded", source = true },
          virtual_text = true,
          severity_sort = true,
        })
      '';
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
        tinymist = {
          enable = true;
          settings = {
            # conform + typstyle owns formatting; don't let the LSP fight it.
            formatterMode = "disable";
            # Preview renders live, so don't drop a PDF next to the source on save.
            exportPdf = "never";
          };
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
          typst = [ "typstyle" ];
          c = [ "clang_format" ];
          java = [ "google-java-format" ];
          sh = [ "shfmt" ];
          bash = [ "shfmt" ];
        };
      };
    };

    # Live preview in the browser. The nixvim module points the plugin at the
    # tinymist/websocat from the store, so it never tries to download binaries.
    # No open_cmd: fall back to the system default browser handler.
    typst-preview.enable = true;

    luasnip.enable = true;

    blink-cmp = {
      enable = true;
      settings = {
        keymap.preset = "enter";
        appearance.nerd_font_variant = "mono";
        completion = {
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
            window.border = "rounded";
          };
          menu.border = "rounded";
        };
        sources = {
          default = [ "lsp" "path" "snippets" "lazydev" ];
          providers.lazydev = {
            module = "lazydev.integrations.blink";
            score_offset = 100;
          };
        };
        snippets.preset = "luasnip";
        fuzzy.implementation = "lua";
        signature = {
          enabled = true;
          trigger = {
            # Defaults only show the signature at the instant "(" is typed.
            show_on_insert = true;   # re-entering an existing call shows it again
            show_on_keyword = true;  # keep it up while typing argument names
          };
          window = {
            border = "rounded";
            show_documentation = true;  # off by default; this is the parameter help
          };
        };
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
