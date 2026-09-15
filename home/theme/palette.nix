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
    slate    = "#868B92";
    graphite = "#767B82";
    basalt   = "#666B72";
    charcoal = "#555A60";
    obsidian = "#43474D";
    onyx     = "#26292E";
    # the one accent, reserved for critical states only
    clay = "#B87C7C";
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
  };
}
