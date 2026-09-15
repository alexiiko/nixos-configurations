{ config, ... }:

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
}
