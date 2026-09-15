import Quickshell
import "modules/bar"
import "modules/workspaces"
import "modules/dashboard"
import "modules/notifications"
import "modules/launcher"
import "services"

ShellRoot {
    Bar {}
    WorkspaceBar {}
    Dashboard {}
    Launcher {}
    Toasts {}
    Reminders {}
    BatteryAlerts {}
}
