{ pkgs, ... }:

{
  xdg.desktopEntries = {
    # Deine bestehenden Web-Apps (bleiben unverändert)
    whatsapp = {
      name = "WhatsApp";
      exec = ''${pkgs.appimage-run}/bin/appimage-run /home/alex/Applications/helium-0.11.5.1-x86_64.AppImage --app=https://web.whatsapp.com'';
      icon = "whatsapp";
      comment = "WhatsApp Web App";
      categories = [ "Network" "InstantMessaging" ];
      terminal = false;
    };

    google-calendar = {
      name = "Google Calendar";
      exec = ''${pkgs.appimage-run}/bin/appimage-run /home/alex/Applications/helium-0.11.5.1-x86_64.AppImage --app=https://calendar.google.com/calendar/u/4/r'';
      icon = "google-calendar";
      comment = "Google Calendar";
      categories = [ "Network" "InstantMessaging" ];
      terminal = false;
    };

    open-webui = {
      name = "Open WebUI";
      exec = ''${pkgs.appimage-run}/bin/appimage-run /home/alex/Applications/helium-0.11.5.1-x86_64.AppImage --app=http://localhost:2020/'';
      icon = "applications-internet";
      comment = "Local Open WebUI";
      categories = [ "Network" ];
      terminal = false;
    };

    # Runs through XWayland. Hyprland draws X apps at native resolution
    # (xwayland:force_zero_scaling), so the app scales itself 2x instead of
    # being stretched, which is what made it blurry.
    onlyoffice-desktopeditors = {
      name = "ONLYOFFICE";
      exec = "onlyoffice-desktopeditors --force-scale=2 %U";
      icon = "onlyoffice-desktopeditors";
      comment = "Office suite";
      categories = [ "Office" ];
      terminal = false;
      mimeType = [ "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                   "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                   "application/vnd.openxmlformats-officedocument.presentationml.presentation"
                   "application/msword" "application/vnd.ms-excel" "application/vnd.ms-powerpoint"
                   "application/vnd.oasis.opendocument.text" "application/vnd.oasis.opendocument.spreadsheet" ];
    };

    suspend = {
      name = "Energie sparen";
      exec = "suspend";
      icon = "energie-sparen";
      comment = "Laptop in den Ruhezustand versetzen";
      categories = [ "System" ];
      terminal = false;
    };

    reboot = {
      name = "Neustarten";
      exec = "reboot";
      icon = "restart";
      comment = "System neu starten";
      categories = [ "System" ];
      terminal = false;
    };

    shutdown = {
      name = "Herunterfahren";
      exec = "shutdown";
      icon = "shutdown";
      comment = "System herunterfahren";
      categories = [ "System" ];
      terminal = false;
    };

    notion = {
      name = "Notion";
      exec = ''${pkgs.appimage-run}/bin/appimage-run /home/alex/Applications/helium-0.11.5.1-x86_64.AppImage --app=https://www.notion.so/'';
      icon = "notion";
      comment = "Notion – All-in-one workspace";
      categories = [ "Office" ];
      terminal = false;
    };

    antigravity = {
      name = "Antigravity";
      exec = "/etc/profiles/per-user/alex/bin/antigravity-ide";
      icon = "antigravity-ide";
      comment = "Google Antigravity AI Code Editor";
      categories = [ "Development" "IDE" ];
      terminal = false;
      startupNotify = true;
    };

    claude-desktop = {
      name = "Claude";
      exec = "claude-desktop --enable-features=UseOzonePlatform,WaylandWindowDecorations,WaylandFractionalScaleV1 --ozone-platform=wayland --enable-wayland-ime";
      icon = "claude-desktop";
      comment = "Claude Desktop by Anthropic";
      categories = [ "Network" "Office" ];
      terminal = false;
      startupNotify = true;
    };
  };
}
