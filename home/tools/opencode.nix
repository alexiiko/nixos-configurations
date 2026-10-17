{ ... }:

{
  # opencode config + notify plugin. The package.json/node_modules stay
  # out of nix on purpose: plugin SDK deps, managed with npm in place.
  xdg.configFile."opencode/opencode.jsonc" = {
    force = true;
    source = ./opencode/opencode.jsonc;
  };
  xdg.configFile."opencode/plugins/notify.ts" = {
    force = true;
    source = ./opencode/plugins/notify.ts;
  };
}
