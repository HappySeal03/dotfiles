import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: root

    readonly property var output: Pipewire.defaultAudioSink
    readonly property var input: Pipewire.defaultAudioSource

    PwObjectTracker {
        objects: [root.output, root.input]
    }

    readonly property real outputVolume: output && output.audio ? output.audio.volume : 0

    readonly property real inputVolume: input && input.audio ? input.audio.volume : 0

    readonly property bool outputMuted: output && output.audio ? output.audio.muted : false

    readonly property bool inputMuted: input && input.audio ? input.audio.muted : false

    function setOutputVolume(value) {
        if (output && output.audio)
            output.audio.volume = value;
    }

    function setInputVolume(value) {
        if (input && input.audio)
            input.audio.volume = value;
    }

    function toggleOutputMute() {
        if (output && output.audio)
            output.audio.muted = !output.audio.muted;
    }

    function toggleInputMute() {
        if (input && input.audio)
            input.audio.muted = !input.audio.muted;
    }
}
