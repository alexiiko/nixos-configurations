{ ... }:
{
  xdg.configFile."walker/config.toml".text = ''
    [general]
    icons = true
    theme = "elephant"          # einfacher String (kein [theme]-Abschnitt)

    # Optional: bessere Darstellung
    placeholder = "Suche..."
  '';
}
