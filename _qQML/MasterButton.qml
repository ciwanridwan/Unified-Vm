import QtQuick 2.0

Rectangle {
    id: master_rec
    property int x_pos: 0
    property int y_pos: 0
    property var color_: "white"
    property int widht_: 642
    property int height_: 639
    property var img_:""
    property var text_:"TIket Pesawat"
    property var text2_:"Flight Ticket"
    property var text_color: "black"
    x: x_pos
    y: y_pos
    width: widht_
    height: height_
    color: color_
    Image{
        id: image1
        anchors.fill: parent
        scale: 0.4
        source: img_
        fillMode: Image.PreserveAspectFit
        Text{
            id: text_button
            color: text_color
            text: text_
            font.pixelSize: 50
            font.bold: true
                anchors.bottomMargin: -90
                anchors.horizontalCenterOffset: 0
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
            font.family: "Microsoft YaHei"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        Text{
            id: text2_button
            color: text_color
            text: text2_
            font.pixelSize: 35
            font.italic: true
                anchors.bottomMargin: -130
                anchors.horizontalCenterOffset: 0
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
            font.family: "Microsoft YaHei"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }
}

