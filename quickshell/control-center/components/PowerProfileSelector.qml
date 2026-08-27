import QtQuick
import QtQuick.Controls
import Quickshell.Services.UPower
import "../theme"

Menu {
    id: root

    property var powerService

    background: Rectangle {
        implicitWidth: 180
        color: Theme.surface
        radius: 12
        border.width: 1
        border.color: Theme.outline
    }

    MenuItem {
        text: "Power Saver"

        contentItem: Text {
            text: parent.text
            color: parent.highlighted ? Theme.accentText : Theme.text
            verticalAlignment: Text.AlignVCenter
            leftPadding: 12
        }

        background: Rectangle {
            color: parent.highlighted ? Theme.accent : "transparent"
            radius: 8
        }

        onTriggered: root.powerService.setProfile(PowerProfile.PowerSaver)
    }

    MenuItem {
        text: "Balanced"

        contentItem: Text {
            text: parent.text
            color: parent.highlighted ? Theme.accentText : Theme.text
            verticalAlignment: Text.AlignVCenter
            leftPadding: 12
        }

        background: Rectangle {
            color: parent.highlighted ? Theme.accent : "transparent"
            radius: 8
        }

        onTriggered: root.powerService.setProfile(PowerProfile.Balanced)
    }

    MenuItem {
        text: "Performance"
        visible: root.powerService.hasPerformance

        contentItem: Text {
            text: parent.text
            color: parent.highlighted ? Theme.accentText : Theme.text
            verticalAlignment: Text.AlignVCenter
            leftPadding: 12
        }

        background: Rectangle {
            color: parent.highlighted ? Theme.accent : "transparent"
            radius: 8
        }

        onTriggered: root.powerService.setProfile(PowerProfile.Performance)
    }
}
