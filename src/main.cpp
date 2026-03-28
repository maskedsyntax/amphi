#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include "mpvitem.h"

int main(int argc, char *argv[])
{
    // Force OpenGL for libmpv rendering via QQuickFramebufferObject
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    QGuiApplication app(argc, argv);

    qmlRegisterType<MpvItem>("Amphi", 1, 0, "MpvVideo");

    QQmlApplicationEngine engine;
    const QUrl url("qrc:/amphi/qml/main.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
