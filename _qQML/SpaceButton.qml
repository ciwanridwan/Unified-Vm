import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    width: 509
    height: 69
    color: "white"
    radius: 10
    property var chars
    property bool isEnabled: true
    Text{
        id: text_button
        text:chars
        color:"black"
        font.family:"GothamRounded"
        font.pixelSize: 30
        anchors.centerIn: parent
    }
    MouseArea {
        anchors.fill: parent
        enabled: isEnabled
        onClicked: {
            full_keyboard.strButtonClick(" ")
        }
        onEntered: {
            parent.color = "black"
            text_button.color = "white"
        }
        onExited: {
            parent.color = "white"
            text_button.color = "black"
        }
    }
}


