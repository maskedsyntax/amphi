#pragma once

#include <QQuickFramebufferObject>
#include <QString>
#include <mpv/client.h>
#include <mpv/render_gl.h>

class MpvItem : public QQuickFramebufferObject {
    Q_OBJECT
    Q_PROPERTY(QString mediaUrl READ mediaUrl WRITE setMediaUrl NOTIFY mediaUrlChanged)
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(int duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(int position READ position WRITE setPosition NOTIFY positionChanged)
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY playingChanged)
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(double audioDelay READ audioDelay WRITE setAudioDelay NOTIFY audioDelayChanged)
    Q_PROPERTY(double subtitleDelay READ subtitleDelay WRITE setSubtitleDelay NOTIFY subtitleDelayChanged)
    Q_PROPERTY(double playbackSpeed READ playbackSpeed WRITE setPlaybackSpeed NOTIFY playbackSpeedChanged)
    
    // Tracks
    Q_PROPERTY(QVariantList audioTracks READ audioTracks NOTIFY tracksChanged)
    Q_PROPERTY(QVariantList subtitleTracks READ subtitleTracks NOTIFY tracksChanged)
    Q_PROPERTY(int currentAudioTrack READ currentAudioTrack WRITE setCurrentAudioTrack NOTIFY tracksChanged)
    Q_PROPERTY(int currentSubtitleTrack READ currentSubtitleTrack WRITE setCurrentSubtitleTrack NOTIFY tracksChanged)

public:
    explicit MpvItem(QQuickItem *parent = nullptr);
    ~MpvItem() override;

    Renderer *createRenderer() const override;

    QString mediaUrl() const;
    void setMediaUrl(const QString &url);

    QString title() const { return m_title; }

    int duration() const { return m_duration; }
    int position() const { return m_position; }
    Q_INVOKABLE void setPosition(int pos);

    bool isPlaying() const { return m_isPlaying; }
    int volume() const { return m_volume; }
    Q_INVOKABLE void setVolume(int vol);

    double audioDelay() const { return m_audioDelay; }
    void setAudioDelay(double delay);

    double subtitleDelay() const { return m_subtitleDelay; }
    void setSubtitleDelay(double delay);

    double playbackSpeed() const { return m_playbackSpeed; }
    void setPlaybackSpeed(double speed);

    // Tracks
    QVariantList audioTracks() const { return m_audioTracks; }
    QVariantList subtitleTracks() const { return m_subtitleTracks; }
    int currentAudioTrack() const { return m_currentAudioTrack; }
    int currentSubtitleTrack() const { return m_currentSubtitleTrack; }
    Q_INVOKABLE void setCurrentAudioTrack(int id);
    Q_INVOKABLE void setCurrentSubtitleTrack(int id);

    Q_INVOKABLE void play();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void load(const QString &url);
    Q_INVOKABLE void addSubtitle(const QString &url);

signals:
    void mediaUrlChanged();
    void titleChanged();
    void durationChanged();
    void positionChanged();
    void playingChanged();
    void volumeChanged();
    void audioDelayChanged();
    void subtitleDelayChanged();
    void playbackSpeedChanged();
    void tracksChanged();
    void endOfFile();

private slots:
    void onMpvEvents();

private:
    mpv_handle *mpv;
    QString m_mediaUrl;
    QString m_title;
    int m_duration = 0;
    int m_position = 0;
    bool m_isPlaying = false;
    int m_volume = 100;
    double m_audioDelay = 0.0;
    double m_subtitleDelay = 0.0;
    double m_playbackSpeed = 1.0;

    // Tracks
    QVariantList m_audioTracks;
    QVariantList m_subtitleTracks;
    int m_currentAudioTrack = -1;
    int m_currentSubtitleTrack = -1;

    void handleMpvEvent(mpv_event *event);
    void updateTracks();
    static void on_mpv_events(void *ctx);

    friend class MpvRenderer;
};
