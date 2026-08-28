import QtQuick
import QtQuick.Layouts

import "../../theme"

RowLayout {
    id: root

    required property var service

    Layout.fillWidth: true
    spacing: 12

    Rectangle {
        Layout.preferredWidth: 96
        Layout.preferredHeight: 96

        radius: 8
        color: Theme.surfaceVariant

        clip: true

        Image {
            anchors.fill: parent

            source: root.service.artUrl
            fillMode: Image.PreserveAspectCrop

            asynchronous: true
            cache: true

            visible: source !== ""
        }

        Text {
            anchors.centerIn: parent

            text: "♪"

            color: Theme.textMuted
            font.pixelSize: 32

            visible: root.service.artUrl === ""
        }
    }

    ColumnLayout {
        Layout.fillWidth: true

        spacing: 4

        Text {
            text: root.service.available ? root.service.title : "Nothing playing"

            color: Theme.text
            font.pixelSize: 15
            font.bold: true

            elide: Text.ElideRight
            maximumLineCount: 2
            wrapMode: Text.Wrap

            Layout.fillWidth: true
        }

        Text {
            text: root.service.artist

            color: Theme.textMuted
            font.pixelSize: 13

            elide: Text.ElideRight
            visible: text !== ""

            Layout.fillWidth: true
        }

        Text {
            text: root.service.album

            color: Theme.textMuted
            font.pixelSize: 11

            elide: Text.ElideRight
            visible: text !== ""

            Layout.fillWidth: true
        }
    }
}
