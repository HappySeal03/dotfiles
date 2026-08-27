import QtQuick

import "../theme"

Rectangle {
    id: root

    default property alias content: contentItem.data

    implicitWidth: 220
    implicitHeight: contentItem.implicitHeight + 24

    color: Theme.surface
    radius: 12

    border {
        width: 1
        color: Theme.outline
    }

    Item {
        id: contentItem

        anchors {
            fill: parent
            margins: 12
        }
    }
}
