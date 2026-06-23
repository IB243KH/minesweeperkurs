import QtQuick
import QtQuick.Controls
import MinesweeperApp 1.0

Window {
    id: root
    width: 900
    height: 720
    minimumWidth: 480
    minimumHeight: 560
    visible: true
    title: "💣 Сапер"
    color: "#0d1117"
    GameModel {
        id: game
    }
    StackView {
        id: stack
        anchors.fill: parent

        initialItem: menuScreen
        pushEnter: Transition {
            PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
            PropertyAnimation { property: "scale"; from: 0.92; to: 1; duration: 280; easing.type: Easing.OutCubic }
        }
        pushExit: Transition {
            PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
        }
        popEnter: Transition {
            PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
        }
        popExit: Transition {
            PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
            PropertyAnimation { property: "scale"; from: 1; to: 0.92; duration: 200 }
        }
    }
    Component {
        id: menuScreen
        MenuScreen {
            onStartGame: function(rows, cols, mines, difficulty) {
                game.newGame(rows, cols, mines, difficulty)
                stack.push(gameScreen)
            }
            onShowRecords: {
                stack.push(recordsScreen)
            }
        }
    }
    Component {
        id: gameScreen
        Item {
            Column {
                anchors.fill: parent
                spacing: 0
                GameHeader {
                    width: parent.width
                    height: 72
                    flagsLeft: game.flagsLeft
                    elapsedTime: game.elapsedTime
                    gameState: game.gameState
                    difficulty: game.difficulty
                    onNewGame: stack.pop()
                    onRestart: game.newGame(game.rows, game.cols, game.mines, game.difficulty)
                }
                GameBoard {
                    width: parent.width
                    height: parent.height - 72
                    model: game
                    rows: game.rows
                    cols: game.cols
                    gameState: game.gameState
                    onRevealCell: function(index) { game.revealCell(index) }
                    onToggleFlag: function(index) { game.toggleFlag(index) }
                    onChord: function(index) { game.chord(index) }
                }
            }
            WinScreen {
                anchors.fill: parent
                visible: game.gameState === "won"
                elapsedTime: game.elapsedTime
                difficulty: game.difficulty
                onNewGame: stack.pop()
                onRestart: game.newGame(game.rows, game.cols, game.mines, game.difficulty)
                onShowRecords: stack.push(recordsScreen)
            }
        }
    }
    Component {
        id: recordsScreen
        RecordsScreen {
            records: game.records
            onBack: stack.pop()
        }
    }
}
