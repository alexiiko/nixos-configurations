{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Die eigentlichen Befehle
    (writeShellScriptBin "suspend"  "exec systemctl suspend")
    (writeShellScriptBin "reboot"   "exec systemctl reboot")
    (writeShellScriptBin "shutdown" "exec systemctl poweroff")
  ];

  # Schöne .desktop-Einträge (mit deutschen Namen + Icons)
  xdg.desktopEntries = {
    suspend = {
      name = "Energie sparen";
      exec = "suspend";
      icon = "system-suspend";
      comment = "Laptop in den Ruhezustand versetzen";
      categories = [ "System" ];
      terminal = false;
    };

    reboot = {
      name = "Neustarten";
      exec = "reboot";
      icon = "system-reboot";
      comment = "System neu starten";
      categories = [ "System" ];
      terminal = false;
    };

    shutdown = {
      name = "Herunterfahren";
      exec = "shutdown";
      icon = "system-shutdown";
      comment = "System herunterfahren";
      categories = [ "System" ];
      terminal = false;
    };
  };
}
