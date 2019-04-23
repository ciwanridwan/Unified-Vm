import QtQuick 2.0

Rectangle {
    id: reComponent
    property bool testMode: true
    height: textComponent.height + 10
    color: testMode ? "white" : "#cbd2db"
    width: 100
    Text {
        id: textComponent
        color: testMode ? "darkred" : "white"
        text: 'suggestion.name'
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        width: parent.width
        height: 30
        font.family: 'Microsoft YaHei'
        font.pixelSize: 20
        font.italic: true
        anchors.horizontalCenter: parent.horizontalCenter
    }
}

