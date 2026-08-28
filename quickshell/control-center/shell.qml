import Quickshell
import Quickshell.Io

ShellRoot {
    Services {
        id: services
    }

    Panel {
        id: panel
        services: services
    }

    IpcHandler {
        target: "panel"

        function show(): void {
            panel.visible = true;
        }

        function hide(): void {
            panel.visible = false;
        }

        function toggle(): void {
            panel.visible = !panel.visible;
        }
    }
}
