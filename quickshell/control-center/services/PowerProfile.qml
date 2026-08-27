import QtQuick
import Quickshell.Services.UPower

Item {
    id: root

    readonly property var current: PowerProfiles.profile

    readonly property bool hasPerformance: PowerProfiles.hasPerformanceProfile

    function setProfile(profile) {
        PowerProfiles.profile = profile;
    }

    function toggle() {
        switch (PowerProfiles.profile) {
        case PowerProfile.PowerSaver:
            PowerProfiles.profile = PowerProfile.Balanced;
            break;
        case PowerProfile.Balanced:
            if (PowerProfiles.hasPerformanceProfile)
                PowerProfiles.profile = PowerProfile.Performance;
            else
                PowerProfiles.profile = PowerProfile.PowerSaver;
            break;
        case PowerProfile.Performance:
            PowerProfiles.profile = PowerProfile.PowerSaver;
            break;
        }
    }
}
