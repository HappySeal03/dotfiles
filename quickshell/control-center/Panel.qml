import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import "./components"
import "./features/controls"
import "./features/calendar"
import "./features/systeminfo"
import "./features/media"
import "./theme"

PanelWindow {
    id: root

    property real scaleFactor: Theme.scale
    property var services

    visible: false

    anchors {
        top: true
        left: true
        right: true
    }

    implicitWidth: panel.width * scaleFactor
    implicitHeight: panel.height * scaleFactor

    color: "transparent"

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    Rectangle {
        id: panel

        transform: Scale {
            origin.x: panel.width / 2
            origin.y: 0
            xScale: root.scaleFactor
            yScale: root.scaleFactor
        }

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        implicitWidth: Math.max(content.implicitWidth + 32, 300)
        implicitHeight: content.implicitHeight + 32

        color: Theme.background
        radius: 16

        border.width: 1
        border.color: Theme.outline

        focus: true

        Keys.onEscapePressed: root.visible = false

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Q) {
                root.visible = false;
                event.accepted = true;
            } else if (event.key === Qt.Key_B) {
                root.services.mpris.previous();
                event.accepted = true;
            } else if (event.key === Qt.Key_N) {
                root.services.mpris.next();
                event.accepted = true;
            } else if (event.key === Qt.Key_Q) {
                root.visible = false;
                event.accepted = true;
            }
        }

        Keys.onSpacePressed: function (event) {
            root.services.mpris.togglePlaying();
            event.accepted = true;
        }

        RowLayout {
            id: content

            anchors {
                fill: parent
                margins: 16
            }

            spacing: 12

            SystemInfo {
                service: root.services.systeminfo
            }

            ColumnLayout {
                id: controls
                Layout.fillWidth: true

                spacing: 12

                Controls {
                    outputVolume: root.services.audio.outputVolume
                    inputVolume: root.services.audio.inputVolume
                    brightness: root.services.brightness.value

                    onOutputVolumeChangedByUser: value => root.services.audio.setOutputVolume(value)

                    onInputVolumeChangedByUser: value => root.services.audio.setInputVolume(value)

                    onBrightnessChangedByUser: value => root.services.brightness.setValue(value)
                }

                ButtonPanel {
                    services: root.services
                }

                Calendar {
                    Layout.fillWidth: true
                }
            }

            MediaPlayer {
                service: root.services.mpris
            }
        }
    }
}
