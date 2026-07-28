{ ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
    # Silence the "loading .envrc" banner on every cd.
    config.global.hide_env_diff = true;
  };
}
