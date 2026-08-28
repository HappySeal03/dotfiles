import QtQuick
import QtQuick.Layouts

import "../../theme"

ColumnLayout {
    id: root

    required property var service

    Layout.fillWidth: true

    spacing: 4

    Rectangle {
        id: progressBackground

        Layout.fillWidth: true
        implicitHeight: 4

        radius: 2

        color: Theme.surfaceVariant

        Rectangle {
            width: root.service.length > 0 ? progressBackground.width * Math.min(1, Math.max(0, root.service.position / root.service.length)) : 0

            height: parent.height
            radius: 2

            color: Theme.accent
        }

        MouseArea {
            anchors.fill: parent

            enabled: root.service.canSeek && root.service.length > 0

            onClicked: mouse => {
                var ratio = mouse.x / width;

                root.service.seekTo(ratio * root.service.length);
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true

        Text {
            text: formatTime(root.service.position)

            color: Theme.textMuted
            font.pixelSize: 10
        }

        Item {
            Layout.fillWidth: true
        }

        Text {
            text: formatTime(root.service.length)

            color: Theme.textMuted
            font.pixelSize: 10
        }
    }

    function formatTime(seconds) {
        if (!seconds || seconds < 0)
            return "0:00";

        var minutes = Math.floor(seconds / 60);
        var remaining = Math.floor(seconds % 60);

        return minutes + ":" + (remaining < 10 ? "0" : "") + remaining;
    }
}
