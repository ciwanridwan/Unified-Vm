import QtQuick 2.4
import QtQuick.Controls 1.3
import QtGraphicalEffects 1.0
import "base_function.js" as FUNC

Base{
    id: prepaid_topup_denom
    property int timer_value: 120
    property var press: '0'
    idx_bg: 1
    property var denomTopup: undefined
    property var provider: undefined
    property bool emoneyAvailable: false
    property bool tapcashAvailable: false
    property var topupData: undefined
    property var adminFee: 1500
    property var mandiriTopupWallet: 0
    property var bniTopupWallet: 0
    property var directTopup: undefined
    property var cardData: undefined
    property int stepMode: 0
    property var totalPrice: 0
    property var globalCart
    property var selectedPayment: undefined
    property var globalDetails
    property var shopType
    property bool cashEnable: false
    property bool debitEnable: false

    property var bniWallet1: 0
    property var bniWallet2: 0


    // By Default Only Can Show 3 Denoms, Adjusted with below properties
    property int miniDenomValue: 10000
    property bool miniDenomActive: true
    // ----------------------------------

    signal topup_denom_signal(string str)
    signal select_payment_signal(string str)
    imgPanel: 'aAsset/topup_kartu.png'
    textPanel: 'Isi Ulang Saldo Kartu Prabayar'


    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            if (topupData==undefined) _SLOT.start_kiosk_get_topup_amount();
            _SLOT.start_get_topup_readiness();
            _SLOT.start_get_device_status();
            _SLOT.start_get_topup_status_instant();
            _SLOT.get_kiosk_price_setting();
            if (cardData==undefined) open_preload_notif();
            abc.counter = timer_value;
            my_timer.start();
            press = '0';
            denomTopup = undefined
            provider = undefined
            globalDetails = undefined
        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
            loading_view.close()
        }
    }

    Component.onCompleted:{
        topup_denom_signal.connect(selected_denom);
        select_payment_signal.connect(set_selected_payment);
        base.result_get_device.connect(get_device_status);
        base.result_balance_qprox.connect(get_balance);
        base.result_topup_readiness.connect(topup_readiness);
        base.result_topup_amount.connect(get_topup_amount);
        base.result_price_setting.connect(define_price);
    }

    Component.onDestruction:{
        topup_denom_signal.disconnect(selected_denom);
        select_payment_signal.disconnect(set_selected_payment);
        base.result_get_device.disconnect(get_device_status);
        base.result_balance_qprox.disconnect(get_balance);
        base.result_topup_readiness.disconnect(topup_readiness);
        base.result_topup_amount.disconnect(get_topup_amount);
        base.result_price_setting.disconnect(define_price);

    }

    function get_device_status(s){
        console.log('get_device_status', s);
        var device = JSON.parse(s);
        if (device.MEI == 'AVAILABLE' || device.GRG == 'AVAILABLE'){
            cashEnable = true;
        }
        if (device.EDC == 'AVAILABLE'){
            debitEnable = true;
        }
    }

    function set_selected_payment(p){
        console.log('set_selected_payment', p);
        selectedPayment = p;
        var details = {
            payment: selectedPayment,
            shop_type: shopType,
            time: new Date().toLocaleTimeString(Qt.locale("id_ID"), "hh:mm:ss"),
            date: new Date().toLocaleDateString(Qt.locale("id_ID"), Locale.ShortFormat),
            epoch: new Date().getTime()
        }
        details.qty = 1;
        details.value = globalCart.value;
        details.provider = globalCart.provider;
        details.admin_fee = adminFee;
        details.raw = globalCart;
        details.status = '1';
        switch(selectedPayment){
            case 'cash':
                var get_denom = parseInt(details.value) - parseInt(adminFee);
                details.denom = get_denom.toString();
                details.final_balance = parseInt(details.denom) + parseInt(cardData.balance);
                _payment_method.labelContent = 'Tunai';
                _nominal.labelContent = 'Rp. ' +  FUNC.insert_dot(get_denom.toString()) + ',-';
                _total_biaya.labelContent = 'Rp. ' +  FUNC.insert_dot(details.value.toString()) + ',-';
                break;
            case 'debit':
                var total_pay = parseInt(details.value) + parseInt(adminFee);
                details.denom = details.value;
                details.final_balance = parseInt(details.denom) + parseInt(cardData.balance);
                _payment_method.labelContent = 'Kartu Debit';
                _total_biaya.labelContent = 'Rp. ' +  FUNC.insert_dot(total_pay.toString()) + ',-';
                break;
        }
        globalDetails = details;
        stepMode = 3;
        press = '0'
    }

    function define_price(p){
        console.log('define_price', p);
        var price = JSON.parse(p);
        adminFee = parseInt(price.adminFee);
        console.log('adminFee', adminFee);
    }

    function topup_readiness(r){
        console.log('topup_readiness', r);
        var ready = JSON.parse(r)
        if (ready.mandiri=='AVAILABLE') emoneyAvailable = true;
        if (ready.bni=='AVAILABLE') tapcashAvailable = true;
        mandiriTopupWallet = parseInt(ready.balance_mandiri);
        bniTopupWallet = parseInt(ready.balance_bni);
        //TODO Show This Wallet Into Proper View
        bniWallet1 = ready.bni_wallet_1;
        bniWallet2 = ready.bni_wallet_2;
        popup_loading.close();
    }

    function init_topup_denom(p){
        console.log('init_topup_denom', p);
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

    function selected_denom(d){
        console.log('selected_denom', d);
        globalCart = JSON.parse(d);
        globalCart.card_no = cardData.card_no;
        globalCart.prev_balance = cardData.balance;
        globalCart.bank_type = cardData.bank_type;
        globalCart.bank_name = cardData.bank_name;
        press = '0';
        if (provider=='TapCash BNI' && parseInt(globalCart.value) > bniTopupWallet){
            false_notif('Mohon Maaf|Silakan Pilih Nilai Denom Lainnya.');
            return;
        }
        if (provider=='e-Money Mandiri' && parseInt(globalCart.value) > mandiriTopupWallet){
            false_notif('Mohon Maaf|Silakan Pilih Nilai Denom Lainnya.');
            return;
        }
        if (cashEnable && debitEnable){
            stepMode = 2;
            _nominal.labelContent = 'Rp. ' +  FUNC.insert_dot(globalCart.value.toString()) + ',-';
        } else if (cashEnable && !debitEnable){
            set_selected_payment('cash');
        } else if (!cashEnable && debitEnable){
            set_selected_payment('debit');
        } else if (!cashEnable && !debitEnable){
            false_notif('Mohon Maaf|Tidak Terdapat Metode Pembayaran Yang Aktif.');
            return;
        }
    }

    function get_topup_amount(r){
        console.log('get_topup_amount', r);
        topupData = JSON.parse(r)
        if (cardData != undefined){
            parse_cardData(cardData);
        } else {
            open_preload_notif();
        }
    }

    function get_balance(text){
        console.log('get_balance', text);
        press = '0';
        standard_notif_view.buttonEnabled = true;
        var result = text.split('|')[1];
        if (result == 'ERROR'){
            back_button.z = 999
            popup_loading.close();
            open_preload_notif('Mohon Maaf|Gagal Mendapatkan Saldo, Pastikan Kartu Prabayar Anda Sudah Ditempelkan Pada Reader', 'ulangi');
            return;
        } else {
            var info = JSON.parse(result);
            var bankName = info.bank_name;
            var ableTopupCode = info.able_topup;
            if (bankName=='BNI'){
                if (ableTopupCode=='0000'){
                    cardData = {
                        balance: info.balance,
                        card_no: info.card_no,
                        bank_type: info.bank_type,
                        bank_name: info.bank_name,
                    }
                    parse_cardData(cardData);
                } else if (ableTopupCode=='1008'){
                    back_button.z = 999
                    popup_loading.close();
                    open_preload_notif('Mohon Maaf|Kartu BNI TapCash Anda Sudah Tidak Aktif\nSilakan Hubungi Bank BNI Terdekat', 'coba lagi');
                } else if (ableTopupCode=='5106'){
                    back_button.z = 999
                    popup_loading.close();
                    open_preload_notif('Mohon Maaf|Kartu BNI TapCash Anda Tidak Resmi\nSilakan Gunakan Kartu TapCash Yang Lain', 'coba lagi');
                } else {
                    back_button.z = 999
                    popup_loading.close();
                    open_preload_notif('Mohon Maaf|Terjadi Kesalahan Pada Kartu BNI TapCash Anda\nSilakan Gunakan Kartu TapCash Yang Lain', 'coba lagi');
                }
            } else {
                back_button.z = 999
                popup_loading.close();
                open_preload_notif('Mohon Maaf|Kartu Prabayar Anda Diterbitkan Oleh Bank Lain ('+bankName+')\nUntuk Sementara Kartu Anda Belum Dapat Digunakan Pada Mesin Ini', 'coba lagi');
            }
        }
    }

    function parse_cardData(o){
        console.log('parse_cardData', JSON.stringify(o));
        var card_no = o.card_no
        var last_balance = o.balance
        var bank_name = o.bank_name
        provider = 'TapCash BNI';
        if (card_no.substring(0, 4) == '6032'){
            bank_name = 'MANDIRI'
            provider = 'e-Money Mandiri';
        } else if (card_no.substring(0, 4) == '7546'){
            bank_name = 'BNI'
            provider = 'TapCash BNI';
        }
        init_topup_denom(bank_name);
        stepMode = 1;
        shopType = 'topup';
        // Assigning Wording Into Text Column
        _shop_type.labelContent = 'Isi Ulang';
        _provider.labelContent = provider;
        _card_no.labelContent = card_no;
        _last_balance.labelContent = 'Rp. ' +  FUNC.insert_dot(last_balance.toString()) + ',-';;
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


    BackButton{
        id:back_button
        anchors.left: parent.left
        anchors.leftMargin: 120
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        z: 10
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

    function open_preload_notif(t, b){
        standard_notif_view.buttonEnabled = false;
        if (t==undefined){
            false_notif('Penumpang YTH|Silakan Tempelkan Kartu Prabayar Anda Pada Reader Sebelum Melanjutkan');
        } else {
            false_notif(t);
        }
        if (b==undefined){
            standard_notif_view._button_text = 'lanjut';
        } else {
            standard_notif_view._button_text = b;
        }
    }

    function false_notif(param){
        press = '0';
        standard_notif_view.z = 100;
        standard_notif_view._button_text = 'tutup';
        if (param==undefined){
            standard_notif_view.show_text = "Mohon Maaf";
            standard_notif_view.show_detail = "Terjadi Kesalahan Pada Sistem, Mohon Coba Lagi Beberapa Saat";
        } else {
            standard_notif_view.show_text = param.split('|')[0];
            standard_notif_view.show_detail = param.split('|')[1];
        }
        standard_notif_view.open();
    }

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


    //==============================================================

    ConfirmView{
        id: confirm_view
        show_text: "Dear Customer"
        show_detail: "Proceed This ?."
        z: 99
        MouseArea{
            id: ok_confirm_view
            x: 668; y:691
            width: 190; height: 50;
            onClicked: {
            }
        }
    }

    NotifView{
        id: notif_view
        isSuccess: false
        show_text: "Dear Customer"
        show_detail: "Please Ensure You have set Your plan correctly."
        z: 99
    }

    LoadingView{
        id:loading_view
        z: 99
        show_text: "Finding Flight..."
    }

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
        visible: (stepMode==2) ? true : false
        withBackground: false
    }

    PopupLoading{
        id: popup_loading
    }





}

