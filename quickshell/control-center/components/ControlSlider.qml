import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

RowLayout {
    id: root

    property string icon: ""
    property string label: ""

    property alias value: slider.value
    property alias from: slider.from
    property alias to: slider.to
    property alias stepSize: slider.stepSize

    signal userMoved(real value)

    spacing: 8

    Item {
        Layout.preferredWidth: 24
        Layout.minimumWidth: 24
        Layout.maximumWidth: 24

        Text {
            anchors.centerIn: parent

            text: root.icon
            font.family: "Symbols Nerd Font"
            font.pixelSize: 20
            color: Theme.text
        }
    }

    Slider {
        id: slider
        Layout.fillWidth: true

        from: 0
        to: 1
        stepSize: 0.01

        background: Rectangle {
            width: slider.availableWidth
            height: 4
            y: slider.height / 2 - height / 2
            radius: 2
            color: Theme.surfaceVariant

            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                radius: 2
                color: Theme.accent
            }
        }

        handle: Rectangle {
            implicitWidth: 14
            implicitHeight: 14

            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)

            y: slider.topPadding + slider.availableHeight / 2 - height / 2

            radius: width / 2
            color: slider.pressed ? Theme.accent : Theme.text
        }

        onMoved: root.userMoved(value)
    }

    Text {
        Layout.preferredWidth: 40
        Layout.minimumWidth: 40
        Layout.maximumWidth: 40

        text: Math.round(slider.value * 100) + "%"
        horizontalAlignment: Text.AlignRight

        color: Theme.text
    }
}
