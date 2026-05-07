{ pkgs, ... }:
{
  services.udiskie = {
    enable = true;
    autostart = true;

    # Optional: Dolphin automatisch öffnen, wenn du einen Stick einsteckst
    settings = {
      program_options = {
        file_manager = "dolphin";   # oder "${pkgs.dolphin}/bin/dolphin"
      };
    };
  };
}
