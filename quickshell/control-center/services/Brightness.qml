import QtQuick
import Quickshell.Io

Item {
    id: root

    property real value: 0

    property real current: 0
    property real maximum: 1

    function refresh() {
        currentProcess.running = true;
        maximumProcess.running = true;
    }

    function setValue(value) {
        const percent = Math.round(value * 100);

        setter.exec(["brightnessctl", "set", percent + "%"]);

        root.value = value;
    }

    Process {
        id: currentProcess

        command: ["brightnessctl", "get"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.current = Number(this.text.trim());
                updateValue();
            }
        }
    }

    Process {
        id: maximumProcess

        command: ["brightnessctl", "max"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.maximum = Number(this.text.trim());
                updateValue();
            }
        }
    }

    Process {
        id: setter
    }

    function updateValue() {
        if (root.maximum > 0)
            root.value = root.current / root.maximum;
    }

    Component.onCompleted: refresh()
}
