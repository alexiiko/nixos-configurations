{ pkgs, ... }:
{
  services.udiskie = {
    enable = true;

    settings = {
      program_options = {
        file_manager = "dolphin";   # oder "${pkgs.dolphin}/bin/dolphin"
      };
    };
  };
}
