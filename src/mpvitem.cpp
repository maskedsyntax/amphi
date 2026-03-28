#include "mpvitem.h"
#include <QOpenGLFramebufferObject>
#include <QOpenGLFunctions>
#include <QQuickWindow>
#include <QThread>

class MpvRenderer : public QQuickFramebufferObject::Renderer {
public:
    MpvRenderer(MpvItem *item) : m_item(item), mpv_gl(nullptr) {
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
            qWarning("failed to initialize mpv GL context");
        }

        mpv_render_context_set_update_callback(mpv_gl, [](void *ctx) {
            auto *renderer = static_cast<MpvRenderer *>(ctx);
            QMetaObject::invokeMethod(renderer->m_item, "update", Qt::QueuedConnection);
        }, this);
    }

    ~MpvRenderer() override {
        if (mpv_gl) {
            mpv_render_context_free(mpv_gl);
        }
    }

    void render() override {
        if (!mpv_gl) return;

        QOpenGLFunctions *f = QOpenGLContext::currentContext()->functions();
        f->glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        f->glClear(GL_COLOR_BUFFER_BIT);

        if (m_fbo) {
            mpv_opengl_fbo mpfbo{
                static_cast<int>(m_fbo->handle()),
                m_fbo->width(),
                m_fbo->height(),
                0
            };
            int flip_y = 0;

            mpv_render_param params[] = {
                {MPV_RENDER_PARAM_OPENGL_FBO, &mpfbo},
                {MPV_RENDER_PARAM_FLIP_Y, &flip_y},
                {MPV_RENDER_PARAM_INVALID, nullptr}
            };
            mpv_render_context_render(mpv_gl, params);
        }
    }

    QOpenGLFramebufferObject *createFramebufferObject(const QSize &size) override {
        m_fbo.reset(new QOpenGLFramebufferObject(size));
        return m_fbo.get();
    }

    void synchronize(QQuickFramebufferObject *item) override {
        // No explicit synchronization needed yet
    }

private:
    MpvItem *m_item;
    mpv_render_context *mpv_gl;
    std::unique_ptr<QOpenGLFramebufferObject> m_fbo;
};

MpvItem::MpvItem(QQuickItem *parent) : QQuickFramebufferObject(parent), mpv(mpv_create()) {
    if (!mpv) {
        qWarning("failed creating mpv context");
        return;
    }

    mpv_request_log_messages(mpv, "terminal-default");
    mpv_initialize(mpv);

    mpv_observe_property(mpv, 0, "duration", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "time-pos", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "pause", MPV_FORMAT_FLAG);
    mpv_observe_property(mpv, 0, "volume", MPV_FORMAT_DOUBLE);

    mpv_set_wakeup_callback(mpv, on_mpv_events, this);
}

MpvItem::~MpvItem() {
    if (mpv) {
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
        if (event->event_id == MPV_EVENT_NONE) break;
        handleMpvEvent(event);
    }
}

void MpvItem::handleMpvEvent(mpv_event *event) {
    if (event->event_id == MPV_EVENT_PROPERTY_CHANGE) {
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
        }
    }
}

QString MpvItem::mediaUrl() const { return m_mediaUrl; }

void MpvItem::setMediaUrl(const QString &url) {
    m_mediaUrl = url;
    emit mediaUrlChanged();
}

void MpvItem::load(const QString &url) {
    setMediaUrl(url);
    const char *args[] = {"loadfile", url.toUtf8().constData(), nullptr};
    mpv_command(mpv, args);
}

void MpvItem::play() {
    int pause = 0;
    mpv_set_property(mpv, "pause", MPV_FORMAT_FLAG, &pause);
}

void MpvItem::pause() {
    int pause = 1;
    mpv_set_property(mpv, "pause", MPV_FORMAT_FLAG, &pause);
}

void MpvItem::stop() {
    const char *args[] = {"stop", nullptr};
    mpv_command(mpv, args);
}

void MpvItem::setPosition(int pos) {
    double dpos = pos;
    mpv_set_property(mpv, "time-pos", MPV_FORMAT_DOUBLE, &dpos);
}

void MpvItem::setVolume(int vol) {
    double dvol = vol;
    mpv_set_property(mpv, "volume", MPV_FORMAT_DOUBLE, &dvol);
}
