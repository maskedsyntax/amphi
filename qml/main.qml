import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Amphi
import QtCore

ApplicationWindow {
    id: window
    width: settings.windowWidth
    height: settings.windowHeight
    x: settings.windowX
    y: settings.windowY
    minimumWidth: 900
    minimumHeight: 600
    visible: true
    title: player.title ? player.title + " - Amphi Player" : "Amphi Player"

    property bool isDarkMode: settings.isDarkMode
    property color primaryColor: "#0EA5E9"
    property color bgApp: isDarkMode ? "#020617" : "#F1F5F9"
    property color bgSurface: isDarkMode ? "#B30F172A" : "#B3FFFFFF"
    property color outlineColor: isDarkMode ? "#334155" : "#E2E8F0"
    property color textMain: isDarkMode ? "#F8FAFC" : "#0F172A"
    property color textMuted: isDarkMode ? "#94A3B8" : "#64748B"

    property bool showQueue: settings.showQueue
    property bool controlsVisible: true

    color: bgApp

    Settings {
        id: settings
        property int windowWidth: 1100
        property int windowHeight: 750
        property int windowX: -1
        property int windowY: -1
        property bool isDarkMode: true
        property bool showQueue: true
        property int volume: 100
    }

    Component.onDestruction: {
        settings.windowWidth = window.width
        settings.windowHeight = window.height
        settings.windowX = window.x
        settings.windowY = window.y
        settings.isDarkMode = window.isDarkMode
        settings.showQueue = window.showQueue
        settings.volume = player.volume
    }

    function toggleFullscreen() {
        window.visibility = window.visibility === Window.FullScreen ? Window.Windowed : Window.FullScreen
        showControls()
    }

    DropArea {
        anchors.fill: parent
        onDropped: (drop) => {
            if (drop.hasUrls) {
                let mediaUrls = []
                let subUrls = []
                for (let url of drop.urls) {
                    let str = url.toString().toLowerCase()
                    if (str.endsWith(".srt") || str.endsWith(".ass") || str.endsWith(".vtt")) {
                        subUrls.push(url)
                    } else {
                        mediaUrls.push(url)
                    }
                }
                if (mediaUrls.length > 0) playlistModel.addFiles(mediaUrls)
                if (subUrls.length > 0 && player.mediaUrl !== "") player.addSubtitle(subUrls[0])
                showControls()
            }
        }
    }

    Timer {
        id: hideControlsTimer
        interval: 3000
        repeat: false
        onTriggered: {
            if (player.isPlaying && !headerBar.isHovered && !playbackPanel.isHovered && !queuePanel.isHovered) {
                controlsVisible = false
            }
        }
    }

    function showControls() {
        controlsVisible = true
        hideControlsTimer.restart()
    }

    Shortcut { sequence: "Q"; onActivated: { showQueue = !showQueue; showControls() } }
    Shortcut { sequence: "F"; onActivated: toggleFullscreen() }
    Shortcut { sequence: "Space"; onActivated: { player.isPlaying ? player.pause() : player.play(); showControls() } }

    FileDialog {
        id: fileDialog
        title: "Add media files"
        currentFolder: StandardPaths.writableLocation(StandardPaths.MoviesLocation)
        fileMode: FileDialog.OpenFiles
        onAccepted: { playlistModel.addFiles(selectedFiles); showControls() }
    }

    FileDialog {
        id: subDialog
        title: "Load external subtitle"
        nameFilters: ["Subtitle files (*.srt *.ass *.vtt *.ssa)"]
        onAccepted: { player.addSubtitle(selectedFile); showControls() }
    }

    Connections {
        target: playlistModel
        function onPlaybackRequested(url) {
            player.load(url)
            player.play()
            showControls()
        }
    }

    Connections {
        target: player
        function onEndOfFile() { playlistModel.next() }
        function onPlayingChanged() { showControls() }
    }

    header: ToolBar {
        id: headerBar
        background: Rectangle { color: "transparent" }
        height: 50
        opacity: controlsVisible ? 1.0 : 0.0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 250 } }

        property bool isHovered: maHeader.containsMouse
        MouseArea { id: maHeader; anchors.fill: parent; hoverEnabled: true; propagateComposedEvents: true; onPositionChanged: showControls() }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20; anchors.rightMargin: 20

            Text {
                text: player.title || "Amphi Player"
                color: textMain
                font.pixelSize: 14; font.bold: true
                elide: Text.ElideMiddle
                Layout.maximumWidth: parent.width * 0.7
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 4
                ToolButton {
                    icon.source: "qrc:/amphi/assets/icons/folder-open.svg"
                    icon.color: textMain; icon.width: 18; icon.height: 18
                    onClicked: fileDialog.open(); background: null
                }
                ToolButton {
                    icon.source: "qrc:/amphi/assets/icons/list-video.svg"
                    icon.color: showQueue ? primaryColor : textMain; icon.width: 18; icon.height: 18
                    onClicked: showQueue = !showQueue; background: null
                }
                ToolButton {
                    icon.source: isDarkMode ? "qrc:/amphi/assets/icons/sun.svg" : "qrc:/amphi/assets/icons/moon.svg"
                    icon.color: textMain; icon.width: 18; icon.height: 18
                    onClicked: isDarkMode = !isDarkMode; background: null
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onPositionChanged: showControls()
            onClicked: showControls()
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "black"; radius: 12; clip: true

                    MpvVideo { id: player; anchors.fill: parent; volume: settings.volume }

                    // DOUBLE CLICK FULLSCREEN & TOGGLE PLAY
                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: if (tapCount === 2) toggleFullscreen()
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: player.mediaUrl === ""
                        spacing: 16
                        Image {
                            source: "qrc:/amphi/assets/icons/play.svg"
                            sourceSize: Qt.size(64, 64); width: 48; height: 48; opacity: 0.15
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Button {
                            text: "Open Media"
                            onClicked: fileDialog.open()
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // Playback Panel
                Rectangle {
                    id: playbackPanel
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    color: bgSurface; radius: 16; border.color: outlineColor; border.width: 1
                    opacity: controlsVisible ? 1.0 : 0.0
                    visible: opacity > 0
                    Behavior on opacity { NumberAnimation { duration: 250 } }

                    property bool isHovered: maPlayback.containsMouse
                    MouseArea { id: maPlayback; anchors.fill: parent; hoverEnabled: true; propagateComposedEvents: true; onPositionChanged: showControls() }

                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 12; spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Text { text: formatTime(player.position); color: primaryColor; font.pixelSize: 11; font.bold: true; font.family: "Menlo" }
                            Slider {
                                Layout.fillWidth: true; Layout.preferredHeight: 20
                                from: 0; to: player.duration > 0 ? player.duration : 1
                                value: player.position
                                onMoved: player.setPosition(value)
                            }
                            Text { text: formatTime(player.duration); color: textMuted; font.pixelSize: 11; font.family: "Menlo" }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 24

                                RowLayout {
                                    spacing: 8
                                    ToolButton {
                                        icon.source: "qrc:/amphi/assets/icons/skip-back.svg"
                                        icon.color: textMain; icon.width: 16; icon.height: 16
                                        onClicked: playlistModel.previous(); background: null
                                    }
                                    RoundButton {
                                        implicitWidth: 38; implicitHeight: 38
                                        icon.source: player.isPlaying ? "qrc:/amphi/assets/icons/pause.svg" : "qrc:/amphi/assets/icons/play.svg"
                                        icon.color: "white"; icon.width: 18; icon.height: 18
                                        background: Rectangle { radius: 19; color: primaryColor }
                                        onClicked: player.isPlaying ? player.pause() : player.play()
                                    }
                                    ToolButton {
                                        icon.source: "qrc:/amphi/assets/icons/skip-forward.svg"
                                        icon.color: textMain; icon.width: 16; icon.height: 16
                                        onClicked: playlistModel.next(); background: null
                                    }
                                }

                                RowLayout {
                                    spacing: 4
                                    ToolButton {
                                        icon.source: player.volume === 0 ? "qrc:/amphi/assets/icons/volume-x.svg" : "qrc:/amphi/assets/icons/volume-2.svg"
                                        icon.color: textMain; icon.width: 16; icon.height: 16
                                        background: null; enabled: false
                                    }
                                    Slider {
                                        width: 80; from: 0; to: 100; value: player.volume
                                        onMoved: player.setVolume(value)
                                    }
                                }
                            }

                            RowLayout {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 0
                                
                                ToolButton {
                                    text: "Audio"; font.pixelSize: 10; visible: player.audioTracks.length > 1
                                    contentItem: Text { text: parent.text; font: parent.font; color: textMain; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    background: Item {}
                                    onClicked: audioMenu.open()
                                    Menu {
                                        id: audioMenu
                                        Instantiator {
                                            model: player.audioTracks
                                            MenuItem { text: modelData.title; onTriggered: player.setCurrentAudioTrack(modelData.id) }
                                            onObjectAdded: (index, object) => audioMenu.addItem(object)
                                        }
                                    }
                                }
                                ToolButton {
                                    text: "Subs"; font.pixelSize: 10; visible: player.subtitleTracks.length > 0
                                    contentItem: Text { text: parent.text; font: parent.font; color: textMain; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    background: Item {}
                                    onClicked: subMenu.open()
                                    Menu {
                                        id: subMenu
                                        MenuItem { text: "None"; onTriggered: player.setCurrentSubtitleTrack(-1) }
                                        Instantiator {
                                            model: player.subtitleTracks
                                            MenuItem { text: modelData.title; onTriggered: player.setCurrentSubtitleTrack(modelData.id) }
                                            onObjectAdded: (index, object) => subMenu.addItem(object)
                                        }
                                        MenuSeparator {}
                                        MenuItem { text: "Load External..."; onTriggered: subDialog.open() }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Queue
            Rectangle {
                id: queuePanel
                Layout.preferredWidth: 260; Layout.fillHeight: true
                color: bgSurface; radius: 12; border.color: outlineColor; border.width: 1
                opacity: controlsVisible ? 1.0 : 0.0
                visible: opacity > 0 && showQueue
                Behavior on opacity { NumberAnimation { duration: 250 } }

                property bool isHovered: maQueue.containsMouse
                MouseArea { id: maQueue; anchors.fill: parent; hoverEnabled: true; propagateComposedEvents: true; onPositionChanged: showControls() }

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 12; spacing: 12
                    RowLayout {
                        Text { text: "Queue"; color: textMain; font.pixelSize: 14; font.bold: true }
                        Item { Layout.fillWidth: true }
                        ToolButton { text: "Clear"; font.pixelSize: 10; onClicked: playlistModel.clear(); background: null }
                    }
                    ListView {
                        Layout.fillWidth: true; Layout.fillHeight: true; model: playlistModel; spacing: 4; clip: true
                        delegate: ItemDelegate {
                            width: parent.width; height: 38
                            background: Rectangle { radius: 6; color: index === playlistModel.currentIndex ? primaryColor : (hovered ? outlineColor : "transparent"); opacity: index === playlistModel.currentIndex ? 0.1 : 0.4 }
                            contentItem: RowLayout {
                                spacing: 10
                                Text { text: index + 1; color: textMuted; font.pixelSize: 10; Layout.preferredWidth: 20 }
                                Text { text: model.title; color: textMain; font.pixelSize: 12; font.bold: index === playlistModel.currentIndex; elide: Text.ElideRight; Layout.fillWidth: true }
                                ToolButton {
                                    icon.source: "qrc:/amphi/assets/icons/volume-x.svg"
                                    icon.color: textMuted; icon.width: 12; icon.height: 12
                                    onClicked: playlistModel.remove(index); background: null
                                }
                            }
                            onClicked: playlistModel.currentIndex = index
                        }
                    }
                }
            }
        }
    }

    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0) return "00:00";
        let h = Math.floor(seconds / 3600);
        let m = Math.floor((seconds % 3600) / 60);
        let s = Math.floor(seconds % 60);
        let str = (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
        if (h > 0) str = h + ":" + str;
        return str;
    }
}
