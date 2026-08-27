import QtQuick
import QtQuick.Layouts

import "../../components"

ColumnLayout {
    id: root

    property real outputVolume: 0.3
    property real inputVolume: 0.3

    signal outputVolumeChangedByUser(real value)
    signal inputVolumeChangedByUser(real value)

    spacing: 8

    ControlSlider {
        Layout.fillWidth: true

        label: "Output"
        icon: "󰕾"

        value: root.outputVolume

        onUserMoved: value => {
            root.outputVolumeChangedByUser(value);
        }
    }

    ControlSlider {
        Layout.fillWidth: true

        label: "Input"
        icon: "󰍬"

        value: root.inputVolume

        onUserMoved: value => {
            root.inputVolumeChangedByUser(value);
        }
    }
}
