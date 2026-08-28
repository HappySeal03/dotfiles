import QtQuick
import QtQuick.Layouts

import "../../theme"

Rectangle {
    id: root

    property real outputVolume: 0.3
    property real inputVolume: 0.3
    property real brightness: 0.3

    signal outputVolumeChangedByUser(real value)
    signal inputVolumeChangedByUser(real value)
    signal brightnessChangedByUser(real value)

    color: Theme.surface
    border.color: Theme.outline
    border.width: 1
    radius: 6

    implicitWidth: 300
    implicitHeight: content.implicitHeight + 18

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.margins: 8

        spacing: 8

        VolumeControl {
            Layout.fillWidth: true

            outputVolume: root.outputVolume
            inputVolume: root.inputVolume

            onOutputVolumeChangedByUser: value => root.outputVolumeChangedByUser(value)

            onInputVolumeChangedByUser: value => root.inputVolumeChangedByUser(value)
        }

        BrightnessControl {
            Layout.fillWidth: true

            brightness: root.brightness

            onBrightnessChangedByUser: value => root.brightnessChangedByUser(value)
        }
    }
}
