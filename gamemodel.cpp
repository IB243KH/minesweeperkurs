#include "gamemodel.h"
#include <QRandomGenerator>
#include <algorithm>

GameModel::GameModel(QObject* parent) : QAbstractListModel(parent) {
    m_db.init();

    connect(&m_timer, &QTimer::timeout, this, [this]() {
        m_elapsed++;
        emit elapsedTimeChanged();
    });
}

int GameModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;
    return m_cells.size();
}

QVariant GameModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() >= m_cells.size()) return {};
    const Cell& c = m_cells[index.row()];
    switch (role) {
        case IsMineRole: return c.isMine;
        case IsRevealedRole: return c.isRevealed;
        case IsFlaggedRole: return c.isFlagged;
        case IsQuestionMarkRole: return c.isQuestionMark;
        case NeighborCountRole: return c.neighborCount;
        case IsExplodedRole: return c.isExploded;
        case IndexRole: return index.row();
    }
    return {};
}

QHash<int, QByteArray> GameModel::roleNames() const {
    return {
        {IsMineRole, "isMine"},
        {IsRevealedRole, "isRevealed"},
        {IsFlaggedRole, "isFlagged"},
        {IsQuestionMarkRole, "isQuestionMark"},
        {NeighborCountRole, "neighborCount"},
        {IsExplodedRole, "isExploded"},
        {IndexRole, "cellIndex"}
    };
}

void GameModel::newGame(int rows, int cols, int mines, const QString& difficulty) {
    m_rows = rows;
    m_cols = cols;
    m_mines = qMin(mines, rows * cols - 9);
    m_flagsLeft = m_mines;
    m_elapsed = 0;
    m_firstClick = true;
    m_difficulty = difficulty;
    m_gameState = "idle";

    m_timer.stop();

    beginResetModel();
    m_cells.clear();
    m_cells.resize(m_rows * m_cols);
    endResetModel();

    emit boardChanged();
    emit flagsLeftChanged();
    emit elapsedTimeChanged();
    emit gameStateChanged();
}

void GameModel::placeMines(int firstIndex) {
    QVector<int> positions;
    // Protect first click and neighbors
    QVector<int> safe = neighbors(firstIndex);
    safe.append(firstIndex);

    for (int i = 0; i < m_rows * m_cols; ++i)
        if (!safe.contains(i)) positions.append(i);

    // Shuffle and take first m_mines
    for (int i = positions.size() - 1; i > 0; --i) {
        int j = QRandomGenerator::global()->bounded(i + 1);
        std::swap(positions[i], positions[j]);
    }

    for (int i = 0; i < m_mines && i < positions.size(); ++i)
        m_cells[positions[i]].isMine = true;

    calculateNeighbors();
}

void GameModel::calculateNeighbors() {
    for (int i = 0; i < m_cells.size(); ++i) {
        if (m_cells[i].isMine) { m_cells[i].neighborCount = -1; continue; }
        int count = 0;
        for (int n : neighbors(i))
            if (m_cells[n].isMine) count++;
        m_cells[i].neighborCount = count;
    }
}

QVector<int> GameModel::neighbors(int index) const {
    int r = index / m_cols;
    int c = index % m_cols;
    QVector<int> result;
    for (int dr = -1; dr <= 1; dr++)
        for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            int nr = r + dr, nc = c + dc;
            if (nr >= 0 && nr < m_rows && nc >= 0 && nc < m_cols)
                result.append(nr * m_cols + nc);
        }
    return result;
}

void GameModel::revealCell(int index) {
    if (index < 0 || index >= m_cells.size()) return;
    Cell& c = m_cells[index];
    if (c.isRevealed || c.isFlagged) return;
    if (m_gameState == "won" || m_gameState == "lost") return;

    if (m_firstClick) {
        m_firstClick = false;
        placeMines(index);
        m_gameState = "playing";
        emit gameStateChanged();
        m_timer.start(1000);
    }

    if (c.isMine) {
        c.isRevealed = true;
        c.isExploded = true;
        auto idx = createIndex(index, 0);
        emit dataChanged(idx, idx);
        emit cellExploded(index);
        revealAllMines();
        m_timer.stop();
        m_gameState = "lost";
        emit gameStateChanged();
        return;
    }

    floodReveal(index);
    checkWin();
}

void GameModel::floodReveal(int index) {
    QVector<int> queue = {index};
    QVariantList revealed;

    while (!queue.isEmpty()) {
        int idx = queue.takeFirst();
        if (idx < 0 || idx >= m_cells.size()) continue;
        Cell& cell = m_cells[idx];
        if (cell.isRevealed || cell.isFlagged || cell.isMine) continue;

        cell.isRevealed = true;
        revealed.append(idx);
        auto midx = createIndex(idx, 0);
        emit dataChanged(midx, midx);

        if (cell.neighborCount == 0) {
            for (int n : neighbors(idx))
                if (!m_cells[n].isRevealed && !m_cells[n].isFlagged)
                    queue.append(n);
        }
    }

    if (!revealed.isEmpty())
        emit cellsRevealed(revealed);
}

void GameModel::toggleFlag(int index) {
    if (index < 0 || index >= m_cells.size()) return;
    if (m_gameState == "won" || m_gameState == "lost") return;
    if (m_gameState == "idle") return;

    Cell& c = m_cells[index];
    if (c.isRevealed) return;

    if (!c.isFlagged && !c.isQuestionMark) {
        if (m_flagsLeft <= 0) return;
        c.isFlagged = true;
        m_flagsLeft--;
    } else if (c.isFlagged) {
        c.isFlagged = false;
        c.isQuestionMark = true;
        m_flagsLeft++;
    } else {
        c.isQuestionMark = false;
    }

    auto idx = createIndex(index, 0);
    emit dataChanged(idx, idx);
    emit flagsLeftChanged();
}

void GameModel::chord(int index) {
    if (index < 0 || index >= m_cells.size()) return;
    Cell& c = m_cells[index];
    if (!c.isRevealed || c.neighborCount <= 0) return;
    if (m_gameState != "playing") return;

    auto ns = neighbors(index);
    int flagCount = 0;
    for (int n : ns) if (m_cells[n].isFlagged) flagCount++;

    if (flagCount == c.neighborCount) {
        for (int n : ns)
            if (!m_cells[n].isRevealed && !m_cells[n].isFlagged)
                revealCell(n);
    }
}

void GameModel::checkWin() {
    int unrevealed = 0;
    for (const Cell& c : m_cells)
        if (!c.isRevealed && !c.isMine) unrevealed++;

    if (unrevealed == 0) {
        m_timer.stop();
        m_gameState = "won";
        // Auto-flag remaining mines
        for (int i = 0; i < m_cells.size(); i++) {
            if (m_cells[i].isMine && !m_cells[i].isFlagged) {
                m_cells[i].isFlagged = true;
                auto idx = createIndex(i, 0);
                emit dataChanged(idx, idx);
            }
        }
        m_flagsLeft = 0;
        emit flagsLeftChanged();
        m_db.addRecord(m_difficulty, m_elapsed, m_rows, m_cols, m_mines);
        emit gameStateChanged();
        emit recordsChanged();
    }
}

void GameModel::revealAllMines() {
    for (int i = 0; i < m_cells.size(); i++) {
        Cell& c = m_cells[i];
        if (c.isMine && !c.isExploded) {
            c.isRevealed = true;
            auto idx = createIndex(i, 0);
            emit dataChanged(idx, idx);
        }
        // Show wrong flags
        if (c.isFlagged && !c.isMine) {
            c.isRevealed = true;
            auto idx = createIndex(i, 0);
            emit dataChanged(idx, idx);
        }
    }
}

QVariantList GameModel::records() const {
    return m_db.getRecords();
}

void GameModel::loadRecords(const QString& difficulty) {
    emit recordsChanged();
}
