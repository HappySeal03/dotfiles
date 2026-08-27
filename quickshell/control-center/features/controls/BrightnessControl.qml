import QtQuick
import QtQuick.Layouts

import "../../components"

ColumnLayout {
    id: root

    property real brightness: 0.3

    signal brightnessChangedByUser(real value)

    spacing: 8

    ControlSlider {
        Layout.fillWidth: true

        label: "Brightness"
        icon: "󰃠"

        value: root.brightness

        onUserMoved: value => {
            root.brightnessChangedByUser(value);
        }
    }
}
