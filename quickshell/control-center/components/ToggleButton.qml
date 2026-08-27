import QtQuick
import QtQuick.Controls

import "../theme"

Button {
    id: root

    property bool active: false

    implicitWidth: 30
    implicitHeight: 44

    checkable: true
    checked: active

    background: Rectangle {
        radius: 12

        color: {
            if (root.checked && root.hovered)
                return Theme.accentHover;

            if (root.checked)
                return Theme.accent;

            if (root.hovered)
                return Theme.surfaceHover;

            return Theme.surfaceVariant;
        }

        border.width: 1
        border.color: Theme.outline
    }

    contentItem: Text {
        text: root.text
        font.pixelSize: 20
        color: root.checked ? Theme.accentText : Theme.text

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
