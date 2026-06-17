import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    signal startGame(int rows, int cols, int mines, string difficulty)
    signal showRecords()

    // Background animated grid
    Canvas {
        id: bgCanvas
        anchors.fill: parent
        opacity: 0.07

        property real t: 0
        NumberAnimation on t { from: 0; to: 1; duration: 8000; loops: Animation.Infinite }
        onTChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.strokeStyle = "#00ff88"
            ctx.lineWidth = 1
            var sz = 44
            for (var x = 0; x < width + sz; x += sz) {
                for (var y = 0; y < height + sz; y += sz) {
                    var pulse = Math.sin(t * Math.PI * 2 + x * 0.05 + y * 0.05) * 0.5 + 0.5
                    ctx.globalAlpha = pulse * 0.8
                    ctx.strokeRect(x - sz/2, y - sz/2, sz, sz)
                }
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 0

        // Title
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "💣"
                font.pixelSize: 72
                style: Text.Outline
                styleColor: "#00ff88"

                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.08; duration: 1200; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 1200; easing.type: Easing.InOutSine }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "САПЕР"
                font.pixelSize: 48
                font.letterSpacing: 16
                font.weight: Font.Black
                color: "#ffffff"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "MINESWEEPER"
                font.pixelSize: 13
                font.letterSpacing: 8
                color: "#00ff88"
                opacity: 0.8
            }
        }

        Item { width: 1; height: 40 }

        // Difficulty cards
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "ОБЕРІТЬ РІВЕНЬ СКЛАДНОСТІ"
            font.pixelSize: 11
            font.letterSpacing: 4
            color: "#8892a4"
        }

        Item { width: 1; height: 16 }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16

            DifficultyCard {
                title: "ЛЕГКИЙ"
                subtitle: "9×9 · 10 мін"
                icon: "🌱"
                accentColor: "#00d68f"
                description: "Для початківців"
                onClicked: startGame(9, 9, 10, "easy")
            }

            DifficultyCard {
                title: "СЕРЕДНІЙ"
                subtitle: "16×16 · 40 мін"
                icon: "⚡"
                accentColor: "#ffd60a"
                description: "Для досвідчених"
                onClicked: startGame(16, 16, 40, "medium")
            }

            DifficultyCard {
                title: "СКЛАДНИЙ"
                subtitle: "16×30 · 99 мін"
                icon: "💀"
                accentColor: "#ff4757"
                description: "Для майстрів"
                onClicked: startGame(16, 30, 99, "hard")
            }
        }


        Item { width: 1; height: 20 }

        // Records button
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 200
            height: 44
            radius: 8
            color: "transparent"
            border.color: "#30363d"
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: 8
                Text { text: "🏆"; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: "РЕКОРДИ"
                    font.pixelSize: 13
                    font.letterSpacing: 4
                    color: "#8892a4"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: showRecords()
                onEntered: parent.border.color = "#ffd60a"
                onExited: parent.border.color = "#30363d"
            }
        }
    }

    // DifficultyCard component
    component DifficultyCard: Rectangle {
        id: card
        property string title: ""
        property string subtitle: ""
        property string icon: ""
        property color accentColor: "#00ff88"
        property string description: ""
        signal clicked()

        width: 130
        height: 160
        radius: 14
        color: hovered ? Qt.darker(accentColor, 4) : "#161b22"
        border.color: hovered ? accentColor : "#21262d"
        border.width: hovered ? 2 : 1

        property bool hovered: false
        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        scale: hovered ? 1.04 : 1.0
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

        Column {
            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: card.icon
                font.pixelSize: 36
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: card.title
                font.pixelSize: 13
                font.letterSpacing: 2
                font.weight: Font.Bold
                color: card.hovered ? card.accentColor : "#ffffff"
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: card.subtitle
                font.pixelSize: 12
                color: "#8892a4"
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: card.description
                font.pixelSize: 10
                color: card.hovered ? card.accentColor : "#4a5568"
                font.letterSpacing: 1
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onEntered: card.hovered = true
            onExited: card.hovered = false
            onClicked: card.clicked()
        }
    }

}
