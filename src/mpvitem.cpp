#include "mpvitem.h"
#include <QOpenGLFramebufferObject>
#include <QOpenGLFunctions>
#include <QQuickWindow>
#include <QThread>
#include <clocale>
#include <QDebug>
#include <QUrl>
#include <QFileInfo>

class MpvRenderer : public QQuickFramebufferObject::Renderer {
public:
    MpvRenderer(MpvItem *item) : m_item(item), mpv_gl(nullptr) {
        if (!m_item || !m_item->mpv) return;

        mpv_opengl_init_params gl_init_params{
            [](void *, const char *name) {
                return reinterpret_cast<void *>(QOpenGLContext::currentContext()->getProcAddress(name));
            },
            nullptr,
        };
        mpv_render_param params[] = {
            {MPV_RENDER_PARAM_API_TYPE, const_cast<void *>(static_cast<const void *>(MPV_RENDER_API_TYPE_OPENGL))},
            {MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, &gl_init_params},
            {MPV_RENDER_PARAM_INVALID, nullptr}
        };

        if (mpv_render_context_create(&mpv_gl, m_item->mpv, params) < 0) {
            qWarning() << "MpvRenderer: failed to initialize mpv GL context";
        }

        mpv_render_context_set_update_callback(mpv_gl, [](void *ctx) {
            auto *renderer = static_cast<MpvRenderer *>(ctx);
            QMetaObject::invokeMethod(renderer->m_item, "update", Qt::QueuedConnection);
        }, this);
    }

    ~MpvRenderer() override {
        if (mpv_gl) {
            mpv_render_context_set_update_callback(mpv_gl, nullptr, nullptr);
            mpv_render_context_free(mpv_gl);
        }
    }

    void render() override {
        if (!mpv_gl || !m_item || !m_item->mpv) return;

        QOpenGLFramebufferObject *fbo = framebufferObject();
        if (fbo) {
            mpv_opengl_fbo mpfbo{
                static_cast<int>(fbo->handle()),
                fbo->width(),
                fbo->height(),
                0
            };
            int flip_y = 0;

            mpv_render_param params[] = {
                {MPV_RENDER_PARAM_OPENGL_FBO, &mpfbo},
                {MPV_RENDER_PARAM_FLIP_Y, &flip_y},
                {MPV_RENDER_PARAM_INVALID, nullptr}
            };
            
            if (mpv_render_context_update(mpv_gl) & MPV_RENDER_UPDATE_FRAME) {
                mpv_render_context_render(mpv_gl, params);
            }
        }
    }

    QOpenGLFramebufferObject *createFramebufferObject(const QSize &size) override {
        return new QOpenGLFramebufferObject(size);
    }

    void synchronize(QQuickFramebufferObject *item) override {
        m_item = static_cast<MpvItem*>(item);
    }

private:
    MpvItem *m_item;
    mpv_render_context *mpv_gl;
};

MpvItem::MpvItem(QQuickItem *parent) : QQuickFramebufferObject(parent) {
    setlocale(LC_NUMERIC, "C");
    mpv = mpv_create();
    if (!mpv) {
        qWarning() << "MpvItem: failed creating mpv context";
        return;
    }

    mpv_set_option_string(mpv, "vo", "libmpv");
    mpv_set_option_string(mpv, "wid", "0");
    mpv_set_option_string(mpv, "hwdec", "auto");

    mpv_request_log_messages(mpv, "terminal-default");
    mpv_initialize(mpv);

    mpv_observe_property(mpv, 0, "duration", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "time-pos", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "pause", MPV_FORMAT_FLAG);
    mpv_observe_property(mpv, 0, "volume", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "audio-delay", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "sub-delay", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "track-list", MPV_FORMAT_NODE);

    mpv_set_wakeup_callback(mpv, on_mpv_events, this);
}

MpvItem::~MpvItem() {
    if (mpv) {
        mpv_set_wakeup_callback(mpv, nullptr, nullptr);
        mpv_terminate_destroy(mpv);
    }
}

QQuickFramebufferObject::Renderer *MpvItem::createRenderer() const {
    return new MpvRenderer(const_cast<MpvItem *>(this));
}

void MpvItem::on_mpv_events(void *ctx) {
    auto *item = static_cast<MpvItem *>(ctx);
    QMetaObject::invokeMethod(item, "onMpvEvents", Qt::QueuedConnection);
}

void MpvItem::onMpvEvents() {
    while (mpv) {
        mpv_event *event = mpv_wait_event(mpv, 0);
        if (!event || event->event_id == MPV_EVENT_NONE) break;
        handleMpvEvent(event);
    }
}

void MpvItem::handleMpvEvent(mpv_event *event) {
    switch (event->event_id) {
    case MPV_EVENT_PROPERTY_CHANGE: {
        auto *prop = static_cast<mpv_event_property *>(event->data);
        if (strcmp(prop->name, "duration") == 0 && prop->format == MPV_FORMAT_DOUBLE) {
            m_duration = static_cast<int>(*static_cast<double *>(prop->data));
            emit durationChanged();
        } else if (strcmp(prop->name, "time-pos") == 0 && prop->format == MPV_FORMAT_DOUBLE) {
            m_position = static_cast<int>(*static_cast<double *>(prop->data));
            emit positionChanged();
        } else if (strcmp(prop->name, "pause") == 0 && prop->format == MPV_FORMAT_FLAG) {
            m_isPlaying = !(*static_cast<int *>(prop->data));
            emit playingChanged();
        } else if (strcmp(prop->name, "volume") == 0 && prop->format == MPV_FORMAT_DOUBLE) {
            m_volume = static_cast<int>(*static_cast<double *>(prop->data));
            emit volumeChanged();
        } else if (strcmp(prop->name, "audio-delay") == 0 && prop->format == MPV_FORMAT_DOUBLE) {
            m_audioDelay = *static_cast<double *>(prop->data);
            emit audioDelayChanged();
        } else if (strcmp(prop->name, "sub-delay") == 0 && prop->format == MPV_FORMAT_DOUBLE) {
            m_subtitleDelay = *static_cast<double *>(prop->data);
            emit subtitleDelayChanged();
        } else if (strcmp(prop->name, "track-list") == 0) {
            updateTracks();
        }
        break;
    }
    case MPV_EVENT_END_FILE:
        emit endOfFile();
        break;
    default:
        break;
    }
}

void MpvItem::updateTracks() {
    m_audioTracks.clear();
    m_subtitleTracks.clear();

    mpv_node node;
    if (mpv_get_property(mpv, "track-list", MPV_FORMAT_NODE, &node) < 0) return;

    if (node.format == MPV_FORMAT_NODE_ARRAY) {
        for (int i = 0; i < node.u.list->num; i++) {
            mpv_node item = node.u.list->values[i];
            if (item.format != MPV_FORMAT_NODE_MAP) continue;

            int id = -1;
            QString type, title, lang;
            bool selected = false;

            for (int j = 0; j < item.u.list->num; j++) {
                char *key = item.u.list->keys[j];
                mpv_node val = item.u.list->values[j];

                if (strcmp(key, "id") == 0) id = val.u.int64;
                else if (strcmp(key, "type") == 0) type = QString::fromUtf8(val.u.string);
                else if (strcmp(key, "title") == 0) title = QString::fromUtf8(val.u.string);
                else if (strcmp(key, "lang") == 0) lang = QString::fromUtf8(val.u.string);
                else if (strcmp(key, "selected") == 0) selected = val.u.flag;
            }

            QVariantMap track;
            track["id"] = id;
            track["title"] = title.isEmpty() ? (lang.isEmpty() ? QString("Track %1").arg(id) : lang) : title;
            track["selected"] = selected;

            if (type == "audio") {
                m_audioTracks.append(track);
                if (selected) m_currentAudioTrack = id;
            } else if (type == "sub") {
                m_subtitleTracks.append(track);
                if (selected) m_currentSubtitleTrack = id;
            }
        }
    }
    mpv_free_node_contents(&node);
    emit tracksChanged();
}

QString MpvItem::mediaUrl() const { return m_mediaUrl; }

void MpvItem::setMediaUrl(const QString &url) {
    if (m_mediaUrl == url) return;
    m_mediaUrl = url;
    emit mediaUrlChanged();
}

void MpvItem::setCurrentAudioTrack(int id) {
    m_currentAudioTrack = id;
    mpv_set_property_string(mpv, "aid", QByteArray::number(id).constData());
}

void MpvItem::setCurrentSubtitleTrack(int id) {
    m_currentSubtitleTrack = id;
    if (id == -1) mpv_set_property_string(mpv, "sid", "no");
    else mpv_set_property_string(mpv, "sid", QByteArray::number(id).constData());
}

void MpvItem::load(const QString &url) {
    if (!mpv) return;
    m_mediaUrl = url;
    
    QString path = url;
    if (path.startsWith("file://")) {
        path = QUrl(url).toLocalFile();
    }
    m_title = QFileInfo(path).fileName();

    QByteArray utf8Path = path.toUtf8();
    const char *args[] = {"loadfile", utf8Path.constData(), nullptr};
    mpv_command(mpv, args);
    
    emit mediaUrlChanged();
    emit titleChanged();
}

void MpvItem::addSubtitle(const QString &url) {
    if (!mpv) return;
    QString path = url;
    if (path.startsWith("file://")) {
        path = QUrl(url).toLocalFile();
    }
    QByteArray utf8Path = path.toUtf8();
    const char *args[] = {"sub-add", utf8Path.constData(), "select", nullptr};
    mpv_command(mpv, args);
}

void MpvItem::play() {
    if (!mpv) return;
    int pause = 0;
    mpv_set_property(mpv, "pause", MPV_FORMAT_FLAG, &pause);
}

void MpvItem::pause() {
    if (!mpv) return;
    int pause = 1;
    mpv_set_property(mpv, "pause", MPV_FORMAT_FLAG, &pause);
}

void MpvItem::stop() {
    if (!mpv) return;
    const char *args[] = {"stop", nullptr};
    mpv_command(mpv, args);
}

void MpvItem::setPosition(int pos) {
    if (!mpv) return;
    double dpos = pos;
    mpv_set_property(mpv, "time-pos", MPV_FORMAT_DOUBLE, &dpos);
}

void MpvItem::setVolume(int vol) {
    if (!mpv) return;
    double dvol = vol;
    mpv_set_property(mpv, "volume", MPV_FORMAT_DOUBLE, &dvol);
}

void MpvItem::setAudioDelay(double delay) {
    if (!mpv) return;
    mpv_set_property(mpv, "audio-delay", MPV_FORMAT_DOUBLE, &delay);
}

void MpvItem::setSubtitleDelay(double delay) {
    if (!mpv) return;
    mpv_set_property(mpv, "sub-delay", MPV_FORMAT_DOUBLE, &delay);
}
