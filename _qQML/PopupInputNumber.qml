import QtQuick 2.4
import QtQuick.Controls 1.3
import QtGraphicalEffects 1.0
import "base_function.js" as FUNC
import "screen.js" as SCREEN
import "config.js" as CONF


Rectangle{
    id:popup_input_number
    width: parseInt(SCREEN.size.width)
    height: parseInt(SCREEN.size.height)
    color: 'transparent'
    property var escapeFunction: 'closeWindow' //['closeWindow', 'backToMain', 'backToPrevious']
    property int max_count: 15
    property var press: "0"
    property var numberInput: ""
    property string mainTitle: "Masukkan Nomor WhatsApp Anda"
    property var titleImage: "source/whatsapp_transparent_white.png"
    property bool withBackground: true
    property int min_count: 9
    property var pattern: '08'
    property var calledFrom
    property var handleButtonVisibility

    visible: false
    scale: visible ? 1.0 : 0.1
    Behavior on scale {
        NumberAnimation  { duration: 500 ; easing.type: Easing.InOutBounce  }
    }

    Rectangle{
        id: base_overlay
        visible: withBackground
        anchors.fill: parent
        color: CONF.background_color
        opacity: 0.6
    }

    Rectangle{
        id: notif_rec
        width: parent.width
        height: parent.height - 300
        color: CONF.frame_color
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        MainTitle{
            anchors.top: parent.top
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            show_text: mainTitle
            size_: 50
            color_: CONF.text_color
        }

        Text {
            color: CONF.text_color
            text: "*Untuk Pengembalian Pembayaran Anda\nJika Terjadi Kegagalan Transaksi"
            anchors.verticalCenterOffset: 200
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 50
            font.bold: true
            font.italic: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            font.family:"Ubuntu"
            font.pixelSize: 30
        }

        TextRectangle{
            id: textRectangle
            width: 650
            height: 110
            anchors.top: parent.top
            anchors.topMargin: 125
            anchors.horizontalCenter: parent.horizontalCenter
            borderColor: CONF.text_color
        }

        Image{
            width: 150
            height: 150
            anchors.leftMargin: 200
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.6
            scale: 4
            anchors.left: parent.left
            source: titleImage
            fillMode: Image.PreserveAspectFit
        }

        TextInput {
            id: inputText
            anchors.centerIn: textRectangle;
            text: numberInput
    //        text: "INPUT NUMBER 1234567890SRDCVBUVTY"
            cursorVisible: true
            horizontalAlignment: Text.AlignLeft
            font.family: "Ubuntu"
            font.pixelSize: 50
            color: CONF.text_color
            clip: true
            visible: true
            focus: true
        }

        NumKeyboardCircle{
            id:virtual_numpad
            width:320
            height:420
            anchors.verticalCenterOffset: 100
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            visible: true
            property int count:0

            Component.onCompleted: {
                virtual_numpad.strButtonClick.connect(typeIn)
                virtual_numpad.funcButtonClicked.connect(functionIn)
            }

            function functionIn(str){
                if(str == "Back"){
                    count--
                    numberInput = numberInput.substring(0,numberInput.length-1);
                }
                if(str == "Clear"){
                    count = 0;
                    numberInput = "";
                }
            }

            function typeIn(str){
                if (str == "" && count > 0){
                    if(count >= max_count){
                        count = max_count
                    }
                    count--
                    numberInput = numberInput.substring(0,count);
                }
                if (str != "" && count<max_count){
                    count++
                }
                if (count >= max_count){
                    str = ""
                } else {
                    numberInput += str
                }
                check_availability();
            }
        }

    }

    function open(msg){
        if (msg!=undefined) mainTitle = msg;
        popup_input_number.visible = true;
        reset_counter();
    }

    function close(){
        popup_input_number.visible = false;
        reset_counter();
    }

    function reset_counter(){
        numberInput = '';
        max_count = 15;
        virtual_numpad.count = 0;
    }


    function check_availability(){
//        console.log('numberInput', numberInput, canProceed);
        if (numberInput.substring(0, 2)==pattern && numberInput.length > min_count) {
            if (calledFrom!=undefined) {
                switch(calledFrom){
                case 'general_payment_process':
                    general_payment_process.framingSignal('PHONE_INPUT_FRAME|'+numberInput)
                    break;
                }
            }
            if (handleButtonVisibility!=undefined){
                handleButtonVisibility.visible = true;
            }
        }
    }

}
