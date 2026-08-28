import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

import "../../components"
import "../../theme"

Rectangle {
    id: root

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 16

    color: Theme.surface
    border.width: 1
    border.color: Theme.outline
    radius: 10

    property var services

    ColumnLayout {
        id: content

        anchors {
            fill: parent
            margins: 8
        }

        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            ToggleButton {
                Layout.fillWidth: true

                text: "󰖔"
                active: false
            }

            ToggleButton {
                Layout.fillWidth: true

                text: "󰀝"
                active: false
            }

            ActionButton {
                Layout.fillWidth: true

                text: {
                    switch (root.services.power.current) {
                    case PowerProfile.PowerSaver:
                        return "󰾆";
                    case PowerProfile.Balanced:
                        return "󰗑";
                    case PowerProfile.Performance:
                        return "󱐋";
                    default:
                        return "󰾆";
                    }
                }

                onClicked: powerMenu.open()

                PowerProfileSelector {
                    id: powerMenu

                    powerService: root.services.power
                    scale: Theme.scale
                }
            }

            ToggleButton {
                Layout.fillWidth: true

                text: "󰒲"

                active: root.services.swayidle.running
                onClicked: root.services.swayidle.toggle()
            }
        }
    }
}
