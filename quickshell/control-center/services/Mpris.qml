import Quickshell.Services.Mpris
import QtQuick

Item {
    id: root

    readonly property var players: Mpris.players

    property var activePlayer: null

    readonly property bool available: activePlayer !== null

    readonly property string identity: activePlayer ? activePlayer.identity : ""

    readonly property string title: activePlayer ? activePlayer.trackTitle : ""

    readonly property string artist: activePlayer ? activePlayer.trackArtist : ""

    readonly property string album: activePlayer ? activePlayer.trackAlbum : ""

    readonly property string artUrl: activePlayer ? activePlayer.trackArtUrl : ""

    readonly property bool playing: activePlayer ? activePlayer.isPlaying : false

    readonly property real position: activePlayer ? activePlayer.position : 0

    readonly property real length: activePlayer ? activePlayer.length : 0

    readonly property bool canTogglePlaying: activePlayer ? activePlayer.canTogglePlaying : false

    readonly property bool canNext: activePlayer ? activePlayer.canGoNext : false

    readonly property bool canPrevious: activePlayer ? activePlayer.canGoPrevious : false

    readonly property bool canSeek: activePlayer ? activePlayer.canSeek : false

    function selectPlayer(player) {
        activePlayer = player;
    }

    function togglePlaying() {
        if (activePlayer && activePlayer.canTogglePlaying)
            activePlayer.togglePlaying();
    }

    function next() {
        if (activePlayer && activePlayer.canGoNext)
            activePlayer.next();
    }

    function previous() {
        if (activePlayer && activePlayer.canGoPrevious)
            activePlayer.previous();
    }

    function seek(offset) {
        if (activePlayer && activePlayer.canSeek)
            activePlayer.seek(offset);
    }

    function seekTo(position) {
        if (activePlayer && activePlayer.canSeek)
            activePlayer.position = position;
    }

    function selectDefaultPlayer() {
        var list = players.values;

        console.log("MPRIS players:", list.length);

        activePlayer = null;

        for (var i = 0; i < list.length; ++i) {
            var player = list[i];

            console.log("Player:", player.identity, "playing:", player.isPlaying);

            if (player.isPlaying) {
                activePlayer = player;
                return;
            }
        }

        if (list.length > 0)
            activePlayer = list[0];
    }

    Connections {
        target: players

        function onValuesChanged() {
            console.log("MPRIS player list changed");
            if (root.activePlayer && players.values.indexOf(root.activePlayer) !== -1)
                return;

            root.selectDefaultPlayer();
        }
    }

    Component.onCompleted: {
        root.selectDefaultPlayer();
    }

    Timer {
        interval: 250
        repeat: true

        running: root.activePlayer !== null && root.activePlayer.isPlaying

        onTriggered: {
            if (root.activePlayer)
                root.activePlayer.positionChanged();
        }
    }
}
