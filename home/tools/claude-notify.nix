{ pkgs, ... }:

# Claude Code hooks -> quickshell toast. `claude-notify start` (UserPromptSubmit)
# stamps the prompt time, `claude-notify stop` (Stop) pops the notification:
# title "tmux session | window", body = first answer line + elapsed time.
# Hooks themselves live in ~/.claude/settings.json (not nix-managed).
let
  logo = ./claude-notify/claude-logo.png;
  script = pkgs.writeScriptBin "claude-notify" ''
    #!${pkgs.python3}/bin/python3
    import json, os, subprocess, sys, time

    MAX_BODY = 80
    data = json.load(sys.stdin)
    stamp = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), f"claude-start-{data.get('session_id', 'x')}")

    if sys.argv[1:] == ["start"]:
        open(stamp, "w").write(str(time.time()))
        sys.exit(0)

    def last_answer():
        if data.get("last_assistant_message"):
            return data["last_assistant_message"]
        # older versions: dig the last assistant text out of the transcript
        try:
            lines = open(data["transcript_path"]).read().splitlines()
        except Exception:
            return ""
        for line in reversed(lines):
            try:
                e = json.loads(line)
            except Exception:
                continue
            if e.get("type") != "assistant":
                continue
            texts = [c.get("text", "") for c in e.get("message", {}).get("content", []) if c.get("type") == "text"]
            if any(t.strip() for t in texts):
                return "\n".join(texts)
        return ""

    first = next((l.strip().lstrip("#").strip() for l in last_answer().splitlines() if l.strip()), "Fertig")
    if len(first) > MAX_BODY:
        first = first[: MAX_BODY - 3].rstrip() + "..."

    elapsed = ""
    try:
        s = int(time.time() - float(open(stamp).read()))
        elapsed = f"{s // 60}m {s % 60}s" if s >= 60 else f"{s}s"
    except Exception:
        pass

    title = "Claude Code"
    pane = os.environ.get("TMUX_PANE")
    if os.environ.get("TMUX") and pane:
        r = subprocess.run(["${pkgs.tmux}/bin/tmux", "display-message", "-p", "-t", pane, "#S | #W"], capture_output=True, text=True)
        title = r.stdout.strip() or title

    esc = lambda s: s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    body = esc(first) + (f"<br>{elapsed}" if elapsed else "")
    subprocess.run(["${pkgs.libnotify}/bin/notify-send", "-a", "Claude Code",
                    "-h", "string:image-path:file://${logo}", esc(title), body], check=False)
  '';
in
{
  home.packages = [ script ];
}
