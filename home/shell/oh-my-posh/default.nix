{ config, pkgs, ... }:

let
  palette = import ../../theme/palette.nix;
  # Colours are palette references; the palette is picked per prompt from
  # $THEME_MODE, which zsh refreshes from the theme's mode file (see zsh.nix).
  theme = builtins.fromJSON (builtins.readFile ./theme.omp.json) // {
    palettes = {
      template = "{{ .Env.THEME_MODE }}";
      list = {
        light = { fg = palette.light.onyx; };
        dark  = { fg = palette.dark.onyx; };
      };
    };
  };
in
{
  home.file.".config/oh-my-posh/theme.omp.json".text = builtins.toJSON theme;

  # Prompt init generated at build time. It embeds the oh-my-posh store path
  # of the same generation, so they die together under nix.gc. The runtime
  # `oh-my-posh init` cache keys on the config only and kept handing out a
  # store path gc had long collected, which broke the prompt on every command.
  home.file.".config/oh-my-posh/init.zsh".source = pkgs.runCommand "omp-init.zsh" { } ''
    export HOME=$TMPDIR
    ${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${config.home.homeDirectory}/.config/oh-my-posh/theme.omp.json > /dev/null
    cp "$HOME"/.cache/oh-my-posh/init.*.zsh $out
    # The init swaps in a transient prompt on every accept-line, and omp's
    # default transient renders as a bare "shell> " line. Keep the normal
    # prompt there instead: the accept-line handlers just reuse the prompt
    # string PS1 already carries, so nothing extra is rendered.
    # ponytail: patching generated output; if omp rewrites these lines the
    # patch silently stops matching and the transient prompt comes back.
    sed -i -e 's/_omp_get_prompt transient --eval/_omp_get_prompt primary --eval/g' \
           -e 's/PS1=$_omp_transient_prompt/PS1=$_omp_primary_prompt/' $out
  '';
}
