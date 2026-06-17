#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "gamemodel.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    app.setOrganizationName("MinesweeperApp");
    app.setApplicationName("Minesweeper");

    qmlRegisterType<GameModel>("MinesweeperApp", 1, 0, "GameModel");

    QQmlApplicationEngine engine;
    engine.loadFromModule("MinesweeperApp", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
