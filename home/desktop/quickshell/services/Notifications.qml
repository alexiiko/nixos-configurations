pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// The notification daemon. Quickshell owns org.freedesktop.Notifications
// (dunst is gone), every notification on the system passes through here.
// Toasts are drawn by modules/notifications/Toasts.qml; this holds state.
Singleton {
    id: root

    // Notifications currently shown as toasts. A ListModel, not an array:
    // reassigning an array makes the Repeater rebuild every delegate, which
    // restarted the surviving toasts' fly-in and their expiry timer.
    property ListModel active: ListModel {}
    // everything received this session, newest first (for the centre)
    property var history: []

    // WhatsApp unread: counted from its notifications, cleared when the
    // window is shown. Approximate by nature (phone reads are invisible).
    property int whatsappUnread: 0
    function clearWhatsapp() { whatsappUnread = 0; }
    function isWhatsapp(n) {
        const s = `${n.appName} ${n.desktopEntry} ${n.summary}`.toLowerCase();
        return s.includes("whatsapp");
    }

    // urgency -> ms on screen; critical stays until dismissed
    function timeoutFor(n) {
        if (n.expireTimeout > 0) return n.expireTimeout;
        return n.urgency === NotificationUrgency.Critical ? 0
             : n.urgency === NotificationUrgency.Low ? 4000 : 7000;
    }

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: (n) => {
            n.tracked = true;
            console.log(`notification: app=${JSON.stringify(n.appName)} entry=${JSON.stringify(n.desktopEntry)} summary=${JSON.stringify(n.summary)} icon=${JSON.stringify(n.appIcon)} image=${n.image !== ""}`);
            root.history = [{ appName: n.appName, summary: n.summary, body: n.body, appIcon: n.appIcon, time: new Date() }, ...root.history].slice(0, 100);
            if (root.isWhatsapp(n)) root.whatsappUnread++;
            root.active.append({ notif: n });
            n.closed.connect(() => {
                for (let i = 0; i < root.active.count; i++)
                    if (root.active.get(i).notif === n) { root.active.remove(i); break; }
            });
        }
    }
}
