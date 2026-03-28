#pragma once

#include <QQuickFramebufferObject>
#include <QString>
#include <mpv/client.h>
#include <mpv/render_gl.h>

class MpvItem : public QQuickFramebufferObject {
    Q_OBJECT
    Q_PROPERTY(QString mediaUrl READ mediaUrl WRITE setMediaUrl NOTIFY mediaUrlChanged)
    Q_PROPERTY(int duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(int position READ position WRITE setPosition NOTIFY positionChanged)
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY playingChanged)
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)

public:
    explicit MpvItem(QQuickItem *parent = nullptr);
    ~MpvItem() override;

    Renderer *createRenderer() const override;

    QString mediaUrl() const;
    void setMediaUrl(const QString &url);

    int duration() const { return m_duration; }
    int position() const { return m_position; }
    void setPosition(int pos);

    bool isPlaying() const { return m_isPlaying; }
    int volume() const { return m_volume; }
    void setVolume(int vol);

    Q_INVOKABLE void play();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void load(const QString &url);

signals:
    void mediaUrlChanged();
    void durationChanged();
    void positionChanged();
    void playingChanged();
    void volumeChanged();

private slots:
    void onMpvEvents();

private:
    mpv_handle *mpv;
    QString m_mediaUrl;
    int m_duration = 0;
    int m_position = 0;
    bool m_isPlaying = false;
    int m_volume = 100;

    void handleMpvEvent(mpv_event *event);
    static void on_mpv_events(void *ctx);

    friend class MpvRenderer;
};
