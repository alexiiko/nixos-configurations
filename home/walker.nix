{ ... }:
{
  xdg.configFile."walker/config.toml".text = ''
    [general]
    icons = true
    theme = "custom-light"

    hide_quick_activation = true
    hide_action_hints      = true

    placeholder = "Suche..."
  '';

  # Korrigiertes helles Theme mit den richtigen Selektoren
  xdg.configFile."walker/themes/custom-light/style.css".text = ''
    #window {
      background-color: rgba(255, 255, 255, 0.95);
      border: 2px solid #1e1e2e;
      border-radius: 16px;
      padding: 12px;
    }

    #input {
      background-color: rgba(240, 240, 240, 0.95);
      color: #1e1e2e;
      border: 1px solid #1e1e2e;
      border-radius: 12px;
      padding: 12px 16px;
      font-size: 15px;
    }

    .list {
      background-color: transparent;
      padding: 8px 0;
    }

    .item {
      padding: 10px 14px;
      border-radius: 10px;
      color: #1e1e2e;
    }

    .item:selected {
      background-color: rgba(30, 30, 46, 0.25);
      color: #1e1e2e;
    }

    .item-text {
      color: #1e1e2e;
    }
  '';
}
