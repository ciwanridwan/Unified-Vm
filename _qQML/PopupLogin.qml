import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    id:popup_login
    visible: false
    x:0
    y:0
    width:1280
    height:1024
    color: 'transparent'
    property var escapeFunction: 'closeWindow' //['closeWindow', 'backToMain', 'backToPrevious']
    property bool cancelAble: true
    property var modeLanguage: 'INA'
    property int max_count: 50
    property var press: "0"
    property var textInput: ""
    property string mainTitleIna: "Masukkan Kode Unik Transaksi Anda"
    property string mainTitleEng: "Enter Admin Code"
    property var exitKey: "!@#$%^&*()"
    property var titleImage: "source/icon/password.png"
    property bool clickAble: false


    Rectangle{
        id: base_overlay
        anchors.fill: parent
        color: "gray"
        opacity: 0.6
    }

    Rectangle{
        id: notif_rec
        width: parent.width - 200
        height: parent.height - 200
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: main_text
            color: "darkred"
//            text: (modeLanguage=='INA') ? mainTitleIna : mainTitleEng
            text: mainTitleIna
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.top: parent.top
            anchors.topMargin: 60
            anchors.horizontalCenterOffset: 5
            font.family:"GothamRounded"
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
            anchors.topMargin: 50
            scale: 2
            anchors.left: parent.left
            anchors.leftMargin: 50
            source: titleImage
        }

        TextInput {
            id: inputText
            anchors.centerIn: textRectangle;
            text: textInput
    //        text: "INPUT NUMBER 1234567890SRDCVBUVTY"
            cursorVisible: true
            horizontalAlignment: Text.AlignLeft
            font.family: "GothamRounded"
            font.pixelSize: 40
            color: "darkred"
            clip: true
            visible: true
            focus: true
        }

        NumKeyboard{
            id:virtual_numpad
            anchors.verticalCenterOffset: 100
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
                if (count>=max_count || clickAble == true){
                    str=""
                } else{
                    textInput += str
                }
                check_availability();
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
            ConfirmButton{
                id: cancel_button
                visible: cancelAble
                width: 190
                anchors.left: parent.left
                anchors.leftMargin: 300
                text_: (modeLanguage=='INA') ? 'BATAL' : 'CANCEL'
//                MouseArea{
//                    anchors.fill: parent
//                    onClicked: {
//                        switch(escapeFunction){
//                        case 'backToMain' : my_layer.pop(my_layer.find(function(item){if(item.Stack.index===0)return true}));
//                            break;
//                        case 'backToPrevious' : my_layer.pop();
//                            break;
//                        default: close();
//                            break;
//                        }
//                    }
//                }
            }
            ConfirmButton{
                id: ok_button
                width: 190
                anchors.right: parent.right
                anchors.rightMargin: 300
                text_: (modeLanguage=='INA') ? 'LANJUTKAN' : 'PROCEED'
                color_: (clickAble==true) ? 'green' : 'silver'
            }
        }

    }

    function open(){
        popup_login.visible = true;
    }

    function close(){
        popup_login.visible = false;
    }

    function check_availability(){
        if (textInput==exitKey) {
            clickAble = true;
        }
    }
}
