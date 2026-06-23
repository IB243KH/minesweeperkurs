#include "databasemanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QStandardPaths>
#include <QDir>
#include <QDateTime>

DatabaseManager::DatabaseManager(QObject* parent) : QObject(parent) {}

DatabaseManager::~DatabaseManager() {
    if (m_db.isOpen())
        m_db.close();
}
bool DatabaseManager::init() {
    QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dbPath);
    dbPath += "/minesweeper.db";

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dbPath);

    if (!m_db.open()) {
        qWarning() << "Cannot open database:" << m_db.lastError().text();
        return false;
    }

    return createTables();
}

bool DatabaseManager::createTables() {
    QSqlQuery q(m_db);
    return q.exec(R"(
        CREATE TABLE IF NOT EXISTS records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            difficulty TEXT NOT NULL,
            time_seconds INTEGER NOT NULL,
            rows INTEGER NOT NULL,
            cols INTEGER NOT NULL,
            mines INTEGER NOT NULL,
            played_at TEXT NOT NULL
        )
    )");
}

bool DatabaseManager::addRecord(const QString& difficulty, int timeSeconds, int rows, int cols, int mines) {
    QSqlQuery q(m_db);
    q.prepare("INSERT INTO records (difficulty, time_seconds, rows, cols, mines, played_at) VALUES (?, ?, ?, ?, ?, ?)");
    q.addBindValue(difficulty);
    q.addBindValue(timeSeconds);
    q.addBindValue(rows);
    q.addBindValue(cols);
    q.addBindValue(mines);
    q.addBindValue(QDateTime::currentDateTime().toString(Qt::ISODate));
    return q.exec();
}

QVariantList DatabaseManager::getRecords(const QString& difficulty) const {
    QSqlQuery q(m_db);
    if (difficulty.isEmpty())
        q.exec("SELECT difficulty, time_seconds, rows, cols, mines, played_at FROM records ORDER BY time_seconds ASC LIMIT 50");
    else {
        q.prepare("SELECT difficulty, time_seconds, rows, cols, mines, played_at FROM records WHERE difficulty=? ORDER BY time_seconds ASC LIMIT 20");
        q.addBindValue(difficulty);
        q.exec();
    }

    QVariantList result;
    int rank = 1;
    while (q.next()) {
        QVariantMap rec;
        rec["rank"] = rank++;
        rec["difficulty"] = q.value(0).toString();
        rec["time"] = q.value(1).toInt();
        rec["rows"] = q.value(2).toInt();
        rec["cols"] = q.value(3).toInt();
        rec["mines"] = q.value(4).toInt();
        rec["date"] = q.value(5).toString().left(10);
        result.append(rec);
    }
    return result;
}

QVariantList DatabaseManager::getTopRecords(const QString& difficulty, int limit) const {
    QSqlQuery q(m_db);
    q.prepare("SELECT difficulty, time_seconds, rows, cols, mines, played_at FROM records WHERE difficulty=? ORDER BY time_seconds ASC LIMIT ?");
    q.addBindValue(difficulty);
    q.addBindValue(limit);
    q.exec();

    QVariantList result;
    int rank = 1;
    while (q.next()) {
        QVariantMap rec;
        rec["rank"] = rank++;
        rec["difficulty"] = q.value(0).toString();
        rec["time"] = q.value(1).toInt();
        rec["rows"] = q.value(2).toInt();
        rec["cols"] = q.value(3).toInt();
        rec["mines"] = q.value(4).toInt();
        rec["date"] = q.value(5).toString().left(10);
        result.append(rec);
    }
    return result;
}
