import Quickshell
import "modules/bar"
import "modules/dashboard"
import "modules/notifications"
import "modules/launcher"
import "services"

ShellRoot {
    Bar {}
    Dashboard {}
    Launcher {}
    Toasts {}
    Reminders {}
}
