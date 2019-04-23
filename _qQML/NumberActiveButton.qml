import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    width:159
    height:62
    color: (full_keyboard.isHighlighted==true) ? "black" : "#fff125"
//    radius: 25
    property var chars: "123"

    Text{
        text: chars
        color: (full_keyboard.isHighlighted==true) ? "white" : "red"
        font.family:"Microsoft YaHei"
        font.pixelSize:30
        anchors.centerIn: parent;
//        font.bold: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: full_keyboard.isHighlighted = !full_keyboard.isHighlighted
    }
}
