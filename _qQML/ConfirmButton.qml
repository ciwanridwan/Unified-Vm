import QtQuick 2.0

Rectangle {
    id: master_rec
    property int x_pos: 0
    property int y_pos: 0
    property var color_: "darkred"
    property int widht_: 150
    property int height_: 50
    property var text_:"Cancel"
    property var text_color: "white"
    x: x_pos
    y: y_pos
    width: widht_
    height: height_
    color: color_
    Text{
        id: text_button
        color: text_color
        text: text_
        anchors.fill: parent
        font.pixelSize: 20
        font.bold: false
        font.family: "Ubuntu"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}

