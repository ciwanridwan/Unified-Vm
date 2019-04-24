import QtQuick 2.0

Rectangle{
    color: "transparent"
    property string show_text: "Select Your Schedule"
    property int size_: 30
    property string color_: "darkred"
    height: 50
    width: 932

    Text {
        id: text_notif
        anchors.fill: parent
        text: show_text
        font.pixelSize: size_
        font.family:"Microsoft YaHei"
        color: color_
        textFormat: Text.PlainText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

}


