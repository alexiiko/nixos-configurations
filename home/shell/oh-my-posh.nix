{ config, pkgs, ... }:
{
  home.file.".config/oh-my-posh/theme.omp.json".text = ''
    {
      "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
      "version": 2,
      "final_space": true,
      "blocks": [
        {
          "type": "prompt",
          "alignment": "left",
          "segments": [
            {
              "type": "session",
              "style": "plain",
              "foreground": "#1e1e2e",
              "template": "{{ .UserName }} "
            },
            {
              "type": "path",
              "style": "plain",
              "foreground": "#1e1e2e",
              "template": "{{ .Path }} ",
              "properties": {
                "style": "folder"
              }
            },
            {
              "type": "git",
              "style": "plain",
              "foreground": "#1e1e2e",
              "template": "({{ .HEAD }}) ",
              "properties": {
                "branch_icon": " ",
                "fetch_status": true,
                "fetch_upstream": true
              }
            }
          ]
        }
      ]
    }
  '';
}
