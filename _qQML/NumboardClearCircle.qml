import QtQuick 2.4
import QtQuick.Controls 1.3

Rectangle{
    width:100
    height:100
    color:"#ffc125"
    radius: width/2
    property var slot_text:""
    Text{
        text:slot_text
        color:"#ffffff"
        font.family:"Gotham"
        font.pixelSize:20
        anchors.centerIn: parent;
        font.bold: true
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            full_numpad.funcButtonClicked(slot_text)
        }
    }
}
