import QtQuick
import QtQuick.Layouts

import "../../components"
import "../../theme"

Card {
    id: root

    required property var service

    Layout.fillWidth: true

    implicitWidth: 320
    implicitHeight: content.implicitHeight

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "System"
                color: Theme.text
                font.pixelSize: 16
                font.bold: true

                Layout.fillWidth: true
            }

            Text {
                text: root.service.hostname
                color: Theme.textMuted
                font.pixelSize: 12
            }
        }

        // Resource usage
        GridLayout {
            Layout.fillWidth: true

            columns: 2
            rowSpacing: 8
            columnSpacing: 16

            Text {
                text: "CPU"
                color: Theme.textMuted
            }

            Text {
                text: Math.round(root.service.cpuUsage) + "%"
                color: Theme.text
                horizontalAlignment: Text.AlignRight

                Layout.fillWidth: true
            }

            Text {
                text: "Memory"
                color: Theme.textMuted
            }

            Text {
                text: Math.round(root.service.memoryUsage) + "%"
                color: Theme.text
                horizontalAlignment: Text.AlignRight

                Layout.fillWidth: true
            }

            Text {
                text: "Disk"
                color: Theme.textMuted
            }

            Text {
                text: Math.round(root.service.diskUsage) + "%"
                color: Theme.text
                horizontalAlignment: Text.AlignRight

                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1

            color: Theme.outline
        }

        // Battery / uptime
        GridLayout {
            Layout.fillWidth: true

            columns: 2
            rowSpacing: 8
            columnSpacing: 16

            Text {
                text: "Battery"
                color: Theme.textMuted
            }

            Text {
                text: root.service.batteryPercentage >= 0 ? root.service.batteryPercentage + "%" : "N/A"

                color: root.service.batteryCharging ? Theme.accent : Theme.text

                horizontalAlignment: Text.AlignRight

                Layout.fillWidth: true
            }

            Text {
                text: "Uptime"
                color: Theme.textMuted
            }

            Text {
                text: root.service.uptime
                color: Theme.text

                horizontalAlignment: Text.AlignRight

                Layout.fillWidth: true
            }
        }

        Text {
            text: root.service.kernel
            color: Theme.textMuted
            font.pixelSize: 11

            elide: Text.ElideRight

            Layout.fillWidth: true
        }
    }
}
