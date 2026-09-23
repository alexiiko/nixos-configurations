import QtQuick
import QtQuick.Controls

// Login screen, same language as the rest of the rice: flat neutral surface,
// one card, monochrome. Colours come from Colors.qml (generated from
// home/theme/palette.nix); light/dark follows the clock, like theme-auto.
Rectangle {
    id: root
    color: C.bg

    property int sessionIndex: sessionModel.lastIndex
    property string user: userModel.lastUser || userModel.data(userModel.index(0, 0), Qt.DisplayRole) || "user"

    Connections {
        target: sddm
        function onLoginSucceeded() { message.text = ""; }
        function onLoginFailed() { message.text = "Wrong password"; password.text = ""; password.forceActiveFocus(); }
    }

    // ---- clock, top centre -------------------------------------------------
    Column {
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: root.height * 0.16 }
        spacing: 2
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(clock.now, "HH:mm")
            color: C.text
            font { family: C.font; pixelSize: 84; weight: Font.Light }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(clock.now, "dddd, d MMMM")
            color: C.muted
            font { family: C.font; pixelSize: 16 }
        }
    }
    QtObject {
        id: clock
        property date now: new Date()
        property Timer t: Timer { interval: 1000; running: true; repeat: true; onTriggered: clock.now = new Date() }
    }

    // ---- login card, centre ------------------------------------------------
    Rectangle {
        id: card
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root.height * 0.10
        width: 340
        height: 124
        radius: 16
        color: C.surface
        border.width: 1
        border.color: C.border

        Column {
            anchors { fill: parent; margins: 16 }
            spacing: 12

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.user
                color: C.text
                font { family: C.font; pixelSize: 16; weight: Font.Medium }
            }

            Rectangle {
                width: parent.width
                height: 40
                radius: 10
                color: C.bg
                border.width: 1
                border.color: password.activeFocus ? C.borderFocus : C.border
                Behavior on border.color { ColorAnimation { duration: 150 } }

                TextInput {
                    id: password
                    anchors { fill: parent; leftMargin: 12; rightMargin: 40 }
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    color: C.text
                    font { family: C.font; pixelSize: 15 }
                    focus: true
                    onAccepted: sddm.login(root.user, password.text, root.sessionIndex)
                }
                Text {
                    visible: password.text === ""
                    anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                    text: "Password"
                    color: C.muted
                    font: password.font
                }
                // submit arrow
                Text {
                    anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                    text: "→"
                    color: enter.containsMouse ? C.text : C.muted
                    font { family: C.font; pixelSize: 18 }
                    MouseArea {
                        id: enter
                        anchors.fill: parent; anchors.margins: -8
                        hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: sddm.login(root.user, password.text, root.sessionIndex)
                    }
                }
            }

            Text {
                id: message
                anchors.horizontalCenter: parent.horizontalCenter
                color: C.fail
                font { family: C.font; pixelSize: 13 }
                height: 14
            }
        }
    }

    // ---- session + power, bottom -------------------------------------------
    Row {
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 28 }
        spacing: 20

        Text {
            text: sessionModel.data(sessionModel.index(root.sessionIndex, 0), Qt.DisplayRole) ?? "Session"
            color: sessH.containsMouse ? C.text : C.muted
            font { family: C.font; pixelSize: 13 }
            MouseArea {
                id: sessH
                anchors.fill: parent; anchors.margins: -6
                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: root.sessionIndex = (root.sessionIndex + 1) % sessionModel.rowCount()
            }
        }
        Text {
            text: "Sleep"
            color: sleepH.containsMouse ? C.text : C.muted
            font { family: C.font; pixelSize: 13 }
            visible: sddm.canSuspend
            MouseArea { id: sleepH; anchors.fill: parent; anchors.margins: -6; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: sddm.suspend() }
        }
        Text {
            text: "Restart"
            color: rebootH.containsMouse ? C.text : C.muted
            font { family: C.font; pixelSize: 13 }
            visible: sddm.canReboot
            MouseArea { id: rebootH; anchors.fill: parent; anchors.margins: -6; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: sddm.reboot() }
        }
        Text {
            text: "Shut down"
            color: offH.containsMouse ? C.text : C.muted
            font { family: C.font; pixelSize: 13 }
            visible: sddm.canPowerOff
            MouseArea { id: offH; anchors.fill: parent; anchors.margins: -6; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: sddm.powerOff() }
        }
    }

    Component.onCompleted: password.forceActiveFocus()
}
