import QtQuick

Rectangle {
    id: cell

    property bool isMine: false
    property bool isRevealed: false
    property bool isFlagged: false
    property bool isQuestionMark: false
    property int neighborCount: 0
    property bool isExploded: false
    property bool gameOver: false
    property int cellIndex: 0

    signal leftClicked(int index)
    signal rightClicked(int index)
    signal doubleClicked(int index)

    // Colors for numbers
    readonly property var numColors: [
        "transparent", "#2196f3", "#4caf50", "#f44336",
        "#9c27b0", "#ff5722", "#00bcd4", "#333333", "#9e9e9e"
    ]

    radius: 4

    // Background state
    color: {
        if (isExploded) return "#c0392b"
        if (isRevealed && isMine) return "#3d1a1a"
        if (isRevealed) return "#0d1117"
        return hovered ? "#2d333b" : "#21262d"
    }

    border.color: {
        if (isExploded) return "#e74c3c"
        if (isRevealed && isMine && !isExploded) return "#5a1a1a"
        if (isRevealed) return "#161b22"
        return hovered ? "#444c56" : "#30363d"
    }
    border.width: 1

    Behavior on color { ColorAnimation { duration: 80 } }

    property bool hovered: false

    // Content
    Text {
        anchors.centerIn: parent
        visible: isRevealed && !isMine && neighborCount > 0
        text: neighborCount > 0 ? neighborCount : ""
        font.pixelSize: Math.min(parent.width, parent.height) * 0.52
        font.weight: Font.Bold
        color: numColors[Math.min(neighborCount, 8)]
    }

    Text {
        id: mineText
        anchors.centerIn: parent
        visible: isRevealed && isMine
        text: "💣"
        font.pixelSize: Math.min(parent.width, parent.height) * 0.55
        opacity: 1
    }

    Text {
        id: flagText
        anchors.centerIn: parent
        visible: isFlagged
        text: "🚩"
        font.pixelSize: Math.min(parent.width, parent.height) * 0.55
    }

    Text {
        anchors.centerIn: parent
        visible: isQuestionMark
        text: "❓"
        font.pixelSize: Math.min(parent.width, parent.height) * 0.5
    }

    // Wrong flag indicator
    Text {
        anchors.centerIn: parent
        visible: isRevealed && isFlagged && !isMine
        text: "❌"
        font.pixelSize: Math.min(parent.width, parent.height) * 0.55
        z: 2
    }

    // Reveal animation
    property real revealScale: 1.0
    scale: revealScale

    // Explode animation
    SequentialAnimation {
        id: explodeAnim
        running: isExploded
        NumberAnimation { target: cell; property: "revealScale"; to: 1.4; duration: 100; easing.type: Easing.OutQuad }
        NumberAnimation { target: cell; property: "revealScale"; to: 0.9; duration: 80 }
        NumberAnimation { target: cell; property: "revealScale"; to: 1.1; duration: 60 }
        NumberAnimation { target: cell; property: "revealScale"; to: 1.0; duration: 100 }
    }

    // Reveal ripple
    function playReveal(delay) {
        revealTimer.interval = delay
        revealTimer.start()
    }

    Timer {
        id: revealTimer
        onTriggered: revealAnim.start()
    }

    SequentialAnimation {
        id: revealAnim
        NumberAnimation { target: cell; property: "revealScale"; to: 0.85; duration: 60; easing.type: Easing.InQuad }
        NumberAnimation { target: cell; property: "revealScale"; to: 1.0; duration: 120; easing.type: Easing.OutBack }
    }

    // Flag placement animation
    SequentialAnimation {
        id: flagAnim
        running: isFlagged
        NumberAnimation { target: flagText; property: "scale"; from: 1.8; to: 1.0; duration: 250; easing.type: Easing.OutBack }
    }

    // Press animation
    states: [
        State {
            name: "pressed"
            PropertyChanges { target: cell; revealScale: 0.88 }
        }
    ]

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        property bool holdingLeft: false
        property real pressX: 0
        property real pressY: 0

        onEntered: cell.hovered = true
        onExited: { cell.hovered = false; cell.state = "" }

        onPressed: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                holdingLeft = true
                if (!cell.isRevealed && !cell.isFlagged)
                    cell.state = "pressed"
                pressX = mouse.x
                pressY = mouse.y
            }
        }

        onReleased: function(mouse) {
            cell.state = ""
            if (mouse.button === Qt.LeftButton) {
                holdingLeft = false
                if (Math.abs(mouse.x - pressX) < 5 && Math.abs(mouse.y - pressY) < 5) {
                    cell.leftClicked(cell.cellIndex)
                }
            } else if (mouse.button === Qt.RightButton) {
                cell.rightClicked(cell.cellIndex)
            }
        }

        onDoubleClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton)
                cell.doubleClicked(cell.cellIndex)
        }
    }
}
