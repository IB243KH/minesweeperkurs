#pragma once
#include <QAbstractListModel>
#include <QTimer>
#include <QVector>
#include "databasemanager.h"

struct Cell {
    bool isMine = false;
    bool isRevealed = false;
    bool isFlagged = false;
    bool isQuestionMark = false;
    int neighborCount = 0;
    bool isExploded = false;  // the mine that was clicked
};

class GameModel : public QAbstractListModel {
    Q_OBJECT

    Q_PROPERTY(int rows READ rows NOTIFY boardChanged)
    Q_PROPERTY(int cols READ cols NOTIFY boardChanged)
    Q_PROPERTY(int mines READ mines NOTIFY boardChanged)
    Q_PROPERTY(int flagsLeft READ flagsLeft NOTIFY flagsLeftChanged)
    Q_PROPERTY(int elapsedTime READ elapsedTime NOTIFY elapsedTimeChanged)
    Q_PROPERTY(QString gameState READ gameState NOTIFY gameStateChanged)
    Q_PROPERTY(QString difficulty READ difficulty NOTIFY boardChanged)
    Q_PROPERTY(QVariantList records READ records NOTIFY recordsChanged)

public:
    enum CellRole {
        IsMineRole = Qt::UserRole + 1,
        IsRevealedRole,
        IsFlaggedRole,
        IsQuestionMarkRole,
        NeighborCountRole,
        IsExplodedRole,
        IndexRole
    };

    explicit GameModel(QObject* parent = nullptr);

    // QAbstractListModel
    int rowCount(const QModelIndex& parent = {}) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int rows() const { return m_rows; }
    int cols() const { return m_cols; }
    int mines() const { return m_mines; }
    int flagsLeft() const { return m_flagsLeft; }
    int elapsedTime() const { return m_elapsed; }
    QString gameState() const { return m_gameState; }
    QString difficulty() const { return m_difficulty; }
    QVariantList records() const;

    Q_INVOKABLE void newGame(int rows, int cols, int mines, const QString& difficulty);
    Q_INVOKABLE void revealCell(int index);
    Q_INVOKABLE void toggleFlag(int index);
    Q_INVOKABLE void chord(int index);  // reveal neighbors if flags match count
    Q_INVOKABLE void loadRecords(const QString& difficulty = QString());

signals:
    void boardChanged();
    void flagsLeftChanged();
    void elapsedTimeChanged();
    void gameStateChanged();
    void recordsChanged();
    void cellExploded(int index);
    void cellsRevealed(QVariantList indices);

private:
    void placeMines(int firstIndex);
    void calculateNeighbors();
    void floodReveal(int index);
    void checkWin();
    void revealAllMines();
    int neighborMines(int index) const;
    QVector<int> neighbors(int index) const;

    int m_rows = 9, m_cols = 9, m_mines = 10;
    int m_flagsLeft = 10;
    int m_elapsed = 0;
    bool m_firstClick = true;
    QString m_gameState = "idle";  // idle, playing, won, lost
    QString m_difficulty = "easy";

    QVector<Cell> m_cells;
    QTimer m_timer;
    DatabaseManager m_db;
};
