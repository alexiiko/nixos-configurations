{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.walker.homeManagerModules.default ];

  programs.walker = {
    enable = true;
    runAsService = true;

    config = {
      theme = "custom-light";
      icons = true;
      hide_quick_activation = true;
      hide_action_hints = true;
      placeholder = "Suche...";
    };

    themes = {
      "custom-light" = {
        style = ''
          /* ── Hauptfenster (funktioniert schon) ── */
          .box-wrapper {
            background-color: #ffffff;
            border: 3px solid #1e1e2e;
            border-radius: 24px;
            padding: 16px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.28),
                        0 8px 15px rgba(0, 0, 0, 0.15);
          }

          /* ── Suchleiste: GRAU + SCHWARZER RAND (auch bei Fokus) ── */
          .input {
            background-color: #f0f0f0 !important;
            color: #1e1e2e !important;
            border: 2px solid #1e1e2e !important;
            border-radius: 14px !important;
            padding: 14px 18px !important;
            font-size: 15px !important;
          }

          /* GTK-Fokus-Ring (hellblau) komplett entfernen */
          .input:focus,
          .input:active {
            outline: none !important;
            box-shadow: none !important;
            border-color: #1e1e2e !important;
          }

          /* ── Liste ── */
          .list {
            background-color: #ffffff;
            padding: 8px 0;
          }

          /* ── Einträge normal ── */
          .item-box {
            padding: 12px 16px;
            border-radius: 12px;
            color: #1e1e2e;
            margin: 3px 6px;
          }

          /* ── Highlight (Pfeiltasten + Maus) – hellgrau statt blau ── */
          child:selected .item-box,
          row:selected .item-box,
          .item-box:selected,
          .item-box:focus,
          .item-box:hover {
            background-color: #e5e5e5 !important;
            color: #1e1e2e !important;
          }

          .item-text {
            color: #1e1e2e;
          }
        '';
      };
    };
  };
}
