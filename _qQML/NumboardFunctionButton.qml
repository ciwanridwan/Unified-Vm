import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    width:88
    height:88
    color:"transparent"
    property var slot_text:""
    property var show_image:""

    Image{
        id:num_function_button
        width:88
        height:88
        source:"img/button/NumKeyButton_1.png"
    }
    Image{
        x:0
        y:0
        width:88
        height:88
        source:show_image
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if(slot_text != "delete"){
                full_keyboard.function_button_clicked(slot_text)
            }
            else
                full_keyboard.letter_button_clicked("")
        }
        onEntered:{
            num_function_button.source = "img/bottondown/numbuttondown.png"
        }
        onExited:{
            num_function_button.source = "img/button/NumKeyButton_1.png"
        }
    }
}
