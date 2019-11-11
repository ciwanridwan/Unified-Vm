import QtQuick 2.4
import QtQuick.Controls 1.3
import "base_function.js" as FUNC
import "config.js" as CONF

Base{
    id: base_page
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

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
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
        base.result_check_trx.connect(get_trx_check_result);
    }

    Component.onDestruction:{
        base.result_check_trx.disconnect(get_trx_check_result);
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


    function get_trx_check_result(r){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('get_trx_check_result', now, r);
        //TODO Set View For This Result
        popup_loading.close();


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
        var category = selectedProduct.category.toLowerCase()
        switch(category){
            case 'listrik': case 'tagihan': case 'tagihan air':
                wording_text = 'Masukkan Nomor Meter/ID Pelanggan Anda';
                checkMode = true;
                min_count = 19;
            break;
            case 'pulsa': case 'paket data': case 'ojek online':
                wording_text = 'Masukkan Nomor Seluler Tujuan';
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




}

