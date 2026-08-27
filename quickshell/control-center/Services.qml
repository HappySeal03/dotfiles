import QtQuick
import "./services"

Item {
    property alias audio: audio
    property alias brightness: brightness
    property alias power: powerProfile
    property alias swayidle: swayidle
    property alias systeminfo: systeminfo
    property alias mpris: mpris

    Audio {
        id: audio
    }

    Brightness {
        id: brightness
    }

    PowerProfile {
        id: powerProfile
    }

    Swayidle {
        id: swayidle
    }

    SystemInfo {
        id: systeminfo
    }

    Mpris {
        id: mpris
    }
}
