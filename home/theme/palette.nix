# Single source of truth for every colour on the system.
# Neutral greys with a faint cool tint; names are historical.
#
# Same token names in both modes, roles inverted: `ivory` is the lightest
# background in light mode and the darkest in dark mode; `onyx` is always the
# primary text colour. Consumers pick a token, never a hex.
#
# Contrast (measured): onyx/obsidian/charcoal are body-text safe on every
# background in both modes. basalt is the floor. slate/graphite are for
# disabled or decorative text only (fail 4.5:1 on light backgrounds).
{
  light = {
    # backgrounds, lightest -> darkest
    ivory      = "#FFFFFF";
    shellWhite = "#FCFCFD";
    linen      = "#F6F7F8";
    cream      = "#F1F2F4";
    almondMilk = "#ECEDEF";
    sand       = "#E5E7EA";
    # mid greys: borders, separators, inactive fills
    mist        = "#E6E8EB";
    silverBirch = "#D9DCE0";
    pebble      = "#CBCFD4";
    driftwood   = "#BDC1C7";
    cement      = "#AFB4BA";
    stone       = "#A1A6AD";
    # foregrounds, lightest -> darkest
    slate    = "#6F747B";
    graphite = "#61666D";
    basalt   = "#53585F";
    charcoal = "#45494F";
    obsidian = "#34383D";
    onyx     = "#26292E";
    # the one accent, reserved for critical states only
    clay = "#B87C7C";
    # terminal ANSI colours: muted so diffs/errors stay readable on white
    ansi = {
      black = "#26292E"; red = "#C62A32"; green = "#2E8B3A"; yellow = "#B07A00";
      blue = "#2A62C4"; magenta = "#8E3BB0"; cyan = "#0D8A96"; white = "#9AA0A8";
      brightBlack = "#5C6168"; brightRed = "#D93A42"; brightGreen = "#3A9E47"; brightYellow = "#C48A0A";
      brightBlue = "#3A74D8"; brightMagenta = "#A04CC4"; brightCyan = "#1A9CA8"; brightWhite = "#FFFFFF";
    };
  };

  dark = {
    ivory      = "#1A1C1F";
    shellWhite = "#1F2124";
    linen      = "#25282B";
    cream      = "#2B2E32";
    almondMilk = "#313438";
    sand       = "#383B40";
    mist        = "#3F4247";
    silverBirch = "#4A4D52";
    pebble      = "#56595E";
    driftwood   = "#62656A";
    cement      = "#6E7176";
    stone       = "#7A7D82";
    slate    = "#999DA3";
    graphite = "#A8ABB0";
    basalt   = "#B6B9BE";
    charcoal = "#C5C8CC";
    obsidian = "#D5D7DA";
    onyx     = "#E8EAEC";
    clay = "#D19A9A";
    ansi = {
      black = "#1A1C1F"; red = "#D48A8D"; green = "#9CC49E"; yellow = "#D6BA85";
      blue = "#94B2D6"; magenta = "#BBA3CA"; cyan = "#8FC2C6"; white = "#C5C8CC";
      brightBlack = "#7A7D82"; brightRed = "#E09EA1"; brightGreen = "#AFD2B1"; brightYellow = "#E3C99A";
      brightBlue = "#A9C3E0"; brightMagenta = "#CBB6D8"; brightCyan = "#A5D0D3"; brightWhite = "#E8EAEC";
    };
  };
}
