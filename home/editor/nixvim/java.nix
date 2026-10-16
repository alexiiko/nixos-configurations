{ pkgs, ... }:

# nvim-java (nixpkgs 4.1.2) with zero runtime downloads. That release
# ignores the documented `path`/`auto_install` tool pins and installs
# anything missing into pkgm.Manager.packages_root at startup instead.
# So point packages_root at a store farm pre-seeded with the expected
# <name>/<version> layout: is_installed() then short-circuits every
# download. jdtls is registered via vim.lsp.config and enabled below, so
# ./lsp.nix must not also configure the jdtls server.
# ponytail: the farm dir names are nvim-java's pinned defaults and
# packages_root is an internal class field — a plugin update that moves
# either falls back to downloading; re-check then. Spring Boot is off
# (spring-boot-nvim not in nixpkgs); re-enable both together if needed.
let
  javaPkgs = pkgs.runCommand "nvim-java-packages" { } ''
    mkdir -p $out/jdtls $out/lombok $out/java-test/0.43.2 $out/java-debug/0.58.3
    ln -s "${pkgs.jdt-language-server}/share/java/jdtls" $out/jdtls/1.54.0
    ln -s "${pkgs.lombok}/share/java" $out/lombok/1.18.42
    ln -s "${pkgs.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test" $out/java-test/0.43.2/extension
    ln -s "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug" $out/java-debug/0.58.3/extension
  '';
in
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      nvim-java
      nui-nvim
      nvim-dap
    ];

    extraConfigLuaPost = ''
      require('pkgm.manager').packages_root = "${javaPkgs}"
      require('java').setup({
        -- version dir names, must match the farm above
        jdtls = { version = '1.54.0' },
        lombok = { version = '1.18.42' },
        java_test = { version = '0.43.2' },
        java_debug_adapter = { version = '0.58.3' },
        jdk = { auto_install = false },          -- system java (jdk21) from PATH
        spring_boot_tools = { enable = false },
      })
      vim.lsp.enable('jdtls')
    '';
  };
}
