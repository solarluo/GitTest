#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "GitTest.h"
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("duoxianc", "Main");

    return app.exec();
}
