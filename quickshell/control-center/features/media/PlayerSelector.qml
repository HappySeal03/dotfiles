pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../theme"

Item {
    id: root

    required property var service

    implicitHeight: 36
    Layout.fillWidth: true

    Rectangle {
        id: selector

        anchors.fill: parent

        color: Theme.surfaceVariant
        radius: 8

        border.width: 1
        border.color: Theme.outline

        RowLayout {
            anchors.fill: parent

            anchors.leftMargin: 12
            anchors.rightMargin: 10

            Text {
                text: root.service.available ? root.service.identity : "No player"

                color: Theme.text
                font.pixelSize: 13

                elide: Text.ElideRight

                Layout.fillWidth: true
            }

            Text {
                text: playerMenu.visible ? "▲" : "▼"

                color: Theme.textMuted
                font.pixelSize: 10
            }
        }

        MouseArea {
            anchors.fill: parent

            enabled: root.service.players.values.length > 0

            onPressed: {
                if (playerMenu.visible) {
                    playerMenu.close();
                } else {
                    playerMenu.open();
                }
            }
        }
    }

    Menu {
        id: playerMenu

        parent: selector

        popupType: Popup.Item

        x: 0
        y: selector.height + 4

        width: root.width
        implicitWidth: root.width

        padding: 4

        background: Rectangle {
            color: Theme.surface
            radius: 12

            border.width: 1
            border.color: Theme.outline
        }

        Repeater {
            model: root.service.players

            delegate: MenuItem {
                id: menuItem

                required property var modelData

                width: playerMenu.availableWidth
                height: 36

                contentItem: Text {
                    text: menuItem.modelData.identity

                    color: menuItem.hovered ? Theme.accentText : Theme.text

                    font.pixelSize: 13

                    verticalAlignment: Text.AlignVCenter

                    elide: Text.ElideRight

                    leftPadding: 8
                    rightPadding: 8
                }

                background: Rectangle {
                    radius: 8

                    color: menuItem.hovered ? Theme.accent : "transparent"
                }

                onTriggered: {
                    root.service.selectPlayer(menuItem.modelData);
                    playerMenu.close();
                }
            }
        }
    }
}
