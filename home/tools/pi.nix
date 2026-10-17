{ pkgs, config, ... }:

# Pi coding agent (pi.dev) — minimal harness with built-in MCP.
# Packaged from the npm tarball (dist/ ships prebuilt); the committed
# package-lock.json pins the dependency closure for npmDeps. Runtime
# state (extensions, pi packages, auth, sessions) lives in ~/.pi/agent
# and is pi-managed on purpose — `pi update` is not used on NixOS,
# update via this flake instead.
let
  version = "1.3.0";

  pi = pkgs.buildNpmPackage {
    pname = "pi-coding-agent";
    inherit version;

    src = pkgs.runCommand "pi-coding-agent-${version}-src" { } ''
      mkdir -p $out
      tar xf ${pkgs.fetchurl {
        url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
        hash = "sha256-rieF6HC4GoyOHURRCle17gv8npdGeawvqq2kqr7j08A=";
      }} -C $out --strip-components=1
      cp ${./pi/package-lock.json} $out/package-lock.json
    '';

    npmDepsHash = "sha256-acuSUlO1yeD4CePBSGRAZvAhKxtJAmT1xRMr3V2CNCk=";

    dontNpmBuild = true;

    meta = {
      description = "Minimal, extensible coding agent harness";
      homepage = "https://pi.dev";
      license = pkgs.lib.licenses.mit;
      mainProgram = "pi";
    };
  };
in
{
  home.packages = [ pi ];

  # Xiaomi gateway (OpenAI-compatible) + mimo models. apiKey runs at request
  # time and reads the key from opencode's auth store, so no secret lands in
  # the nix store. See ~/.local/share/opencode/auth.json.
  home.file.".pi/agent/models.json".text = builtins.toJSON {
    "$schema" = "https://pi.dev/schemas/models.schema.json";
    providers.xiaomi-token-plan-ams = {
      baseUrl = "https://token-plan-ams.xiaomimimo.com/v1";
      api = "openai-completions";
      apiKey = ''!python3 -c "import json;print(json.load(open('/home/alex/.local/share/opencode/auth.json'))['xiaomi-token-plan-ams']['key'])"'';
      models = [
        { id = "mimo-v2.6-pro"; reasoning = true; contextWindow = 1000000; }
        { id = "mimo-v2.6-flash"; reasoning = true; }
      ];
    };
  };

  # MCP servers (pi built-in MCP). Same three as opencode; `exposure =
  # "direct"` declares the tools to the model like opencode does (pi's
  # default hides them behind codemode/tool_search).
  home.file.".pi/agent/mcp.json".text = builtins.toJSON {
    mcpServers = {
      codegraph = {
        command = "codegraph";
        args = [ "serve" "--mcp" ];
        exposure = "direct";
        description = "Code intelligence over an indexed knowledge graph";
      };
      headroom = {
        command = "uv";
        args = [
          "tool" "run" "--from" "headroom-ai" "--with" "mcp<2"
          "python" "-m" "headroom.ccr.mcp_server"
        ];
        exposure = "direct";
        description = "Context compression and retrieval";
      };
    };
  };

  # One rules file, shared with opencode.
  home.file.".pi/agent/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "/home/alex/.config/opencode/AGENTS.md";
}
