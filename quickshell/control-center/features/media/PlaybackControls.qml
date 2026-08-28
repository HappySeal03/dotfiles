import QtQuick
import QtQuick.Layouts

import "../../components"

RowLayout {
    id: root

    required property var service

    Layout.fillWidth: true

    spacing: 10

    Item {
        Layout.fillWidth: true
    }

    ActionButton {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40

        text: "‹"

        enabled: root.service.canPrevious

        onClicked: root.service.previous()
    }

    ActionButton {
        Layout.preferredWidth: 48
        Layout.preferredHeight: 48

        text: root.service.playing ? "Ⅱ" : "▶"

        enabled: root.service.canTogglePlaying

        onClicked: root.service.togglePlaying()
    }

    ActionButton {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40

        text: "›"

        enabled: root.service.canNext

        onClicked: root.service.next()
    }

    Item {
        Layout.fillWidth: true
    }
}
