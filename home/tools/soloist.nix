{ pkgs, ... }:

# Spotify Soloist, Spotify's official headless Connect receiver. It runs the
# same playback engine as the official apps, so it gets audio keys that
# librespot (Spotifast) is refused — Spotifast stays the UI, Soloist plays.
#
# Secrets and binary stay OUT of the repo and the nix store on purpose:
#   - the API key lives in ~/.config/soloist/env (chmod 600), loaded through
#     EnvironmentFile; soloist only accepts it via -k, so it is visible in
#     `ps` on this machine — acceptable for a single-user desktop
#   - the binary is user-managed in ~/.local/bin: upstream builds expire
#     ~90 days after release (soloist exits 10), so it must not be pinned in
#     the store. Update with:
#       curl -fsSL -o /tmp/soloist.tar.gz https://soloist-builds.spotifycdn.com/soloist_release_x86_64.tar.gz
#       tar -xzf /tmp/soloist.tar.gz -C /tmp && install -m 755 /tmp/soloist ~/.local/bin/soloist
#     then `systemctl --user restart soloist`.
# The unit runs --verbose and a loopback-only WebSocket API so `soloist ctl`
# works as a neutral controller and playback faults show up in the journal.
#
# Two NixOS quirks this unit fixes (without them Soloist silently plays into
# a dummy driver — "AdvanceStuck: audio_driver"):
#   - it dlopens libpipewire at runtime, which only exists in the nix store,
#     so LD_LIBRARY_PATH points it there
#   - it wants pipewire's client.conf in a standard location, and
#     /etc/pipewire is empty on NixOS, so the stock one is linked into the
#     home config
let
  pipewireLib = "${pkgs.pipewire}/lib";

  # Reset a broken Connect login: the device picker spins and fails to
  # connect, and the journal shows session_auth_info_not_found. Wipes the
  # stored state and restarts the daemon; then close and reopen the Spotify
  # app and pick "Soloist" again.
  relogin = pkgs.writeShellScriptBin "soloist-relogin" ''
    set -eu
    systemctl --user stop soloist
    rm -rf "$HOME/.local/share/soloist"
    systemctl --user start soloist
    echo "Soloist reset — close and reopen the Spotify app, then connect to 'Soloist'."
  '';
in
{
  home.packages = [ relogin ];

  home.file.".config/pipewire/client.conf".source = "${pkgs.pipewire}/share/pipewire/client.conf";

  systemd.user.services.soloist = {
    Unit = {
      Description = "Spotify Soloist Connect receiver (official playback engine)";
      After = [ "pipewire.service" ];
      # an expired build exits 10 and would otherwise restart forever
      StartLimitIntervalSec = 600;
      StartLimitBurst = 5;
    };
    Service = {
      EnvironmentFile = "%h/.config/soloist/env";
      Environment = [ "LD_LIBRARY_PATH=${pipewireLib}" ];
      ExecStart = "%h/.local/bin/soloist --device-name Soloist --api-key \${SOLOIST_API_KEY} --verbose -w 127.0.0.1:0 --data-dir %h/.local/share/soloist";
      StateDirectory = "soloist";   # not used for data: --data-dir pins it so
                                    # `soloist ctl` finds the same pid/ws files
      CacheDirectory = "soloist";
      Restart = "on-failure";
      RestartSec = 10;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
