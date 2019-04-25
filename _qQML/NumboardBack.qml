import QtQuick 2.4
import QtQuick.Controls 1.3

Rectangle{
    id: rec
    width:88
    height:88
    color:"#ffc125"
    radius: 15
    property var slot_text:""
    Image{
        scale: 0.7
        source: "aAsset/back_space.png";
        anchors.fill: rec;
        fillMode: Image.PreserveAspectFit;
    }
//    Text{
//        text:slot_text
//        color:"red"
//        font.family:"Ubuntu"
//        font.pixelSize:20
//        anchors.centerIn: parent;
//        font.bold: true
//    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            full_numpad.funcButtonClicked(slot_text)
        }
    }
}
