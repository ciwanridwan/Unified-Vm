import QtQuick 2.4
import QtQuick.Controls 1.3
import QtGraphicalEffects 1.0
import "base_function.js" as FUNC
import "screen.js" as SCREEN
import "config.js" as CONF


Rectangle{
    id:popup_refund
    width: parseInt(SCREEN.size.width)
    height: parseInt(SCREEN.size.height)

//    property var globalScreenType: '1'
//    height: (globalScreenType=='2') ? 1024 : 1080
//    width: (globalScreenType=='2') ? 1280 : 1920

    color: 'transparent'
    property var colorMode: "#293846"
    property bool withBackground: true

    property var calledFrom
    property var handleButtonVisibility
    property var externalSetValue

    property var escapeFunction: 'closeWindow' //['closeWindow', 'backToMain', 'backToPrevious']
    property var press: "0"

    property int minCountInput: 9
    property int maxCountInput: 15
    property var numberInput: ""
    property var pattern: '08'

    property string caseTitle: ""
    property var mainTitleMode: "normal" //normal/center
    property string mainTitle: "Terjadi Kegagalan Transaksi, Masukkan No HP Anda Untuk Pengembalian Dana"
    property var channelSelectedImage: "source/whatsapp_transparent_white.png"
    property var channelDescription: "Pengembalian Dana Pada Akun XXX Anda, Dikenakan Potongan Biaya Rp. 500"

    property int minRefundAmount: 2500
    property var refundAmount: 0

    property bool manualEnable: false
    property bool divaEnable: false
    property bool linkajaEnable: false
    property bool danaEnable: false
    property bool ovoEnable: false
    property bool gopayEnable: false
    property bool shopeepayEnable: false

    property var availableRefund: []

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
//        color: 'black'
        opacity: 0.6
    }

    Rectangle{
        id: notif_rec
        width: parent.width
        height: parent.height
//        color: CONF.frame_color
        color: colorMode
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        MainTitle{
            id: main_title
            width: parent.width - 400
            anchors.top: parent.top
            anchors.topMargin: mainTitleMode=="normal" ? 45 : 375
            anchors.horizontalCenter: parent.horizontalCenter
            show_text: caseTitle + mainTitle
            size_: (popup_refund.width==1920) ? 50 : 35
            color_: CONF.text_color
        }

        Text {
            id: channel_desc
            color: CONF.text_color
            text: channelDescription
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 100
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: true
            font.italic: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family:"Ubuntu"
            font.pixelSize: (popup_refund.width==1920) ? 35 : 25
        }

        TextRectangle{
            id: text_rectangle
            width: 650
            height: 100
            anchors.top: parent.top
            anchors.topMargin: 160
            anchors.horizontalCenter: parent.horizontalCenter
            borderColor: CONF.text_color
            visible: !manualMethod.isSelected
        }

        Image{
            id: channel_image
            width: 150
            height: 150
            anchors.right: parent.right
            anchors.rightMargin: 200
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.6
            scale: 4
            source: channelSelectedImage
            fillMode: Image.PreserveAspectFit
        }

        TextInput {
            id: inputText
            anchors.centerIn: text_rectangle;
            text: numberInput
    //        text: "INPUT NUMBER 1234567890SRDCVBUVTY"
            cursorVisible: true
            horizontalAlignment: Text.AlignLeft
            font.family: "Ubuntu"
            font.pixelSize: (popup_refund.width==1920) ? 50 : 45
            color: CONF.text_color
            clip: true
            visible: !manualMethod.isSelected
            focus: true
        }

        NumKeyboardCircle{
            id:virtual_numpad
            width:320
            height:420
            anchors.verticalCenterOffset: 50
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            //TODO: Assign this into conditional view
            visible: !manualMethod.isSelected
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
                    if(count >= maxCountInput){
                        count = maxCountInput
                    }
                    count--
                    numberInput = numberInput.substring(0,count);
                }
                if (str != "" && count<maxCountInput){
                    count++
                }
                if (count >= maxCountInput){
                    str = ""
                } else {
                    numberInput += str
                }
                check_availability();
            }
        }

    }

    Column{
        id: column_buttons
        spacing: 5
        width: 150
        anchors.left: parent.left
        anchors.leftMargin: -10
        anchors.verticalCenter: parent.verticalCenter

        RefundSelectionButton{
            id: manualMethod
            buttonName: 'OPERATOR'
            imageSource: 'source/manual_logo.jpeg'
            colorMode: 'white'
            channelCode: 'MANUAL'
            visible: manualEnable
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    switch_to_active(manualMethod);
                }
            }
        }

        RefundSelectionButton{
            id: divaMethod
            buttonName: 'WHATSAPP'
            imageSource: 'source/whatsapp_logo.jpeg'
            colorMode: '#64C85A'
            channelCode: 'DIVA'
            visible: divaEnable
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    switch_to_active(divaMethod);
                }
            }
        }

        RefundSelectionButton{
            id: linkajaMethod
            buttonName: 'LINKAJA'
            imageSource: 'source/linkaja_logo.jpeg'
            colorMode: '#D13A34'
            channelCode: 'LINKAJA'
            visible: linkajaEnable && (refundAmount >= minRefundAmount)
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    switch_to_active(linkajaMethod);
                }
            }
        }

        RefundSelectionButton{
            id: danaMethod
            buttonName: 'DANA'
            imageSource: 'source/dana_logo.jpeg'
            colorMode: '#3888DB'
            channelCode: 'DANA'
            visible: danaEnable && (refundAmount >= minRefundAmount)
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    switch_to_active(danaMethod);
                }
            }
        }

        RefundSelectionButton{
            id: ovoMethod
            buttonName: 'O V O'
            imageSource: 'source/ovo_logo.jpeg'
            colorMode: '#45368B'
            channelCode: 'OVO'
            visible: ovoEnable && (refundAmount >= minRefundAmount)
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    switch_to_active(ovoMethod);
                }
            }
        }


        RefundSelectionButton{
            id: gopayMethod
            buttonName: 'GOPAY'
            imageSource: 'source/gopay_logo.png'
            colorMode: '#48A7CC'
            channelCode: 'GOPAY'
            visible: gopayEnable && (refundAmount >= minRefundAmount)
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    switch_to_active(gopayMethod);
                }
            }
        }


        RefundSelectionButton{
            id: shopeeMethod
            buttonName: 'SHOPEE'
            imageSource: 'source/shopee_logo.jpg'
            colorMode: '#D25437'
            channelCode: 'SHOPEEPAY'
            visible: shopeepayEnable && (refundAmount >= minRefundAmount)
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    switch_to_active(shopeeMethod);
                }
            }
        }

    }

    function switch_to_active(id){
        console.log('User Choose "'+ id.channelCode +'" as Refund Channel');
//        _SLOT.user_action_log('Choose "'+ id.channelCode+'" as Refund Channel');
        reset_all_channel();
        id.setActive();
        if (availableRefund.length > 0){
            for (var i=0;i < availableRefund.length;i++){
                if (availableRefund[i].status == '1'){
                    if (availableRefund[i].name == id.channelCode){
                        id.channelFee = availableRefund[i].admin_fee;
                        if (parseInt(availableRefund[i].custom_admin_fee) > 0) id.channelFee = availableRefund[i].custom_admin_fee;
                        channelDescription = availableRefund[i].description;
                        if (availableRefund[i].due_time != "0") channelDescription += ' Waktu Proses ' + availableRefund[i].due_time;
                    }
                }
            }
        }
        console.log('Refund Channel Description : '+ channelDescription);
        channel_image.visible = false;
        externalSetValue = {
            name: id.buttonName,
            code: id.channelCode,
            admin_fee: id.channelFee,
            amount: refundAmount,
            total: refundAmount - parseInt(id.channelFee)
        }
//        colorMode = id.colorMode;
        if (calledFrom!=undefined) {
            switch(calledFrom){
            case 'general_payment_process':
                general_payment_process.framingSignal('SELECT_REFUND|'+JSON.stringify(externalSetValue))
                break;
            }
        }
        switch(id.channelCode){
        case 'MANUAL':
            mainTitle = channelDescription;
            mainTitleMode = 'center';
            channel_desc.visible = false;
            if (handleButtonVisibility!=undefined) handleButtonVisibility.visible = true;
            break;
        default:
            mainTitle = 'Silakan Masukkan Nomor HP/Akun ' + id.buttonName + ' Anda';
            mainTitleMode = 'normal';
//            channelDescription = 'Pengembalian Dana Ke Akun ' + id.channelCode + ', Potongan Biaya Rp. ' + FUNC.insert_dot(id.channelFee.toString());
            if (handleButtonVisibility!=undefined) handleButtonVisibility.visible = false;
            reset_counter();
            break;
        }
//        channelSelectedImage = id.imageSource;
    }

    function reset_all_channel(){
        manualMethod.release();
        divaMethod.release();
        linkajaMethod.release();
        danaMethod.release();
        ovoMethod.release();
        gopayMethod.release();
        shopeeMethod.release();
    }

    function open(msg, amount){
        if (msg!=undefined) caseTitle = msg;
        if (amount!=undefined) refundAmount = parseInt(amount);
        switch_to_active(divaMethod);
        popup_refund.visible = true;
        reset_counter();
    }

    function close(){
        popup_refund.visible = false;
        reset_counter();
    }

    function reset_counter(){
        numberInput = '';
        maxCountInput = 15;
        virtual_numpad.count = 0;
    }


    function check_availability(){
//        console.log('numberInput', numberInput, canProceed);
        if (numberInput.substring(0, 2)==pattern && numberInput.length > minCountInput) {
            if (handleButtonVisibility!=undefined){
                handleButtonVisibility.visible = true;
            }
        }
    }

}
