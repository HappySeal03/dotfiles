import QtQuick
import QtQuick.Layouts

import "../../components"
import "../../theme"

Card {
    id: root

    required property var service

    Layout.fillWidth: true
    Layout.alignment: Qt.AlignTop

    implicitWidth: 320
    implicitHeight: content.implicitHeight + 24

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: 12

        PlayerSelector {
            id: playerSelector
            Layout.fillWidth: true

            service: root.service
        }

        TrackInfo {
            service: root.service
        }

        ProgressBar {
            service: root.service
        }

        PlaybackControls {
            service: root.service
        }
    }
}
