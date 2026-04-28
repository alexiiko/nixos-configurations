{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    enableAutosuggestions = true;

    shellAliases = {
      copy = "wl-copy";
      paste = "wl-paste";
      clip = "wl-copy";
    };

    initExtra = ''
      # Letzten Befehl ins Clipboard kopieren
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
    '';
  };
}
