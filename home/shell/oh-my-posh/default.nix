{ config, ... }:

{
  home.file.".config/oh-my-posh/theme.omp.json".source =
    ./theme.omp.json;

  # Oh My Posh initialisieren (in Zsh)
  programs.zsh.initExtra = ''
    eval "$(oh-my-posh init zsh --config ${config.home.homeDirectory}/.config/oh-my-posh/theme.omp.json)"
  '';
}
