{ pkgs, ... }:
{
  xdg.desktopEntries = {
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
  };
}
