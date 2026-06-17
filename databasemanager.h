#pragma once
#include <QObject>
#include <QSqlDatabase>
#include <QVariantList>

class DatabaseManager : public QObject {
    Q_OBJECT
public:
    explicit DatabaseManager(QObject* parent = nullptr);
    ~DatabaseManager();

    bool init();
    bool addRecord(const QString& difficulty, int timeSeconds, int rows, int cols, int mines);
    QVariantList getRecords(const QString& difficulty = QString()) const;
    QVariantList getTopRecords(const QString& difficulty, int limit = 10) const;

private:
    mutable QSqlDatabase m_db;
    bool createTables();
};
