import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Amphi

ApplicationWindow {
    id: window
    width: 1280
    height: 800
    minimumWidth: 960
    minimumHeight: 640
    visible: true
    title: qsTr("Amphi Player")

    property bool isDarkMode: true
    property color primaryColor: "#0EA5E9"
    property color bgApp: isDarkMode ? "#020617" : "#F0F9FF"
    property color bgSurface: isDarkMode ? "#0F172A" : "#FFFFFF"
    property color outlineColor: isDarkMode ? "#334155" : "#CBD5E1"
    property color textMain: isDarkMode ? "#FFFFFF" : "#000000"
    property color textMuted: isDarkMode ? "#94A3B8" : "#64748B"

    property bool showQueue: true

    color: bgApp

    Shortcut {
        sequence: "Q"
        onActivated: showQueue = !showQueue
    }

    Shortcut {
        sequence: "Space"
        onActivated: player.isPlaying ? player.pause() : player.play()
    }

    FileDialog {
        id: fileDialog
        title: "Please choose a media file"
        nameFilters: ["Media files (*.mp4 *.mkv *.avi *.mp3 *.wav *.webm)"]
        onAccepted: {
            player.load(selectedFile)
            player.play()
        }
    }

    // Top Toolbar
    header: ToolBar {
        background: Rectangle {
            color: "transparent"
        }
        RowLayout {
            anchors.fill: parent
            anchors.margins: 16

            Text {
                text: "Amphi"
                color: textMain
                font.pixelSize: 20
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            ToolButton {
                icon.source: "qrc:/amphi/assets/icons/folder-open.svg"
                icon.color: textMain
                onClicked: fileDialog.open()
                ToolTip.text: "Open File"
                ToolTip.visible: hovered
            }

            ToolButton {
                icon.source: "qrc:/amphi/assets/icons/list-video.svg"
                icon.color: showQueue ? primaryColor : textMain
                onClicked: showQueue = !showQueue
                ToolTip.text: "Toggle Queue"
                ToolTip.visible: hovered
            }

            ToolButton {
                icon.source: isDarkMode ? "qrc:/amphi/assets/icons/sun.svg" : "qrc:/amphi/assets/icons/moon.svg"
                icon.color: textMain
                onClicked: isDarkMode = !isDarkMode
                ToolTip.text: "Toggle Theme"
                ToolTip.visible: hovered
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Main Player Area
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            // Video Container
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "black"
                radius: 28
                clip: true

                MpvVideo {
                    id: player
                    anchors.fill: parent
                }

                // Empty State
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: player.mediaUrl === ""
                    spacing: 16

                    Text {
                        text: "Ready for Media"
                        color: "white"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Button {
                        text: "Open Media Files"
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: fileDialog.open()
                    }
                }
            }

            // Playback Controls
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 110
                color: bgSurface
                radius: 28
                border.color: outlineColor
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    // Progress Bar
                    RowLayout {
                        spacing: 16
                        Text {
                            text: formatTime(player.position)
                            color: primaryColor
                            font.bold: true
                        }
                        Slider {
                            id: progressSlider
                            Layout.fillWidth: true
                            from: 0
                            to: player.duration > 0 ? player.duration : 1
                            value: player.position
                            onMoved: player.setPosition(value)
                        }
                        Text {
                            text: formatTime(player.duration)
                            color: textMuted
                        }
                    }

                    // Transport Controls
                    RowLayout {
                        Item { Layout.fillWidth: true } // spacer

                        RoundButton {
                            icon.source: "qrc:/amphi/assets/icons/skip-back.svg"
                            icon.color: textMain
                        }

                        RoundButton {
                            icon.source: player.isPlaying ? "qrc:/amphi/assets/icons/pause.svg" : "qrc:/amphi/assets/icons/play.svg"
                            icon.color: "white"
                            background: Rectangle {
                                radius: width / 2
                                color: primaryColor
                            }
                            onClicked: player.isPlaying ? player.pause() : player.play()
                            implicitWidth: 48
                            implicitHeight: 48
                        }

                        RoundButton {
                            icon.source: "qrc:/amphi/assets/icons/skip-forward.svg"
                            icon.color: textMain
                        }

                        Item { Layout.fillWidth: true } // spacer

                        // Volume Control
                        RowLayout {
                            spacing: 8
                            IconImage {
                                source: player.volume === 0 ? "qrc:/amphi/assets/icons/volume-x.svg" : "qrc:/amphi/assets/icons/volume-2.svg"
                                color: textMuted
                                sourceSize.width: 20
                                sourceSize.height: 20
                            }
                            Slider {
                                Layout.preferredWidth: 100
                                from: 0
                                to: 100
                                value: player.volume
                                onMoved: player.setVolume(value)
                            }
                        }
                    }
                }
            }
        }

        // Queue Panel
        Rectangle {
            visible: showQueue
            Layout.preferredWidth: 340
            Layout.fillHeight: true
            color: bgSurface
            radius: 28
            border.color: outlineColor
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20

                Text {
                    text: "Queue"
                    color: textMain
                    font.pixelSize: 20
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: outlineColor
                }

                Text {
                    text: "Queue is empty"
                    color: textMuted
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillHeight: true
                }
            }
        }
    }

    function formatTime(seconds) {
        if (isNaN(seconds)) return "00:00";
        let h = Math.floor(seconds / 3600);
        let m = Math.floor((seconds % 3600) / 60);
        let s = Math.floor(seconds % 60);
        let str = (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
        if (h > 0) {
            str = h + ":" + str;
        }
        return str;
    }
}
