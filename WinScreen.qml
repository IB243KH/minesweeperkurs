import QtQuick

Rectangle {
    id: winScreen
    property int elapsedTime: 0
    property string difficulty: "easy"

    signal newGame()
    signal restart()
    signal showRecords()

    color: "#CC0d1117"
    radius: 0

    opacity: 0
    visible: false

    onVisibleChanged: {
        if (visible) {
            opacity = 0
            showAnim.start()
            confettiTimer.start()
        }
    }

    NumberAnimation {
        id: showAnim
        target: winScreen
        property: "opacity"
        to: 1
        duration: 400
        easing.type: Easing.OutCubic
    }

    // Confetti particles
    property var particles: []
    Timer {
        id: confettiTimer
        interval: 16
        repeat: true
        property int frame: 0
        onTriggered: {
            frame++
            canvas.requestPaint()
            if (frame > 300) stop()
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        opacity: 0.85

        property var dots: {
            var arr = []
            for (var i = 0; i < 80; i++) {
                arr.push({
                    x: Math.random() * width,
                    y: -20 - Math.random() * 300,
                    vx: (Math.random() - 0.5) * 3,
                    vy: 2 + Math.random() * 4,
                    color: ["#00ff88","#ffd60a","#ff4757","#74b9ff","#fd79a8","#00cec9"][Math.floor(Math.random()*6)],
                    size: 6 + Math.random() * 8,
                    rot: Math.random() * 360,
                    rspeed: (Math.random() - 0.5) * 8
                })
            }
            return arr
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            for (var d of dots) {
                d.x += d.vx
                d.y += d.vy
                d.rot += d.rspeed
                if (d.y > height + 20) d.y = -20
                ctx.save()
                ctx.translate(d.x, d.y)
                ctx.rotate(d.rot * Math.PI / 180)
                ctx.fillStyle = d.color
                ctx.globalAlpha = Math.min(1, (height - d.y) / height + 0.3)
                ctx.fillRect(-d.size/2, -d.size/4, d.size, d.size/2)
                ctx.restore()
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 24

        // Trophy icon with bounce
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "🏆"
            font.pixelSize: 80

            SequentialAnimation on scale {
                running: winScreen.visible
                NumberAnimation { from: 0; to: 1.2; duration: 400; easing.type: Easing.OutBack }
                NumberAnimation { to: 1.0; duration: 200 }
                loops: 1
            }
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "ПЕРЕМОГА!"
                font.pixelSize: 40
                font.weight: Font.Black
                font.letterSpacing: 8
                color: "#00ff88"

                SequentialAnimation on opacity {
                    running: winScreen.visible; loops: Animation.Infinite
                    NumberAnimation { to: 0.6; duration: 900; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Ви пройшли мінне поле!"
                font.pixelSize: 16
                color: "#8892a4"
                font.letterSpacing: 2
            }
        }

        // Time result card
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 260
            height: 80
            radius: 16
            color: "#0d2818"
            border.color: "#00ff88"
            border.width: 2

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "ВАШ ЧАС"
                    font.pixelSize: 11
                    font.letterSpacing: 4
                    color: "#4caf50"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        var m = Math.floor(elapsedTime / 60)
                        var s = elapsedTime % 60
                        return (m > 0 ? m + "хв " : "") + s + " сек"
                    }
                    font.pixelSize: 32
                    font.weight: Font.Black
                    color: "#00ff88"
                    font.family: "Courier New"
                }
            }
        }

        // Buttons
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16

            WinButton { text: "🏠 МЕНЮ"; accent: "#8892a4"; onClicked: winScreen.newGame() }
            WinButton { text: "↺ ЩЕ РАЗ"; accent: "#00ff88"; onClicked: winScreen.restart() }
            WinButton { text: "🏆 РЕКОРДИ"; accent: "#ffd60a"; onClicked: winScreen.showRecords() }
        }
    }

    component WinButton: Rectangle {
        property string text: ""
        property color accent: "#00ff88"
        signal clicked()

        width: 120; height: 46
        radius: 10
        color: btnHover.containsMouse ? Qt.darker(accent, 3) : "transparent"
        border.color: btnHover.containsMouse ? accent : Qt.darker(accent, 2)
        border.width: 2

        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
            anchors.centerIn: parent
            text: parent.text
            font.pixelSize: 12
            font.letterSpacing: 1
            color: parent.accent
        }

        MouseArea {
            id: btnHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
