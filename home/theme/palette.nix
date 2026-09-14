# Single source of truth for every colour on the system.
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
    ivory      = "#FDFCFB";
    shellWhite = "#FBF7F4";
    linen      = "#F5F0EB";
    cream      = "#F0ECE8";
    almondMilk = "#EBE6E1";
    sand       = "#E6E0DA";
    # mid greys: borders, separators, inactive fills
    mist        = "#E8E6E3";
    silverBirch = "#DBD8D4";
    pebble      = "#CCC9C5";
    driftwood   = "#BFBBB6";
    cement      = "#B2ADA8";
    stone       = "#A5A09A";
    # foregrounds, lightest -> darkest
    slate    = "#8A8580";
    graphite = "#7A7570";
    basalt   = "#6A6560";
    charcoal = "#5A5550";
    obsidian = "#4A4540";
    onyx     = "#3E3935";
    # the one accent, reserved for critical states only
    clay = "#9E6E62";
  };

  dark = {
    ivory      = "#2E2B28";
    shellWhite = "#332F2B";
    linen      = "#3A3632";
    cream      = "#403C38";
    almondMilk = "#46423E";
    sand       = "#4D4944";
    mist        = "#54504C";
    silverBirch = "#5E5A56";
    pebble      = "#6A6662";
    driftwood   = "#76726E";
    cement      = "#827E7A";
    stone       = "#8E8A86";
    slate    = "#A8A39E";
    graphite = "#B5B0AB";
    basalt   = "#C2BDB8";
    charcoal = "#CFC9C4";
    obsidian = "#DBD6D1";
    onyx     = "#E5E0DB";
    clay = "#C48D7F";
  };
}
