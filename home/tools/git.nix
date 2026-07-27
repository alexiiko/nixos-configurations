{ pkgs, config, ... }:

let
  hooksDir = "${config.xdg.configHome}/git/hooks";
in
{
  programs.git = {
    enable = true;
    extraConfig = {
      core.hooksPath = hooksDir;
    };
  };

  xdg.configFile."git/hooks/post-checkout" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      # Refresh sibling tmux panes in the same worktree after a branch switch,
      # so their shell prompts pick up the new branch.
      [ -z "''${TMUX:-}" ] && exit 0
      # Args: prev_head new_head flag (1 = branch checkout, 0 = file checkout)
      [ "''${3:-0}" = "1" ] || exit 0

      root=$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null) || exit 0
      me="''${TMUX_PANE:-}"

      ${pkgs.tmux}/bin/tmux list-panes -s \
        -F '#{pane_id} #{pane_current_command} #{pane_current_path}' \
      | while read -r pid cmd path; do
          [ "$pid" = "$me" ] && continue
          case "$path" in "$root"|"$root"/*) ;; *) continue ;; esac
          case "$cmd" in zsh|bash|fish|sh|dash)
            ${pkgs.tmux}/bin/tmux send-keys -t "$pid" Enter
          ;; esac
        done
    '';
  };
}
