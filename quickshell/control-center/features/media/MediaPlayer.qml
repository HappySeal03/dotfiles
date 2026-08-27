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

        // Player selector
        Rectangle {
            id: playerSelector

            Layout.fillWidth: true
            implicitHeight: 36

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
                    text: selectorPopup.visible ? "▲" : "▼"

                    color: Theme.textMuted
                    font.pixelSize: 10
                }
            }

            MouseArea {
                anchors.fill: parent

                enabled: root.service.players.count > 0

                onClicked: selectorPopup.visible = !selectorPopup.visible
            }
        }

        // Track information
        RowLayout {
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

        // Progress
        ColumnLayout {
            Layout.fillWidth: true

            spacing: 4

            Rectangle {
                id: progressBackground

                Layout.fillWidth: true
                height: 4

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
        }

        // Playback controls
        RowLayout {
            Layout.fillWidth: true

            spacing: 8

            Item {
                Layout.fillWidth: true
            }

            ActionButton {
                text: "‹"

                enabled: root.service.canPrevious

                onClicked: root.service.previous()
            }

            ActionButton {
                text: root.service.playing ? "Ⅱ" : "▶"

                enabled: root.service.canTogglePlaying

                onClicked: root.service.togglePlaying()
            }

            ActionButton {
                text: "›"

                enabled: root.service.canNext

                onClicked: root.service.next()
            }

            Item {
                Layout.fillWidth: true
            }
        }
    }

    // Player selector dropdown
    Rectangle {
        id: selectorPopup

        visible: false

        x: playerSelector.x
        y: playerSelector.y + playerSelector.height + 4

        width: playerSelector.width
        height: Math.min(playerList.contentHeight + 8, 300)

        z: 100

        color: Theme.surface
        radius: 8

        border.width: 1
        border.color: Theme.outline

        ListView {
            id: playerList

            anchors.fill: parent
            anchors.margins: 4

            model: root.service.players

            clip: true

            delegate: Rectangle {
                required property var modelData

                width: playerList.width
                height: 36

                radius: 6

                color: modelData === root.service.activePlayer ? Theme.surfaceVariant : "transparent"

                Text {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter

                        leftMargin: 10
                        rightMargin: 10
                    }

                    text: modelData.identity

                    color: Theme.text
                    font.pixelSize: 13

                    elide: Text.ElideRight
                }

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true

                    onEntered: {
                        if (modelData !== root.service.activePlayer)
                            parent.color = Theme.surfaceHover;
                    }

                    onExited: {
                        parent.color = modelData === root.service.activePlayer ? Theme.surfaceVariant : "transparent";
                    }

                    onClicked: {
                        root.service.selectPlayer(modelData);
                        selectorPopup.visible = false;
                    }
                }
            }
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
