import Quickshell
import "modules/bar"
import "modules/workspaces"
import "modules/volume"
import "modules/brightness"
import "modules/dashboard"
import "modules/notifications"
import "modules/launcher"
import "modules/screenshot"
import "services"

ShellRoot {
    Bar {}
    WorkspaceBar {}
    VolumePanel {}
    BrightnessPanel {}
    Dashboard {}
    Launcher {}
    Freeze {}
    Toasts {}
    Reminders {}
    BatteryAlerts {}
}
