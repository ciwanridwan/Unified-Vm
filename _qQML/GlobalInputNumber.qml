import QtQuick 2.4
import QtQuick.Controls 1.3
import "base_function.js" as FUNC
import "config.js" as CONF

Base{
    id: global_input_number
    mode_: "reverse"
    isPanelActive: false
    isHeaderActive: true
    isBoxNameActive: false
    textPanel: 'Pilih Produk'
    property int timer_value: 150
    property int max_count: 24
    property int min_count: 10
    property var press: "0"
    property var textInput: ""
    property var mode: undefined
    property var selectedProduct: undefined
    property var wording_text: ''
    property bool checkMode: false
    property bool frameWithButton: false

    property bool cashEnable: false
    property bool cardEnable: false
    property bool qrOvoEnable: false
    property bool qrDanaEnable: false
    property bool qrGopayEnable: false
    property bool qrLinkajaEnable: false
    property var totalPaymentEnable: 0

    property bool isConfirm: false

    signal get_payment_method_signal(string str)
    signal set_confirmation(string str)


    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            console.log('mode', mode);
            abc.counter = timer_value
            my_timer.start()
            define_wording()
            press = '0'

        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
            loading_view.close()
        }
    }

    Component.onCompleted:{
        set_confirmation.connect(set_confirm);
        get_payment_method_signal.connect(process_selected_payment);
        base.result_check_trx.connect(get_trx_check_result);
        base.result_get_device.connect(get_device_status);

    }

    Component.onDestruction:{
        set_confirmation.disconnect(set_confirm);
        get_payment_method_signal.disconnect(process_selected_payment);
        base.result_check_trx.disconnect(get_trx_check_result);
        base.result_get_device.disconnect(get_device_status);

    }

    Rectangle{
        id: rec_timer
        width:10
        height:10
        y:10
        color:"transparent"
        QtObject{
            id:abc
            property int counter
            Component.onCompleted:{
                abc.counter = timer_value
            }
        }

        Timer{
            id:my_timer
            interval:1000
            repeat:true
            running:true
            triggeredOnStart:true
            onTriggered:{
                abc.counter -= 1
                if(abc.counter < 0){
                    my_timer.stop()
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
                }
            }
        }
    }

    CircleButton{
        id:back_button
        anchors.left: parent.left
        anchors.leftMargin: 100
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        button_text: 'BATAL'
        modeReverse: true
        MouseArea{
            anchors.fill: parent
            onClicked: {
                my_layer.pop()
            }
        }
    }


    function set_confirm(_mode){
        console.log('Confirmation Flagged By', _mode)
        global_confirmation_page.close()
        isConfirm = true;
    }


    function get_trx_check_result(r){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
//        console.log('get_trx_check_result', now, r);
        popup_loading.close();
        var res = r.split('|')[1]
        if (['ERROR', 'MISSING_REFF_NO'].indexOf(res) > -1){
            false_notif('Terjadi Kesalahan Saat Memeriksa Nomor Order Anda', 'backToPrevious', res);
            return;
        }
        var data = JSON.parse(res);
        console.log('get_trx_check_result', now, res);
        global_confirmation_frame.label1 = 'label1'
        global_confirmation_frame.data1 = '---'
        global_confirmation_frame.label2 = 'label2'
        global_confirmation_frame.data2 = '---'
        global_confirmation_frame.label3 = 'label3'
        global_confirmation_frame.data3 = '---'
        global_confirmation_frame.label4 = 'label4'
        global_confirmation_frame.data4 = '---'
        global_confirmation_frame.label5 = 'label5'
        global_confirmation_frame.data5 = '---'
        global_confirmation_frame.label6 = 'label6'
        global_confirmation_frame.data6 = '---'
        global_confirmation_frame.label7 = 'label7'
        global_confirmation_frame.data7 = '---'
        global_confirmation_frame.open();

    }


    function define_wording(){
        if (mode=='SEARCH_TRX'){
            wording_text = 'Masukkan Minimal 6 Digit (Dari Belakang) Nomor Transaksi Anda';
            min_count = 6;
            return;
        }
        if (mode=='PPOB' && selectedProduct==undefined){
            false_notif('Pastikan Anda Telah Memilih Product Untuk Transaksi', 'backToPrevious');
            return
        }
        _SLOT.start_get_device_status();
        var category = selectedProduct.category.toLowerCase()
        switch(category){
            case 'listrik': case 'tagihan': case 'tagihan air':
                wording_text = 'Masukkan Nomor Meter/ID Pelanggan Anda';
                checkMode = true;
                min_count = 19;
            break;
            case 'pulsa': case 'paket data': case 'ojek online':
                wording_text = 'Masukkan Nomor Telepon Tujuan';
                min_count = 10;
            break;
            case 'uang elektronik':
                wording_text = 'Masukkan Nomor Kartu Prabayar Anda';
                min_count = 15;
            break;
            default:
                wording_text = 'Masukkan Nomor Pelanggan Anda';
                min_count = 15;
        }
    }

    function false_notif(message, closeMode, textSlave){
        if (closeMode==undefined) closeMode = 'backToMain';
        if (textSlave==undefined) textSlave = '';
        press = '0';
        switch_frame('source/smiley_down.png', message, textSlave, closeMode, false )
        return;
    }

    function switch_frame(imageSource, textMain, textSlave, closeMode, smallerText){
        frameWithButton = false;
        if (closeMode.indexOf('|') > -1){
            closeMode = closeMode.split('|')[0];
            var timer = closeMode.split('|')[1];
            global_frame.timerDuration = parseInt(timer);
        }
        global_frame.imageSource = imageSource;
        global_frame.textMain = textMain;
        global_frame.textSlave = textSlave;
        global_frame.closeMode = closeMode;
        global_frame.smallerSlaveSize = smallerText;
        global_frame.withTimer = true;
        global_frame.open();
    }

    function switch_frame_with_button(imageSource, textMain, textSlave, closeMode, smallerText){
        frameWithButton = true;
        global_frame.imageSource = imageSource;
        global_frame.textMain = textMain;
        global_frame.textSlave = textSlave;
        global_frame.closeMode = closeMode;
        global_frame.smallerSlaveSize = smallerText;
        global_frame.withTimer = false;
        global_frame.open();
    }


    function process_selected_payment(channel){
        var globalDetails = get_cart_details(channel);
        my_layer.push(mandiri_payment_process, {details: globalDetails});
    }

    function get_cart_details(channel){
        var details = {
            payment: channel,
            shop_type: 'ppob',
            time: new Date().toLocaleTimeString(Qt.locale("id_ID"), "hh:mm:ss"),
            date: new Date().toLocaleDateString(Qt.locale("id_ID"), Locale.ShortFormat),
            epoch: new Date().getTime()
        }
        details.qty = '1';
        details.value = selectedProduct.rs_price.toString();
        details.provider = selectedProduct.operator;
        details.admin_fee = '0';
        details.status = selectedProduct.status;
        details.raw = selectedProduct;
        return details;
    }

    function get_device_status(s){
        console.log('get_device_status', s);
        var device = JSON.parse(s);
        if (device.MEI == 'AVAILABLE' || device.GRG == 'AVAILABLE'){
            cashEnable = true;
            totalPaymentEnable += 1;
        }
        if (device.EDC == 'AVAILABLE') {
            cardEnable = true;
            totalPaymentEnable += 1;
        }
        if (device.QR_LINKAJA == 'AVAILABLE') {
            qrLinkajaEnable = true;
            totalPaymentEnable += 1;
        }
        if (device.QR_DANA == 'AVAILABLE') {
            qrDanaEnable = true;
            totalPaymentEnable += 1;
        }
        if (device.QR_GOPAY == 'AVAILABLE') {
            qrGopayEnable = true;
            totalPaymentEnable += 1;
        }
        if (device.QR_OVO == 'AVAILABLE') {
            qrOvoEnable = true;
            totalPaymentEnable += 1;
        }

    }

    //==============================================================
    //PUT MAIN COMPONENT HERE
//    DatePickerNew{
//        id: datepicker
//    }

    MainTitle{
        anchors.top: parent.top
        anchors.topMargin: 200
        anchors.horizontalCenter: parent.horizontalCenter
        show_text: wording_text
        visible: !popup_loading.visible
        size_: 50
        color_: "white"

    }

    TextRectangle{
        id: textRectangle
        width: 650
        height: 110
        color: "white"
        radius: 0
        anchors.top: parent.top
        anchors.topMargin: 325
        border.color: CONF.text_color
        anchors.horizontalCenter: parent.horizontalCenter
    }

    TextInput {
        id: inputText
        height: 60
        anchors.centerIn: textRectangle;
        text: textInput
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
        id:virtual_keyboard
        width:320
        height:420
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 130
        anchors.horizontalCenter: parent.horizontalCenter
        property int count:0

        Component.onCompleted: {
            virtual_keyboard.strButtonClick.connect(typeIn)
            virtual_keyboard.funcButtonClicked.connect(functionIn)
        }

        function functionIn(str){
            if(str == "OK"){
                if(press != "0") return;
                if (max_count+1 > textInput.length > min_count ){
                    var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
                    press = "1"
                    console.log('number input', now, textInput);
                    switch(mode){
                    case 'PPOB':
                        if (checkMode){
                            //TODO Call PPOB Slot Function For Checking
                            console.log('TODO Call PPOB Slot Function For Checking');
                            return;

                        } else {
                            //TODO Create Object, Send View To Confirmation Layer
                            console.log('TODO Create Object, Send View To Confirmation Layer');
                            return;
                        }                        
                    case 'SEARCH_TRX':
                        console.log('Checking Transaction Number : ', textInput);
                        _SLOT.start_check_trx_online(textInput);
                        return
                    default:
                        false_notif('No Handle Set For This Action', 'backToMain');
                        return
                    }
                }
            }
            if(str=="Back"){
                count--;
                textInput=textInput.substring(0,textInput.length-1);
            }
            if(str=="Clear"){
                textInput = "";
                max_count = 24;
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
            } else {
                textInput += str
            }
            abc.counter = timer_value
            my_timer.restart()
        }
    }


    CircleButton{
        id:next_button
        anchors.right: parent.right
        anchors.rightMargin: 100
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        button_text: 'LANJUT'
        modeReverse: true
        MouseArea{
            anchors.fill: parent
            onClicked: {
                console.log('button "LANJUT" is pressed..!')
                if(press != "0") return;
                if (max_count+1 > textInput.length){
                    var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
                    press = "1"
                    console.log('number input', now, textInput);
                    popup_loading.open()
                    switch(mode){
                    case 'PPOB':
                        if (checkMode){
                            //TODO Call PPOB Slot Function For Checking
                            console.log('TODO Call PPOB Slot Function For Checking');
                            return;

                        } else {
                            //TODO Create Object, Send View To Confirmation Layer
                            console.log('TODO Create Object, Send View To Confirmation Layer');
                            return;
                        }
                    case 'SEARCH_TRX':
//                        console.log('Checking Transaction Number : ', textInput);
                        _SLOT.start_check_trx_online(textInput);
                        return
                    case 'WA_INVOICE':
                        // TODO: Add SLOT Function Check WA Payment
                           return
                    default:
                        false_notif('No Handle Set For This Action', 'backToMain');
                        return
                    }
                }
            }
        }
    }


    //==============================================================


    PopupLoading{
        id: popup_loading
    }

    GlobalFrame{
        id: global_frame
    }

    LoadingView{
        id:loading_view
        z: 99
        show_text: "Finding Flight..."
    }


    GlobalConfirmationFrame{
        id: global_confirmation_frame
        calledFrom: 'global_input_number'


    SelectPaymentPopupNotif{
        id: select_payment
        visible: isConfirm
        calledFrom: 'global_input_number'
        _cashEnable: cashEnable
        _cardEnable: cardEnable
        _qrOvoEnable: qrOvoEnable
        _qrDanaEnable: qrDanaEnable
        _qrGopayEnable: qrGopayEnable
        _qrLinkAjaEnable: qrLinkajaEnable
        totalEnable: totalPaymentEnable
    }




}

