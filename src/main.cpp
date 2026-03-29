#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <clocale>
#include <QSettings>
#include "mpvitem.h"
#include "playlistmodel.h"

int main(int argc, char *argv[])
{
    setlocale(LC_NUMERIC, "C");
    
    QGuiApplication app(argc, argv);
    app.setOrganizationName("Amphi");
    app.setApplicationName("AmphiPlayer");

    // Force OpenGL for libmpv rendering via QQuickFramebufferObject
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    qmlRegisterType<MpvItem>("Amphi", 1, 0, "MpvVideo");
    
    PlaylistModel playlist;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("playlistModel", &playlist);

    const QUrl url("qrc:/amphi/qml/main.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
