import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    id:popup_update_stock
    visible: false
    x:0
    y:0
    width:1920
    height:1080
    color: 'transparent'
    property int max_count: 50
    property var press: "0"
    property var textInput: ""
    property var titleImage: "aAsset/plus_circle.png"
    property var selectedSlot: '1'

    scale: visible ? 1.0 : 0.1
    Behavior on scale {
        NumberAnimation  { duration: 500 ; easing.type: Easing.InOutBounce  }
    }

    Rectangle{
        id: notif_rec
        width: 1000
        height: 800
        color: "white"
        anchors.verticalCenterOffset: 50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: main_text
            color: "darkred"
            text: 'Masukkan Update Stock Slot ' + selectedSlot
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.top: parent.top
            anchors.topMargin: 60
            anchors.horizontalCenterOffset: 5
            font.family:"Ubuntu"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 40
        }

        TextRectangle{
            id: textRectangle
            width: 700
            height: 80
            anchors.top: parent.top
            anchors.topMargin: 180
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Image{
            id: imageBody
            anchors.top: parent.top
            anchors.topMargin: 20
            scale: 0.7
            anchors.left: parent.left
            anchors.leftMargin: 20
            source: titleImage
        }

        TextInput {
            id: inputText
            anchors.centerIn: textRectangle;
            text: textInput
    //        text: "INPUT NUMBER 1234567890SRDCVBUVTY"
            cursorVisible: true
            horizontalAlignment: Text.AlignLeft
            font.family: "Ubuntu"
            font.pixelSize: 40
            color: "darkred"
            clip: true
            visible: true
            focus: true
        }

        NumKeyboard{
            id:virtual_numpad
            anchors.verticalCenterOffset: 60
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            property int count:0

            Component.onCompleted: {
                virtual_numpad.strButtonClick.connect(typeIn)
                virtual_numpad.funcButtonClicked.connect(functionIn)
            }

            function functionIn(str){
                if(str == "OK"){
                    if(press != "0"){
                        return
                    }
                    press = "1"
                }
                if(str=="Back"){
                    count--
                    textInput=textInput.substring(0,textInput.length-1);
                }
                if(str=="Clear"){
                    count = 0;
                    textInput = "";
                }
            }

            function typeIn(str){
                if (str == "" && count > 0){
                    if(count>=max_count){
                        count=max_count
                    }
                    count--
                    textInput=textInput.substring(0,count);
                }
                if (str!=""&&count<max_count){
                    count++
                }
                if (count>=max_count){
                    str=""
                } else{
                    textInput += str
                }
            }
        }

        GroupBox{
            id: groupBox1
            flat: true
            x: 200
            y: 472
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            NextButton{
                id: cancel_button
                width: 190
                anchors.left: parent.left
                anchors.leftMargin: 250
                button_text: 'batal'
                MouseArea{
                    anchors.fill: parent
                    onClicked: close();
                }
            }
            NextButton{
                id: update_button
                width: 190
                anchors.right: parent.right
                anchors.rightMargin: 250
                button_text: 'update'
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        if (textInput!='' && parseInt(textInput) > 0){
                            var _signal = JSON.stringify({
                                                             port: selectedSlot,
                                                             stock: textInput,
                                                             type: 'changeStock'
                                                         });
                            admin_page.update_product_stock(_signal);
                            close();
                        }
                    }
                }
            }

        }

    }

    function open(){
        popup_update_stock.visible = true;
    }

    function close(){
        popup_update_stock.visible = false;
    }

}
