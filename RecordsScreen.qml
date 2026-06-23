import QtQuick
import QtQuick.Controls

Item {
    property var records: []
    signal back()
    property string filterDifficulty: "all"
    property var filteredRecords: {
        if (filterDifficulty === "all") return records
        return records.filter(r => r.difficulty === filterDifficulty)
    }
    Rectangle {
        anchors.fill: parent
        color: "#0d1117"
    }
    Column {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            width: parent.width
            height: 64
            color: "#161b22"
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: "#21262d"
            }
            Row {
                anchors {
                    left: parent.left; right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 20; rightMargin: 20
                }
                Rectangle {
                    width: 36; height: 36; radius: 8
                    color: bkHov.containsMouse ? "#21262d" : "transparent"
                    border.color: "#30363d"; border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Text { anchors.centerIn: parent; text: "←"; font.pixelSize: 18; color: "#8892a4" }

                    MouseArea {
                        id: bkHov; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor; onClicked: back()
                    }
                }
                Item { width: 16; height: 1 }
                Text {
                    text: "🏆 ТАБЛИЦЯ РЕКОРДІВ"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    font.letterSpacing: 4
                    color: "#ffd60a"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Item { width: 1; height: 1; implicitWidth: parent.width - 360 }
                Row {
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter
                    Repeater {
                        model: [
                            {key: "all", label: "ВСІ"},
                            {key: "easy", label: "ЛЕГКИЙ"},
                            {key: "medium", label: "СЕРЕДНІЙ"},
                            {key: "hard", label: "СКЛАДНИЙ"},
                            {key: "custom", label: "ВЛАСНИЙ"}
                        ]
                        delegate: Rectangle {
                            property var item: modelData
                            width: tabLabel.width + 20; height: 28; radius: 6
                            color: filterDifficulty === item.key ? "#ffd60a" : "transparent"
                            border.color: filterDifficulty === item.key ? "#ffd60a" : "#30363d"
                            border.width: 1
                            Text {
                                id: tabLabel
                                anchors.centerIn: parent
                                text: item.label
                                font.pixelSize: 10; font.letterSpacing: 2
                                color: filterDifficulty === item.key ? "#0d1117" : "#8892a4"
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: filterDifficulty = item.key
                            }
                        }
                    }
                }
            }
        }
        Item {
            width: parent.width
            height: parent.height - 64
            Rectangle {
                id: tableHeader
                width: parent.width
                height: 36
                color: "#161b22"
                z: 1
                Row {
                    anchors {
                        fill: parent
                        leftMargin: 32; rightMargin: 32
                    }
                    Repeater {
                        model: [
                            {label: "#", w: 44},
                            {label: "РІВЕНЬ", w: 120},
                            {label: "ЧАС", w: 100},
                            {label: "ПОЛЕ", w: 100},
                            {label: "МІНИ", w: 80},
                            {label: "ДАТА", w: 120}
                        ]
                        delegate: Text {
                            text: modelData.label
                            width: modelData.w
                            font.pixelSize: 10; font.letterSpacing: 3
                            color: "#4a5568"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width; height: 1; color: "#21262d"
                }
            }

            ListView {
                anchors {
                    top: tableHeader.bottom
                    left: parent.left; right: parent.right; bottom: parent.bottom
                }
                model: filteredRecords
                clip: true
                spacing: 0

                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Rectangle {
                    property var rec: modelData
                    width: ListView.view.width
                    height: 48
                    color: index % 2 === 0 ? "#0d1117" : "#0a0e15"

                    Rectangle {
                        width: 3; height: parent.height
                        color: {
                            if (rec.rank === 1) return "#ffd700"
                            if (rec.rank === 2) return "#c0c0c0"
                            if (rec.rank === 3) return "#cd7f32"
                            return "transparent"
                        }
                    }

                    Row {
                        anchors {
                            fill: parent
                            leftMargin: 32; rightMargin: 32
                        }

                        Text {
                            width: 44; anchors.verticalCenter: parent.verticalCenter
                            text: rec.rank <= 3 ? ["🥇","🥈","🥉"][rec.rank - 1] : "#" + rec.rank
                            font.pixelSize: rec.rank <= 3 ? 20 : 14
                            color: "#8892a4"
                        }

                        Rectangle {
                            width: 120; height: 48
                            color: "transparent"
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                anchors.centerIn: parent
                                width: diffBadge.width + 16; height: 22; radius: 5
                                color: {
                                    var d = rec.difficulty
                                    if (d === "easy") return "#0d2818"
                                    if (d === "medium") return "#2a2000"
                                    if (d === "hard") return "#2a0a0a"
                                    return "#1a1a2e"
                                }
                                border.color: {
                                    var d = rec.difficulty
                                    if (d === "easy") return "#00d68f"
                                    if (d === "medium") return "#ffd60a"
                                    if (d === "hard") return "#ff4757"
                                    return "#7c3aed"
                                }
                                border.width: 1

                                Text {
                                    id: diffBadge
                                    anchors.centerIn: parent
                                    text: {
                                        var d = rec.difficulty
                                        if (d === "easy") return "Легкий"
                                        if (d === "medium") return "Середній"
                                        if (d === "hard") return "Складний"
                                        return "Власний"
                                    }
                                    font.pixelSize: 11
                                    color: {
                                        var d = rec.difficulty
                                        if (d === "easy") return "#00d68f"
                                        if (d === "medium") return "#ffd60a"
                                        if (d === "hard") return "#ff4757"
                                        return "#a78bfa"
                                    }
                                }
                            }
                        }

                        Text {
                            width: 100; anchors.verticalCenter: parent.verticalCenter
                            text: {
                                var m = Math.floor(rec.time / 60)
                                var s = rec.time % 60
                                return (m > 0 ? m + "хв " : "") + s + "с"
                            }
                            font.pixelSize: 14; font.weight: Font.Bold; font.family: "Courier New"
                            color: rec.rank === 1 ? "#ffd700" : "#00ff88"
                        }

                        Text {
                            width: 100; anchors.verticalCenter: parent.verticalCenter
                            text: rec.rows + " × " + rec.cols
                            font.pixelSize: 13; color: "#8892a4"
                        }

                        Text {
                            width: 80; anchors.verticalCenter: parent.verticalCenter
                            text: "💣 " + rec.mines
                            font.pixelSize: 13; color: "#8892a4"
                        }

                        Text {
                            width: 120; anchors.verticalCenter: parent.verticalCenter
                            text: rec.date
                            font.pixelSize: 12; color: "#4a5568"
                        }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width; height: 1; color: "#161b22"
                    }
                }

                Item {
                    visible: filteredRecords.length === 0
                    anchors.fill: parent

                    Column {
                        anchors.centerIn: parent
                        spacing: 12

                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "🏜️"; font.pixelSize: 48 }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Поки немає рекордів"
                            font.pixelSize: 16; color: "#4a5568"; font.letterSpacing: 2
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Зіграйте і станьте першим!"
                            font.pixelSize: 13; color: "#30363d"
                        }
                    }
                }
            }
        }
    }
}
