import QtQuick 2.4
import QtQuick.Controls 1.3
import QtGraphicalEffects 1.0
import "base_function.js" as FUNC

Base{
    id: prepaid_topup_denom
    property int timer_value: 120
    property var press: '0'
    idx_bg: 0
    property var denomTopup: undefined
    property var provider: 'e-Money Mandiri'
    property bool emoneyAvailable: false
    property bool tapcashAvailable: false
    property var topupData: undefined
    property var adminFee: 1500
    property var mandiriTopupWallet: 0
    property var bniTopupWallet: 0
    property var directTopup: undefined
    property var cardData: undefined
    property int stepMode: 0
    property int cardBalance: 0
    property var selectedDenom: 0
    property var globalCart
    property var selectedPayment: undefined
    property var globalDetails
    property var shopType: 'topup'
    property bool cashEnable: false
    property bool cardEnable: false
    property bool qrOvoEnable: false
    property bool qrDanaEnable: false
    property bool qrGopayEnable: false
    property bool qrLinkajaEnable: false
    property bool mainVisible: false
    property var totalPaymentEnable: 0
    property bool isConfirm: false

    property var bniWallet1: 0
    property var bniWallet2: 0

    property int totalPay: 0

    property string cancelText: 'BATAL'
    property string proceedText: 'LANJUT'
    property bool frameWithButton: false

    property var smallDenomTopup: ''
    property var midDenomTopup: ''
    property var highDenomTopup: ''

    // By Default Only Can Show 3 Denoms, Adjusted with below properties
    property int miniDenomValue: 10000
    property bool miniDenomActive: true
    // ----------------------------------
    property int maxBalance: 1000000

    signal topup_denom_signal(string str)
    signal get_payment_method_signal(string str)
    signal set_confirmation(string str)
    imgPanel: 'source/topup_kartu.png'
    textPanel: 'Isi Ulang Saldo Kartu Prabayar'


    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
//            if (topupData==undefined) _SLOT.start_kiosk_get_topup_amount();
//            _SLOT.start_get_topup_status_instant();
            _SLOT.start_get_device_status();
            _SLOT.get_kiosk_price_setting();
            mainVisible = false;
            abc.counter = timer_value;
            my_timer.start();
            press = '0';
            cardBalance = 0;
            totalPay = 0;
            denomTopup = undefined;
            provider = undefined;
            globalDetails = undefined;
            frameWithButton = false;
            isConfirm = false;
            if (cardData==undefined){
                open_preload_notif();
            } else {
                parse_cardData(cardData);
            }
        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop();
//            loading_view.close()
        }
    }

    Component.onCompleted:{
        set_confirmation.connect(do_set_confirm);
        get_payment_method_signal.connect(process_selected_payment);
        topup_denom_signal.connect(set_selected_denom);
        base.result_get_device.connect(get_device_status);
        base.result_balance_qprox.connect(get_balance);
        base.result_topup_readiness.connect(topup_readiness);
        base.result_topup_amount.connect(get_topup_amount);
        base.result_price_setting.connect(define_price);
    }

    Component.onDestruction:{
        set_confirmation.disconnect(do_set_confirm);
        get_payment_method_signal.disconnect(process_selected_payment);
        topup_denom_signal.disconnect(set_selected_denom);
        base.result_get_device.disconnect(get_device_status);
        base.result_balance_qprox.disconnect(get_balance);
        base.result_topup_readiness.disconnect(topup_readiness);
        base.result_topup_amount.disconnect(get_topup_amount);
        base.result_price_setting.disconnect(define_price);

    }

    function get_device_status(s){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('get_device_status', s, now);
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

    function process_selected_payment(method){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('process_selected_payment', now, method);
        selectedPayment = method;
        var details = {
            payment: selectedPayment,
            shop_type: 'topup',
            time: new Date().toLocaleTimeString(Qt.locale("id_ID"), "hh:mm:ss"),
            date: new Date().toLocaleDateString(Qt.locale("id_ID"), Locale.ShortFormat),
            epoch: new Date().getTime()
        }
        globalCart = {
            value: selectedDenom.toString(),
            provider: provider,
            admin_fee: adminFee,
            card_no: cardData.card_no,
            prev_balance: cardData.balance,
            bank_type: cardData.bank_type,
            bank_name: cardData.bank_name,
        }
        var final_balance = parseInt(cardData.balance) + parseInt(selectedDenom)
        details.qty = 1;
        details.value = totalPay.toString();
        details.provider = provider;
        if (details.provider==undefined) details.provider = 'e-Money Mandiri';
        details.admin_fee = adminFee;
        details.raw = globalCart;
        details.status = '1';
        details.final_balance = final_balance.toString();
        details.denom = selectedDenom.toString();
        globalDetails = details;
        my_layer.push(mandiri_payment_process, {details: globalDetails, cardNo: cardData.card_no});
    }

    function define_price(p){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('define_price', p, now);
        var price = JSON.parse(p);
        adminFee = parseInt(price.adminFee);
        console.log('adminFee', adminFee);
    }

    function topup_readiness(r){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('topup_readiness', r, now);
        var ready = JSON.parse(r)
        mandiriTopupWallet = parseInt(ready.balance_mandiri);
        bniTopupWallet = parseInt(ready.balance_bni);
        if (ready.mandiri=='AVAILABLE') {
            if (mandiriTopupWallet > 0) {
                emoneyAvailable = true;
                if (mandiriTopupWallet > parseInt(smallDenomTopup)) {
                    small_denom.buttonActive = true;
                } else {
                    small_denom.buttonActive = false;
                }
                if (mandiriTopupWallet > parseInt(midDenomTopup)) {
                    mid_denom.buttonActive = true;
                } else {
                    mid_denom.buttonActive = false;
                }
                if (mandiriTopupWallet > parseInt(highDenomTopup)) {
                    high_denom.buttonActive = true;
                } else {
                    high_denom.buttonActive = false;
                }
            }
        }
        if (ready.mandiri=='TEST_MODE') {
            smallDenomTopup = '2';
            midDenomTopup = '4';
            highDenomTopup = '9';
            adminFee = 1;
            if (mandiriTopupWallet > 0) {
                emoneyAvailable = true;
                if (mandiriTopupWallet > parseInt(smallDenomTopup)) {
                    small_denom.buttonActive = true;
                } else {
                    small_denom.buttonActive = false;
                }
                if (mandiriTopupWallet > parseInt(midDenomTopup)) {
                    mid_denom.buttonActive = true;
                } else {
                    mid_denom.buttonActive = false;
                }
                if (mandiriTopupWallet > parseInt(highDenomTopup)) {
                    high_denom.buttonActive = true;
                } else {
                    high_denom.buttonActive = false;
                }
            }
        }
        if (ready.bni=='AVAILABLE') {
            if (bniTopupWallet > 0) tapcashAvailable = true;
        }
        switch(cardData.bank_name){
        case 'MANDIRI':
            highDenomTopup = ready.emoney[0]
            midDenomTopup = ready.emoney[1]
            smallDenomTopup = ready.emoney[2]
            break;
        case 'BNI':
            highDenomTopup = ready.tapcash[0]
            midDenomTopup = ready.tapcash[1]
            smallDenomTopup = ready.tapcash[2]
            break;
        case 'DKI':
            highDenomTopup = ready.jakcard[0]
            midDenomTopup = ready.jakcard[1]
            smallDenomTopup = ready.jakcard[2]
            break;
        case 'BCA':
            highDenomTopup = ready.flazz[0]
            midDenomTopup = ready.flazz[1]
            smallDenomTopup = ready.flazz[2]
            break;
        case 'BRI':
            highDenomTopup = ready.brizzi[0]
            midDenomTopup = ready.brizzi[1]
            smallDenomTopup = ready.brizzi[2]
            break;
        }
//        bniWallet1 = ready.bni_wallet_1;
//        bniWallet2 = ready.bni_wallet_2;

        if (!check_denom_topup()){
            false_notif();
            return;
        }
        popup_loading.close();
    }


    function check_denom_topup(){
        if (FUNC.empty(highDenomTopup) && FUNC.empty(midDenomTopup) && FUNC.empty(smallDenomTopup)){
            return false;
        }
        return true;

    }

    function init_topup_denom(p){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('init_topup_denom', p, now);
        //[{'name': 'MANDIRI', 'smallDenom': 50, 'bigDenom': 100, 'tinyDenom': 25}, {'name': 'BNI', 'smallDenom': 50, 'bigDenom': 100}]
        for (var i=0; i < topupData.length; i++){
            if (topupData[i].name==p){
                select_denom.bigDenomAmount = topupData[i].bigDenom;
                select_denom.smallDenomAmount = topupData[i].smallDenom;
                var tinyDenom = 0;
                if (topupData[i].tinyDenom != undefined) tinyDenom = topupData[i].tinyDenom;
                select_denom.tinyDenomAmount = tinyDenom;
            }
        }
    }

    function set_selected_denom(d){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('set_selected_denom', d, now);
        selectedDenom = d;
        totalPay = parseInt(selectedDenom) + parseInt(adminFee);
        var rows = [
            {label: 'Tanggal', content: now},
            {label: 'Produk', content: 'Isi Ulang Prabayar'},
            {label: 'Provider', content: provider},
            {label: 'Nilai Topup', content: FUNC.insert_dot(selectedDenom.toString())},
            {label: 'Biaya Admin', content: FUNC.insert_dot(adminFee.toString())},
            {label: 'Total', content: FUNC.insert_dot(totalPay.toString())},
        ]
        generateConfirm(rows, true);
    }

    function get_topup_amount(r){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('get_topup_amount', r, now);
        topupData = JSON.parse(r)
        if (cardData != undefined){
            parse_cardData(cardData);
        } else {
            open_preload_notif();
        }
    }

    function get_balance(text){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('get_balance', text, now);
        press = '0';
//        standard_notif_view.buttonEnabled = true;
        popup_loading.close();
        var result = text.split('|')[1];
        if (result == 'ERROR'){
            back_button.z = 999
            switch_frame('source/insert_card_new.png', 'Anda tidak meletakkan kartu', 'ataupun kartu Anda tidak dapat digunakan', 'closeWindow', false );
            return;
        } else {
            var info = JSON.parse(result);
            var bankName = info.bank_name;
            var ableTopupCode = info.able_topup;
            cardBalance = parseInt(info.balance);
            if (['MANDIRI', 'BNI'].indexOf(bankName) > -1){
                cardData = {
                    balance: info.balance,
                    card_no: info.card_no,
                    bank_type: info.bank_type,
                    bank_name: info.bank_name,
                }
                parse_cardData(cardData);
//                if (ableTopupCode=='0000'){
////                } else if (ableTopupCode=='1008'){
////                    back_button.z = 999
////                    open_preload_notif('Mohon Maaf|Kartu BNI TapCash Anda Sudah Tidak Aktif\nSilakan Hubungi Bank BNI Terdekat', 'coba lagi');
////                } else if (ableTopupCode=='5106'){
////                    back_button.z = 999
////                    open_preload_notif('Mohon Maaf|Kartu BNI TapCash Anda Tidak Resmi\nSilakan Gunakan Kartu TapCash Yang Lain', 'coba lagi');
//                } else {
////                    back_button.z = 999
//                    switch_frame('source/insert_card_new.png', 'Maaf terjadi kesalahan pada kartu Anda', 'gunakan kartu lainnya', 'closeWindow', false );
//                    return;
//                }
            } else {
//                back_button.z = 999
                switch_frame('source/insert_card_new.png', 'Anda tidak meletakkan kartu', 'ataupun kartu Anda tidak dapat digunakan', 'closeWindow', false );
                return;
            }
        }
        _SLOT.start_get_topup_readiness();
    }

    function parse_cardData(o){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('parse_cardData', now, JSON.stringify(o));
        var card_no = o.card_no;
        var last_balance = o.balance;
        var bank_name = o.bank_name;
        cardBalance = parseInt(last_balance);
        press = '0';
        shopType = 'topup';
        //TODO Reset Provider To Default Item
        if (bank_name=='MANDIRI') provider = 'e-Money Mandiri';
        if (bank_name=='BNI') provider = 'Tapcash BNI';
        mainVisible = true;
//        init_topup_denom(bank_name);
//        stepMode = 1;
        // Assigning Wording Into Text Column
//        _shop_type.labelContent = 'Isi Ulang';
//        _provider.labelContent = provider;
//        _card_no.labelContent = card_no;
//        _last_balance.labelContent = 'Rp. ' +  FUNC.insert_dot(last_balance.toString()) + ',-';;
        _SLOT.start_get_topup_readiness();
        popup_loading.close();
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
            repeat:true
            interval:1000
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
        anchors.leftMargin: 50
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        button_text: 'BATAL'
        visible: !popup_loading.visible
        modeReverse: true

        MouseArea{
            anchors.fill: parent
            onClicked: {
                _SLOT.user_action_log('Press Back Button "TopUp Denom"');
                my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
            }
        }
    }

    //==============================================================
    //PUT MAIN COMPONENT HERE

    function do_set_confirm(_mode){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('Confirmation Flagged By', _mode, now)
        global_confirmation_frame.no_button();
        popup_loading.close();
        press = '0';
        isConfirm = true;
    }

    function open_preload_notif(){
        preload_check_card.open();
    }

    function false_notif(closeMode, textSlave){
        if (closeMode==undefined) closeMode = 'backToMain';
        if (textSlave==undefined) textSlave = '';
        press = '0';
        switch_frame('source/smiley_down.png', 'Maaf Sementara Mesin Tidak Dapat Digunakan', textSlave, closeMode, false )
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

    function exceed_balance(denom){
        if ((parseInt(cardData.balance) + parseInt(denom)) > maxBalance){
            press = '0';
            switch_frame('source/smiley_down.png', 'Mohon Maaf Saldo Akan Melebihi Limit', 'Silakan Pilih Denom Yang Lebih Kecil', 'closeWindow', false )
            return true;
        } else {
            return false;
        }
    }

    function generateConfirm(rows, confirmation, closeMode, timer){
        if (rows==undefined || rows.length == 0) return;
        if (confirmation==undefined) confirmation = false;
        if (closeMode==undefined) closeMode = 'closeWindow';
        if (timer!==undefined){
            global_confirmation_frame.withTimer = true;
            global_confirmation_frame.timerDuration = parseInt(timer);
        }
        global_confirmation_frame.modeConfirm = confirmation;
        global_confirmation_frame.closeMode = closeMode;
        for (var i=0;i<rows.length;i++){
            if (i==0){
                global_confirmation_frame.label1 = rows[i].label;
                global_confirmation_frame.data1 = rows[i].content;
            }
            if (i==1){
                global_confirmation_frame.label2 = rows[i].label;
                global_confirmation_frame.data2 = rows[i].content;
            }
            if (i==2){
                global_confirmation_frame.label3 = rows[i].label;
                global_confirmation_frame.data3 = rows[i].content;
            }
            if (i==3){
                global_confirmation_frame.label4 = rows[i].label;
                global_confirmation_frame.data4 = rows[i].content;
            }
            if (i==4){
                global_confirmation_frame.label5 = rows[i].label;
                global_confirmation_frame.data5 = rows[i].content;
            }
            if (i==5){
                global_confirmation_frame.label6 = rows[i].label;
                global_confirmation_frame.data6 = rows[i].content;
            }
            if (i==6){
                global_confirmation_frame.label7 = rows[i].label;
                global_confirmation_frame.data7 = rows[i].content;
            }
        }
        press = '0';
        global_confirmation_frame.open();
    }

    /*

    Rectangle{
        id: main_base
        color: '#1D294D'
        radius: 50
        border.width: 0
        anchors.verticalCenterOffset: 50
        anchors.horizontalCenterOffset: 150
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: .97
        width: 1100
        height: 900
        visible: !standard_notif_view.visible && !popup_loading.visible


    }

    Text {
        id: main_title
        height: 100
        anchors.top: parent.top
        anchors.topMargin: 150
        anchors.horizontalCenterOffset: 150
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: "white"
        wrapMode: Text.WordWrap
        text: "Konfirmasi Isi Ulang";
        font.bold: false
        font.family: "Ubuntu"
        font.pixelSize: 45
        visible: !standard_notif_view.visible && !popup_loading.visible
    }

    Column{
        id: col_summary
        width: 800
        anchors.horizontalCenterOffset: 150
        anchors.top: parent.top
        anchors.topMargin: 250
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 25
        TextDetailRow{
            id: _shop_type
            labelName: qsTr('Tipe Pembelian')
            visible: (stepMode>0) ? true : false;
            contentSize: 30
            labelSize: 30
            theme: 'white'
        }
        TextDetailRow{
            id: _provider
            labelName: qsTr('Tipe Kartu')
            visible: (stepMode>0) ? true : false;
            contentSize: 30
            labelSize: 30
            theme: 'white'
        }
        TextDetailRow{
            id: _card_no
            labelName: qsTr('Nomor Kartu')
            visible: (stepMode>0) ? true : false;
            contentSize: 30
            labelSize: 30
            theme: 'white'
        }
        TextDetailRow{
            id: _last_balance
            labelName: qsTr('Sisa Saldo')
            visible: (stepMode>0) ? true : false;
            contentSize: 30
            labelSize: 30
            theme: 'white'
        }
        TextDetailRow{
            id: _nominal
            labelName: qsTr('Nominal')
            visible: (stepMode>1) ? true : false;
            contentSize: 30
            labelSize: 30
            theme: 'white'
        }
//        TextDetailRow{
//            id: _jumlahUnit
//            labelName: qsTr('Jumlah Unit')
//            visible: (stepMode>1) ? true : false;
//            labelContent: '1'
//            contentSize: 30
//            labelSize: 30
//            theme: 'white'
//        }
        TextDetailRow{
            id: _payment_method
            labelName: qsTr('Pembayaran')
            visible: (stepMode>2) ? true : false;
            contentSize: 30
            labelSize: 30
            theme: 'white'
        }
        TextDetailRow{
            id: _biaya_admin
            visible: (stepMode>2) ? true : false;
            labelName: qsTr('Biaya Admin')
            labelContent: 'Rp. ' +  FUNC.insert_dot(adminFee.toString()) + ',-';
            contentSize: 30
            labelSize: 30
            theme: 'white'
        }
        TextDetailRow{
            id: _total_biaya
            labelName: qsTr('Total')
            visible: (stepMode>2) ? true : false;
            contentSize: 30
            labelSize: 30
            theme: 'white'
        }

    }

    NextButton{
        id: change_details
        x: 770
        y: 865
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 150
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        visible: (stepMode==3) ? true : false
        button_text: 'ubah'
        modeReverse: true
        MouseArea{
            anchors.fill: parent
            onClicked: {
                _SLOT.user_action_log('Press "Ubah"');
                stepMode = 1;
                press = '0';
            }
        }
    }

    NextButton{
        id: confirm_button
        x: 1039
        y: 891
        visible: (stepMode==3) ? true : false
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 150
        anchors.horizontalCenterOffset: 300
        anchors.horizontalCenter: parent.horizontalCenter
        button_text: 'konfirmasi'
        modeReverse: true
        MouseArea{
            anchors.fill: parent
            onClicked: {
                _SLOT.user_action_log('Press "Konfirmasi"');
                console.log('Confirm Button is Pressed..!');
                   if (press!='0') return;
                   press = '1';
                   my_layer.push(process_shop, {details: globalDetails})
            }
        }
    }

    Text {
        id: small_notif
        x: 0
        color: "white"
        visible: !standard_notif_view.visible && !popup_loading.visible
        text: "*Pastikan Kartu Prabayar Anda masih Ditempelkan di Reader Hingga Proses Isi Ulang Selesai."
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 150
        wrapMode: Text.WordWrap
        font.italic: true
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"Ubuntu"
        font.pixelSize: 20
    }

    Text {
        id: balance_notif
        x: 0
        color: "white"
        visible: false
        text: "Saldo Tersedia 1 Rp."+FUNC.insert_dot(bniWallet1.toString())+",- & 2 Rp."+FUNC.insert_dot(bniWallet2.toString())+",-"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 150
        wrapMode: Text.WordWrap
        font.italic: true
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"Ubuntu"
        font.pixelSize: 15
    }

    */

    MainTitle{
        anchors.top: parent.top
        anchors.topMargin: 200
        anchors.horizontalCenter: parent.horizontalCenter
        show_text: 'Pilih nominal topup'
        size_: 50
        color_: "white"
        visible: mainVisible
    }

    Text {
        id: label_current_balance
        color: "white"
        text: "Saldo Anda sekarang"
        anchors.top: parent.top
        anchors.topMargin: 325
        anchors.left: parent.left
        anchors.leftMargin: 350
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"Ubuntu"
        font.pixelSize: 50
        visible: mainVisible
    }

    Text {
        id: content_current_balance
        color: "white"
        text: (cardBalance==0) ? 'Rp 0' : 'Rp ' + FUNC.insert_dot(cardBalance.toString())
        anchors.right: parent.right
        anchors.rightMargin: 350
        anchors.top: parent.top
        anchors.topMargin: 325
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.family:"Ubuntu"
        font.pixelSize: 50
        visible: mainVisible
    }

    Column{
        id: denom_button
        width: 1220
        height: 500
        anchors.top: parent.top
        anchors.topMargin: 450
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 60
        visible: mainVisible
        MandiriDenomButton{
            id: small_denom
            width: parent.width
            button_text: 'Rp ' + FUNC.insert_dot(smallDenomTopup)
            buttonActive: false
            MouseArea{
                anchors.fill: parent
                enabled: parent.buttonActive
                onClicked: {
                    if (exceed_balance(smallDenomTopup)) return
                    _SLOT.user_action_log('Press smallDenom "'+smallDenomTopup+'"');
                    if (press!='0') return;
                    press = '1';
                    set_selected_denom(smallDenomTopup);
                }
            }
        }
        MandiriDenomButton{
            id: mid_denom
            width: parent.width
            button_text: 'Rp ' + FUNC.insert_dot(midDenomTopup)
            buttonActive: false
            MouseArea{
                anchors.fill: parent
                enabled: parent.buttonActive
                onClicked: {
                    if (exceed_balance(midDenomTopup)) return
                    _SLOT.user_action_log('Press midDenom "'+midDenomTopup+'"');
                    if (press!='0') return;
                    press = '1';
                    set_selected_denom(midDenomTopup);
                }
            }
        }
        MandiriDenomButton{
            id: high_denom
            width: parent.width
            button_text: 'Rp ' + FUNC.insert_dot(highDenomTopup)
            buttonActive: false
            MouseArea{
                anchors.fill: parent
                enabled: parent.buttonActive
                onClicked: {
                    if (exceed_balance(highDenomTopup)) return
                    _SLOT.user_action_log('Press highDenom "'+highDenomTopup+'"');
                    if (press!='0') return;
                    press = '1';
                    set_selected_denom(highDenomTopup);
                }
            }
        }
    }


    //==============================================================


    StandardNotifView{
        id: standard_notif_view
//        withBackground: false
        modeReverse: true
        show_text: "Dear Customer"
        show_detail: "Please Ensure You have set Your plan correctly."
        z: 99
        MouseArea{
            enabled: !parent.buttonEnabled
            width: 180
            height: 90
            anchors.horizontalCenterOffset: 150
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 295
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                _SLOT.user_action_log('Press Notif Button "Check Balance"');
                console.log('alternative button is pressed..!')
                popup_loading.open();
                _SLOT.start_check_balance();
                parent.visible = false;
                parent.buttonEnabled = true;
            }
        }
    }

    SelectDenomTopupNotif{
        id: select_denom
        visible: (stepMode==1) ? true : false
        _provider: provider
        bigDenomAmount: 100
        smallDenomAmount: 50
        _adminFee: adminFee
        tinyDenomAmount: 0
        miniDenomAmount: (miniDenomActive) ? miniDenomValue : 0
        withBackground: false
    }

    SelectPaymentPopupNotif{
        id: select_payment
        visible: isConfirm
        calledFrom: 'prepaid_topup_denom'
        _cashEnable: cashEnable
        _cardEnable: cardEnable
        _qrOvoEnable: qrOvoEnable
        _qrDanaEnable: qrDanaEnable
        _qrGopayEnable: qrGopayEnable
        _qrLinkAjaEnable: qrLinkajaEnable
        totalEnable: totalPaymentEnable
        z: 99
    }

    PopupLoading{
        id: popup_loading
    }

    GlobalFrame{
        id: global_frame
        CircleButton{
            id: cancel_button_global
            anchors.left: parent.left
            anchors.leftMargin: 100
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            button_text: cancelText
            modeReverse: true
            visible: frameWithButton
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press "BATAL"');
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }));
                }
            }
        }

        CircleButton{
            id: next_button_global
            anchors.right: parent.right
            anchors.rightMargin: 100
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            button_text: proceedText
            modeReverse: true
            visible: frameWithButton
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press "LANJUT"');
                    if (press!='0') return;
                    press = '1'
                    switch(modeButtonPopup){
                    case 'retrigger_grg':
                        _SLOT.start_grg_receive_note();
                        break;
                    case 'do_topup':
                        perform_do_topup();
                        break;
                    case 'reprint':
                        _SLOT.start_reprint_global();
                        break;
                    case 'check_balance':
                        _SLOT.start_check_balance();
                        break;
                    }
                    popup_loading.open();
                }
            }
        }
    }

    PreloadCheckCard{
        id: preload_check_card
        CircleButton{
            id: cancel_button_preload
            anchors.left: parent.left
            anchors.leftMargin: 100
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            button_text: 'BATAL'
            modeReverse: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press "BATAL"');
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }));
                }
            }
        }

        CircleButton{
            id: next_button_preload
            anchors.right: parent.right
            anchors.rightMargin: 100
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            button_text: 'LANJUT'
            modeReverse: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press "LANJUT"');
                    preload_check_card.close();
                    if (press!='0') return;
                    press = '1'
                    popup_loading.open();
                    _SLOT.start_check_balance();
                }
            }
        }
    }

    GlobalConfirmationFrame{
        id: global_confirmation_frame
        calledFrom: 'prepaid_topup_denom'

    }




}

