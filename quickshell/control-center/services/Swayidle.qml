import QtQuick
import Quickshell.Io

Item {
    id: root

    property bool running: false

    function refresh() {
        check.running = true;
    }

    function toggle() {
        if (root.running)
            stop();
        else
            start();
    }

    function start() {
        startProcess.running = true;
    }

    function stop() {
        stopProcess.running = true;
    }

    Process {
        id: check

        command: ["pgrep", "-x", "swayidle"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.running = text.trim().length > 0;
            }
        }
    }

    Process {
        id: startProcess

        command: ["setsid", "swayidle", "-w", "timeout", "300", "swaylock -f", "timeout", "600", "niri msg action power-off-monitors", "resume", "niri msg action power-on-monitors", "before-sleep", "swaylock -f"]

        onExited: root.refresh()
    }

    Process {
        id: stopProcess

        command: ["pkill", "-x", "swayidle"]

        onExited: root.refresh()
    }

    Component.onCompleted: refresh()
}
