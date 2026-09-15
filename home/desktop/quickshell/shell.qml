import Quickshell
import "modules/bar"
import "modules/dashboard"
import "modules/notifications"
import "services"

ShellRoot {
    Bar {}
    Dashboard {}
    Toasts {}
    Reminders {}
}
