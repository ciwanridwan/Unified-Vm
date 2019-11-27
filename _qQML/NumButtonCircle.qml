import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    id: rec
    width:100
    height:100
    radius: width/2
    property var show_text: "9"
    property var rec_color: "white"
    color: rec_color
    Text{
        text:show_text
        color:"black"
        font.family:"Gotham"
        font.pixelSize:30
        anchors.centerIn: rec;
        font.bold: true
    }
    MouseArea {
        anchors.fill: rec
        onClicked: {
            full_numpad.strButtonClick(show_text);
        }
        onEntered:{
            rec.color = "gray";
        }
        onExited:{
            rec.color = rec_color;
        }
    }
}
