import QtQuick
import QtQuick.Controls

Rectangle {
    id: header
    color: "#161b22"
    border.color: "#21262d"
    border.width: 0
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#21262d"
    }
    property int flagsLeft: 0
    property int elapsedTime: 0
    property string gameState: "idle"
    property string difficulty: "easy"
    signal newGame()
    signal restart()
    Row {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 20
            rightMargin: 20
        }
        Rectangle {
            width: 36; height: 36
            radius: 8
            color: backHover.containsMouse ? "#21262d" : "transparent"
            border.color: "#30363d"
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter
            Text { anchors.centerIn: parent; text: "←"; font.pixelSize: 18; color: "#8892a4" }
            MouseArea {
                id: backHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: header.newGame()
            }
        }
        Item { width: 12; height: 1 }
        Rectangle {
            height: 28
            width: diffLabel.width + 24
            radius: 6
            anchors.verticalCenter: parent.verticalCenter
            color: {
                if (difficulty === "easy") return "#0d2818"
                if (difficulty === "medium") return "#2a2000"
                if (difficulty === "hard") return "#2a0a0a"
                return "#1a1a2e"
            }
            border.color: {
                if (difficulty === "easy") return "#00d68f"
                if (difficulty === "medium") return "#ffd60a"
                if (difficulty === "hard") return "#ff4757"
                return "#7c3aed"
            }
            border.width: 1
            Text {
                id: diffLabel
                anchors.centerIn: parent
                text: {
                    if (difficulty === "easy") return "ЛЕГКИЙ"
                    if (difficulty === "medium") return "СЕРЕДНІЙ"
                    if (difficulty === "hard") return "СКЛАДНИЙ"
                    return "ВЛАСНИЙ"
                }
                font.pixelSize: 11
                font.letterSpacing: 2
                color: {
                    if (difficulty === "easy") return "#00d68f"
                    if (difficulty === "medium") return "#ffd60a"
                    if (difficulty === "hard") return "#ff4757"
                    return "#a78bfa"
                }
            }
        }
        Item { width: parent.width - 320; height: 1 }
        Item {
            width: parent.width - 320
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            Rectangle {
                anchors.centerIn: parent
                width: 46; height: 46
                radius: 23
                color: faceHover.containsMouse ? "#21262d" : "#0d1117"
                border.color: "#30363d"
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    font.pixelSize: 24
                    text: {
                        if (gameState === "won") return "😎"
                        if (gameState === "lost") return "😵"
                        if (gameState === "playing") return faceHover.pressed ? "😮" : "🙂"
                        return "🙂"
                    }
                }
                MouseArea {
                    id: faceHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: header.restart()
                }
            }
        }
        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter
            Text { text: "🚩"; font.pixelSize: 20; anchors.verticalCenter: parent.verticalCenter }
            Text {
                text: flagsLeft < 0 ? flagsLeft : ("0" + flagsLeft).slice(-2 - (flagsLeft >= 100 ? 1 : 0))
                font.pixelSize: 28
                font.weight: Font.Black
                color: flagsLeft < 0 ? "#ff4757" : "#ff6b6b"
                font.family: "Courier New"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        Item { width: 24; height: 1 }
        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter

            Text { text: "⏱️"; font.pixelSize: 20; anchors.verticalCenter: parent.verticalCenter }
            Text {
                text: {
                    var m = Math.floor(elapsedTime / 60)
                    var s = elapsedTime % 60
                    return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
                }
                font.pixelSize: 28
                font.weight: Font.Black
                color: "#00ff88"
                font.family: "Courier New"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Item { width: 12; height: 1 }
        Rectangle {
            width: 36; height: 36
            radius: 8
            color: restartHover.containsMouse ? "#21262d" : "transparent"
            border.color: "#30363d"
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter

            Text { anchors.centerIn: parent; text: "↺"; font.pixelSize: 20; color: "#8892a4" }

            MouseArea {
                id: restartHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: header.restart()
            }
        }
    }
}
