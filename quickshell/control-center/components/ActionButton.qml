import QtQuick
import QtQuick.Controls
import "../theme"

Button {
    id: root

    implicitWidth: 30
    implicitHeight: 44

    background: Rectangle {
        radius: 12

        color: root.hovered ? Theme.surfaceHover : Theme.surfaceVariant

        border.width: 1
        border.color: Theme.outline
    }

    contentItem: Text {
        text: root.text
        color: Theme.text

        font.family: "Symbols Nerd Font"
        font.pixelSize: 20

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
