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
      exec = ''${pkgs.appimage-run}/bin/appimage-run /home/alex/Applications/helium-0.11.5.1-x86_64.AppImage --app=https://calendar.google.com/calendar/u/0/r'';
      icon = "google-calendar";
      comment = "Google Calendar";
      categories = [ "Network" "InstantMessaging" ];
      terminal = false;
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
      exec = "/etc/profiles/per-user/alex/bin/antigravity";
      icon = "antigravity";
      comment = "Google Antigravity AI Code Editor";
      categories = [ "Development" "IDE" ];
      terminal = false;
      startupNotify = true;
    };
  };
}
