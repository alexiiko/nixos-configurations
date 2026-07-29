{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "ws" ''
      set -euo pipefail
      dir="$PWD"
      name="$(basename "$dir" | tr '.' '_')"

      # Restore saved sessions first, otherwise a post-reboot `ws` builds a
      # fresh 3-window session and the next detach-save overwrites the layout.
      tmux-load >/dev/null 2>&1 || true

      if ${pkgs.tmux}/bin/tmux has-session -t "$name" 2>/dev/null; then
        exec ${pkgs.tmux}/bin/tmux attach -t "$name"
      fi

      ${pkgs.tmux}/bin/tmux new-session -d -s "$name" -n neovim -c "$dir"
      ${pkgs.tmux}/bin/tmux new-window  -t "$name" -n term    -c "$dir"
      ${pkgs.tmux}/bin/tmux new-window  -t "$name" -n ai      -c "$dir"
      ${pkgs.tmux}/bin/tmux select-window -t "$name":neovim
      exec ${pkgs.tmux}/bin/tmux attach -t "$name"
    '')
  ];
}
