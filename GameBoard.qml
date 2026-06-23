import QtQuick
import QtQuick.Controls

Item {
    id: boardRoot
    property int rows: 9
    property int cols: 9
    property string gameState: "idle"
    property var model: null
    signal revealCell(int index)
    signal toggleFlag(int index)
    signal chord(int index)
    readonly property real cellSize: Math.floor(Math.min(
        (width - 32) / cols,
        (height - 32) / rows,
        48
    ))
    readonly property real boardW: cols * cellSize
    readonly property real boardH: rows * cellSize
    ScrollView {
        anchors.fill: parent
        contentWidth: Math.max(boardW + 32, width)
        contentHeight: Math.max(boardH + 32, height)
        clip: true
        ScrollBar.horizontal.policy: boardW + 32 > width ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: boardH + 32 > height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        Item {
            width: Math.max(boardW + 32, boardRoot.width)
            height: Math.max(boardH + 32, boardRoot.height)
            Rectangle {
                anchors.centerIn: parent
                width: boardW + 20
                height: boardH + 20
                radius: 8
                color: "transparent"
                border.color: {
                    if (gameState === "won") return "#00ff88"
                    if (gameState === "lost") return "#ff4757"
                    return "#30363d"
                }
                border.width: 2
                opacity: 0.5
                Behavior on border.color { ColorAnimation { duration: 400 } }
            }
            Item {
                id: gridContainer
                anchors.centerIn: parent
                width: boardW
                height: boardH
                GridView {
                    id: grid
                    anchors.fill: parent
                    cellWidth: cellSize
                    cellHeight: cellSize
                    model: boardRoot.model
                    interactive: false
                    clip: false
                    delegate: CellItem {
                        width: cellSize - 2
                        height: cellSize - 2
                        x: 1; y: 1
                        isMine: model.isMine
                        isRevealed: model.isRevealed
                        isFlagged: model.isFlagged
                        isQuestionMark: model.isQuestionMark
                        neighborCount: model.neighborCount
                        isExploded: model.isExploded
                        cellIndex: model.cellIndex
                        gameOver: gameState === "lost" || gameState === "won"
                        onLeftClicked: function(index) {
                            if (isRevealed && neighborCount > 0)
                                boardRoot.chord(index)
                            else
                                boardRoot.revealCell(index)
                        }
                        onRightClicked: function(index) { boardRoot.toggleFlag(index) }
                        onDoubleClicked: function(index) { boardRoot.chord(index) }
                    }
                }
            }
            Rectangle {
                anchors.centerIn: parent
                width: boardW + 4
                height: boardH + 4
                radius: 8
                color: "transparent"
                visible: gameState === "idle"
                Text {
                    anchors.centerIn: parent
                    text: "Натисніть на клітинку\nщоб розпочати"
                    color: "#4a5568"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    lineHeight: 1.6
                    font.letterSpacing: 1
                }
            }
        }
    }
    Connections {
        target: boardRoot.model
        function onCellsRevealed(indices) {
            // Animate cells with staggered delay
            for (var i = 0; i < Math.min(indices.length, 50); i++) {
                var item = grid.itemAtIndex(indices[i])
                if (item) item.playReveal(i * 8)
            }
        }
    }
}
