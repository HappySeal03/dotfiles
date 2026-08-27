import Quickshell.Io
import QtQuick

Item {
    id: root

    property real cpuUsage: 0
    property real memoryUsage: 0

    property real diskUsage: 0
    property string diskFree: ""
    property string diskTotal: ""

    property int batteryPercentage: -1
    property bool batteryCharging: false

    property string uptime: ""
    property string hostname: ""
    property string kernel: ""

    property real _previousCpuTotal: 0
    property real _previousCpuIdle: 0

    function update() {
        cpuProcess.running = true;
        memoryProcess.running = true;
        diskProcess.running = true;
        batteryProcess.running = true;
        uptimeProcess.running = true;
        systemProcess.running = true;
    }

    function formatBytes(bytes) {
        if (bytes >= 1024 * 1024 * 1024)
            return (bytes / (1024 * 1024 * 1024)).toFixed(1) + " GB";

        if (bytes >= 1024 * 1024)
            return (bytes / (1024 * 1024)).toFixed(0) + " MB";

        return (bytes / 1024).toFixed(0) + " KB";
    }

    function formatUptime(seconds) {
        var days = Math.floor(seconds / 86400);
        seconds %= 86400;

        var hours = Math.floor(seconds / 3600);
        seconds %= 3600;

        var minutes = Math.floor(seconds / 60);

        if (days > 0)
            return days + "d " + hours + "h";

        if (hours > 0)
            return hours + "h " + minutes + "m";

        return minutes + "m";
    }

    Process {
        id: cpuProcess

        command: ["sh", "-c", "head -n1 /proc/stat"]

        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split(/\s+/);

                if (parts.length < 5)
                    return;

                var user = Number(parts[1]);
                var nice = Number(parts[2]);
                var system = Number(parts[3]);
                var idle = Number(parts[4]);
                var iowait = parts.length > 5 ? Number(parts[5]) : 0;
                var irq = parts.length > 6 ? Number(parts[6]) : 0;
                var softirq = parts.length > 7 ? Number(parts[7]) : 0;
                var steal = parts.length > 8 ? Number(parts[8]) : 0;

                var total = user + nice + system + idle + iowait + irq + softirq + steal;

                var idleTotal = idle + iowait;

                if (root._previousCpuTotal > 0) {
                    var totalDelta = total - root._previousCpuTotal;
                    var idleDelta = idleTotal - root._previousCpuIdle;

                    if (totalDelta > 0) {
                        root.cpuUsage = 100 * (1 - idleDelta / totalDelta);
                    }
                }

                root._previousCpuTotal = total;
                root._previousCpuIdle = idleTotal;
            }
        }
    }

    Process {
        id: memoryProcess

        command: ["sh", "-c", "free -b | awk '/^Mem:/ {print $2, $3}'"]

        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split(/\s+/);

                if (parts.length < 2)
                    return;

                var total = Number(parts[0]);
                var used = Number(parts[1]);

                if (total > 0)
                    root.memoryUsage = used / total * 100;
            }
        }
    }

    Process {
        id: diskProcess

        command: ["sh", "-c", "df -B1 / | awk 'NR==2 {print $2, $3, $4}'"]

        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split(/\s+/);

                if (parts.length < 3)
                    return;

                var total = Number(parts[0]);
                var used = Number(parts[1]);
                var free = Number(parts[2]);

                if (total > 0)
                    root.diskUsage = used / total * 100;

                root.diskFree = root.formatBytes(free);
                root.diskTotal = root.formatBytes(total);
            }
        }
    }

    Process {
        id: batteryProcess

        command: ["sh", "-c", "for f in /sys/class/power_supply/BAT*/capacity; do " + "cat \"$f\"; break; " + "done; " + "for f in /sys/class/power_supply/BAT*/status; do " + "cat \"$f\"; break; " + "done"]

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n");

                if (lines.length > 0) {
                    var percentage = Number(lines[0]);

                    if (!isNaN(percentage))
                        root.batteryPercentage = percentage;
                }

                if (lines.length > 1)
                    root.batteryCharging = lines[1].trim() === "Charging";
            }
        }
    }

    Process {
        id: uptimeProcess

        command: ["sh", "-c", "cut -d' ' -f1 /proc/uptime"]

        stdout: StdioCollector {
            onStreamFinished: {
                var seconds = Number(text.trim());

                if (!isNaN(seconds))
                    root.uptime = root.formatUptime(seconds);
            }
        }
    }

    Process {
        id: systemProcess

        command: ["sh", "-c", "printf '%s\\n' \"$(hostname)\" \"$(uname -s) $(uname -r)\""]

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n");

                if (lines.length > 0)
                    root.hostname = lines[0];

                if (lines.length > 1)
                    root.kernel = lines[1];
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: root.update()
    }
}
