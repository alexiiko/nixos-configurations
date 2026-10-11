{ pkgs, ... }:

# Open WebUI ships chat.finished webhooks but no desktop popups. This bridges
# one to notify-send. ponytail: fixed 80-char body cap approximates one
# notification line; upgrade path is measuring the daemon's real pango width.
let
  port = 2021;
  bridge = pkgs.writeScript "openwebui-notify-bridge" ''
    #!${pkgs.python3}/bin/python3
    import json
    import subprocess
    from http.server import BaseHTTPRequestHandler, HTTPServer

    PORT = ${toString port}
    MAX_BODY = 80

    def esc(s):
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

    class Handler(BaseHTTPRequestHandler):
        def do_POST(self):
            n = int(self.headers.get("Content-Length", 0))
            try:
                data = json.loads(self.rfile.read(n) or b"{}")
            except Exception:
                data = {}
            # Two payload shapes: admin instance webhooks send the full event
            # envelope ({event, data: {...}, message}); user notification
            # targets send flat {action, title, message}.
            event_name = str(data.get("event") or "")
            if event_name and event_name not in ("chat.finished", "chat.failed"):
                self._ok()
                return
            inner = data.get("data") if isinstance(data.get("data"), dict) else {}
            title = str(data.get("title") or inner.get("title") or "Open WebUI")
            message = str(inner.get("message") or data.get("message") or "")
            first = next((line.strip() for line in message.splitlines() if line.strip()), "")
            if len(first) > MAX_BODY:
                first = first[: MAX_BODY - 3].rstrip() + "..."
            subprocess.run(
                ["${pkgs.libnotify}/bin/notify-send", "-a", "Open WebUI", esc(title), esc(first)],
                check=False,
            )
            self._ok()

        def _ok(self):
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"ok")

        def log_message(self, *args):
            pass

    HTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
  '';
in
{
  systemd.user.services.openwebui-notify = {
    Unit.Description = "Open WebUI webhook to notify-send bridge";
    Service = {
      ExecStart = "${bridge}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
