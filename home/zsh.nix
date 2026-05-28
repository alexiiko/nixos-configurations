{ ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    history = {
      size = 10000;
      save = 10000;
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
    };

    shellAliases = {
      copy = "wl-copy";
      paste = "wl-paste";
      clip  = "wl-copy";

      ls  = "eza --icons --color=always";
      ll  = "eza -l --icons --color=always --header";
      la  = "eza -la --icons --color=always --header";
      lt  = "eza --tree --icons --color=always";
      lla = "eza -la --icons --color=always --header";
    };

    initExtra = ''
      # Oh My Posh Prompt laden
      eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/theme.omp.json)"

      # Deine Copy-Funktionen bleiben erhalten
      function copy-last {
        print -z $history[$((HISTCMD-1))] | wl-copy
        echo -e "\033[32mLetzter Befehl kopiert ✅\033[0m"
      }
      function copy-cmd {
        "$@" | tee /dev/fd/2 | wl-copy
      }
      alias lastcopy="copy-last"
      alias cl="copy-cmd"

      bindkey '^[[67;5u' copy-last

      setopt autocd
      setopt interactive_comments

      # === PATH Fix für uv + npm ===
      export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"
    '';
  };

  home.sessionPath = [
    "$HOME/.local/bin"    
    "$HOME/.npm-global/bin"
    "$HOME/.cargo/bin"
  ];
}
