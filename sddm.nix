{ pkgs, lib, ... }:

let
  palette = import ./home/theme/palette.nix;

  # The greeter runs before any user session, so it cannot read the runtime
  # mode file (that lives in alex's home). It picks light/dark by the clock,
  # the same 06:00/20:00 boundary as theme-auto.
  colorsQml = ''
    pragma Singleton
    import QtQuick

    QtObject {
        readonly property bool dark: {
            const h = new Date().getHours();
            return h >= 20 || h < 6;
        }
        readonly property string font: "JetBrainsMono Nerd Font"
        readonly property color bg:          dark ? "${palette.dark.linen}"  : "${palette.light.linen}"
        readonly property color surface:     dark ? "${palette.dark.ivory}"  : "${palette.light.ivory}"
        readonly property color border:      dark ? "${palette.dark.pebble}" : "${palette.light.pebble}"
        readonly property color borderFocus: dark ? "${palette.dark.stone}"  : "${palette.light.stone}"
        readonly property color text:        dark ? "${palette.dark.onyx}"   : "${palette.light.onyx}"
        readonly property color muted:       dark ? "${palette.dark.slate}"  : "${palette.light.slate}"
        readonly property color fail:        dark ? "${palette.dark.clay}"   : "${palette.light.clay}"
    }
  '';

  theme = pkgs.runCommand "sddm-theme-rice" { } ''
    d=$out/share/sddm/themes/rice
    mkdir -p $d
    cp ${./home/desktop/sddm/theme}/* $d/
    cat > $d/Colors.qml <<'QML'
    ${colorsQml}
    QML
    cat > $d/qmldir <<'QMLDIR'
    module rice
    singleton C 1.0 Colors.qml
    QMLDIR
  '';
  # The greeter's compositor. Weston (the default) never turns this laptop's
  # I2C touchpad into pointer motion ("unknown libinput event 806/807"), so the
  # greeter had no working mouse. cage is a wlroots kiosk compositor: same
  # input stack that works in the session, one fullscreen client, and none of
  # Hyprland's on-screen notices.
in
{
  services.displayManager.sddm = {
    # cage draws the cursor itself, from its OWN environment, and does not
    # scale: on this 2x panel the size has to be doubled by hand.
    wayland.compositorCommand =
      "${pkgs.coreutils}/bin/env XCURSOR_THEME=Bibata-Modern-Ice XCURSOR_SIZE=48 ${lib.getExe pkgs.cage} -ds --";
    theme = "rice";
    extraPackages = [ theme ];
    # HiDPI: the greeter does not pick up the panel's 2x scale on its own,
    # and without a cursor theme the pointer is invisible.
    settings.General.GreeterEnvironment =
      "QT_SCALE_FACTOR=2,QT_WAYLAND_DISABLE_WINDOWDECORATION=1,XCURSOR_THEME=Bibata-Modern-Ice,XCURSOR_SIZE=24";
  };
  environment.systemPackages = [ theme ];
}
