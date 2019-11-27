import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    width:75
    height:62
    property var chars: ""
    property bool isNumber: false
    property bool isHighlighted: false
    property bool isEnabled: true
    property color col: (isEnabled==true) ? "white" : 'silver'
    color: col
    radius: 10
//    color: (isHighlighted==true&&isNumber==true) ? "gray" : "white"

    Text{
        id: text_button
        text:chars
        color:"black"
        font.family:"Gotham"
        font.pixelSize:30
        anchors.centerIn: parent
        font.bold: isHighlighted
    }

    MouseArea {
        enabled: isEnabled
        anchors.fill: parent
        onClicked: {
//            console.log(isNumber, isHighlighted)
            if(isNumber==true || (isNumber!=true&&isHighlighted!=true)){
                full_keyboard.strButtonClick(chars)
            }
        }
//        onEntered: {
//            parent.color = "gray"
//        }
//        onExited: {
////            parent.color = (isHighlighted==true&&isNumber==true) ? "gray" : "white"
//            parent.color = col
//        }
    }
}


