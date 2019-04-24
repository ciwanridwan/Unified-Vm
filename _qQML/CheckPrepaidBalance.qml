import QtQuick 2.4
import QtQuick.Controls 1.3
import QtGraphicalEffects 1.0
import "base_function.js" as FUNC

Base{
    id: base_page
    property int timer_value: 300
    property var press: '0'
    property var cardNo: undefined
    property var balance: '0'
    property var topupData: undefined
    property var bankType: undefined
    property var bankName: undefined
    property var ableTopupCode: undefined
    property var imageSource: undefined
    property bool mandiriLogin: false
    imgPanel: 'aAsset/cek_saldo.png'
    textPanel: 'Cek Saldo Kartu Prabayar'

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            abc.counter = timer_value;
            my_timer.start();
            open_preload_notif();
            press = '0';
            cardNo = undefined;
            balance = 0;
            bankType = undefined;
            bankName = undefined;
            imageSource = undefined;
            ableTopupCode = undefined;
            notif_saldo.text = 'Saldo Kartu Prabayar Anda\nRp. 0, -'

        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
            loading_view.close()
        }
    }

    Component.onCompleted:{
        base.result_balance_qprox.connect(get_balance);
        base.result_topup_readiness.connect(topup_readiness);
        base.result_topup_amount.connect(get_topup_amount);
    }

    Component.onDestruction:{
        base.result_balance_qprox.disconnect(get_balance);
        base.result_topup_readiness.disconnect(topup_readiness);
        base.result_topup_amount.disconnect(get_topup_amount);
    }

    function get_topup_amount(r){
        console.log('get_topup_amount', r);
        topupData = JSON.parse(r);
    }

    function topup_readiness(r){
        console.log('topup_readiness', r);
        popup_loading.close();
        var ready = JSON.parse(r)
    }

    function get_balance(text){
        console.log('get_balance', text);
        press = '0';
        popup_loading.close();
        standard_notif_view.buttonEnabled = true;
        var result = text.split('|')[1];
        if (result == 'ERROR'){
            false_notif('Mohon Maaf|Gagal Mendapatkan Saldo, Pastikan Kartu Prabayar Anda Sudah Ditempelkan Pada Reader');
            cardNo = undefined;
            balance = 0;
            bankType = undefined;
            image_prepaid_card.source = "aAsset/card_tj_original.png";
            imageSource = "aAsset/card_tj_original.png";
            notif_saldo.text = "Saldo Kartu Prabayar Anda\nRp. 0, -";
            return;
        } else {
            var info = JSON.parse(result);
            balance = info.balance.toString();
            cardNo = info.card_no;
            bankType = info.bank_type;
            bankName = info.bank_name;
            ableTopupCode = info.able_topup;
            card_no_prepaid.text = FUNC.insert_space_four(cardNo);
            if (bankName == 'MANDIRI'){
                image_prepaid_card.source = "aAsset/mandiri_emoney_card.png";
                imageSource = "aAsset/mandiri_emoney_card.png";
                notif_saldo.text = "Saldo Kartu Prabayar e-Money Anda\nRp. " + FUNC.insert_dot(balance) + ",-";
            } else if (bankName == 'BNI'){
                image_prepaid_card.source = "aAsset/bni_tapcash_card.png";
                imageSource = "aAsset/bni_tapcash_card.png";
                notif_saldo.text = "Saldo Kartu Prabayar TapCash Anda\nRp. " + FUNC.insert_dot(balance) + ",-";
            } else if (bankName == 'BCA'){
                image_prepaid_card.source = "aAsset/bca_flazz_card.png";
                imageSource = "aAsset/bca_flazz_card.png";
                notif_saldo.text = "Saldo Kartu Prabayar Flazz Anda\nRp. " + FUNC.insert_dot(balance) + ",-";
            }else {
                image_prepaid_card.source = "aAsset/card_tj_original.png";
                imageSource = "aAsset/card_tj_original.png";
                notif_saldo.text = "Saldo Kartu Prabayar Anda\nRp. " + FUNC.insert_dot(balance) + ",-";
            }
        }
    }

//    Rectangle{
//        id: rec_timer
//        width:10
//        height:10
//        y:10
//        color:"transparent"
//        QtObject{
//            id:abc
//            property int counter
//            Component.onCompleted:{
//                abc.counter = timer_value
//            }
//        }

//        Timer{
//            id:my_timer
//            interval:1000
//            repeat:true
//            running:true
//            triggeredOnStart:true
//            onTriggered:{
//                abc.counter -= 1
//                if(abc.counter < 0){
//                    my_timer.stop()
//                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
//                }
//            }
//        }
//    }

    BackButton{
        id:back_button
        anchors.left: parent.left
        anchors.leftMargin: 120
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        z: 10
//        visible: !popup_loading.visible
        modeReverse: true
        MouseArea{
            anchors.fill: parent
            onClicked: {
                _SLOT.user_action_log('Press Back Button "Check Balance"');
                my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
            }
        }
    }

    //==============================================================
    //PUT MAIN COMPONENT HERE

    function open_preload_notif(){
        false_notif('Penumpang YTH|Silakan Tempelkan Kartu Prabayar Anda Pada Reader Sebelum Melanjutkan');
        standard_notif_view.buttonEnabled = false;
        standard_notif_view._button_text = 'lanjut';
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

//    Rectangle{
//        id: main_base
//        color: '#9E4305'
//        radius: 50
//        border.width: 0
//        anchors.verticalCenterOffset: 100
//        anchors.horizontalCenterOffset: 150
//        anchors.verticalCenter: parent.verticalCenter
//        anchors.horizontalCenter: parent.horizontalCenter
//        opacity: .97
//        width: 1100
//        height: 800
//        visible: !standard_notif_view.visible && !popup_loading.visible
//    }

    Text {
        id: notif_saldo
        height: 200
        color: "white"
        visible: !standard_notif_view.visible && !popup_loading.visible
        text: "Saldo Kartu Prabayar Anda\nRp. 0, -"
        wrapMode: Text.WordWrap
        anchors.verticalCenter: parent.verticalCenter
        font.bold: false
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenterOffset: 350
        font.family: "Microsoft YaHei"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 30
    }


    Image{
        id: image_prepaid_card
        visible: !standard_notif_view.visible && !popup_loading.visible
        source: "aAsset/card_tj_original.png"
        width: 400
        height: 250
        anchors.horizontalCenterOffset: -150
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        Text{
            id: card_no_prepaid
            font.pointSize: 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 25
            anchors.left: parent.left
            anchors.leftMargin: 30
            color: 'black'
        }
    }

    NextButton{
        id: check_button
        x: 242
        y: 732
        visible: !standard_notif_view.visible && !popup_loading.visible
        anchors.horizontalCenterOffset: -50
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 200
        anchors.horizontalCenter: parent.horizontalCenter
        button_text: 'Cek Saldo'
        modeReverse: true
        MouseArea{
            anchors.fill: parent
            onClicked : {
                _SLOT.user_action_log('Press "Cek Saldo"');
                if (press!='0') return;
                press = '1'
                popup_loading.open();
                _SLOT.start_check_balance();
            }
        }
    }

    NextButton{
        id: topup_button
        x: 542
        y: 732
        visible: !standard_notif_view.visible && !popup_loading.visible
        anchors.horizontalCenterOffset: 300
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 200
        anchors.horizontalCenter: parent.horizontalCenter
        button_text: 'Isi Saldo'
        modeReverse: true
        MouseArea{
            anchors.fill: parent
            onClicked: {
                _SLOT.user_action_log('Press "Isi Saldo"');
                if (!mandiriLogin) {
                    false_notif('Mohon Maaf|Fitur Isi Ulang Belum Diaktifkan')
                    return;
                }
                if (press!='0') return;
                press = '1';
                if (bankName=='BNI'){
                    if (ableTopupCode=='0000'){
                        var _cardData = {
                            'balance': balance,
                            'card_no': cardNo,
                            'bank_type': bankType,
                            'imageSource': imageSource,
                            'notifSaldo': notif_saldo.text
                        }
                        my_layer.push(topup_prepaid_denom, {cardData: _cardData});
                    } else if (ableTopupCode=='1008'){
                        press = 0;
                        false_notif('Mohon Maaf|Kartu BNI TapCash Anda Sudah Tidak Aktif\nSilakan Hubungi Bank BNI Terdekat')
                    }  else if (ableTopupCode=='5106'){
                        press = 0;
                        false_notif('Mohon Maaf|Kartu BNI TapCash Anda Tidak Resmi\nSilakan Gunakan Kartu TapCash Yang Lain')
                    } else {
                        press = 0;
                        false_notif('Mohon Maaf|Terjadi Kesalahan Pada Kartu BNI TapCash Anda\nSilakan Gunakan Kartu TapCash Yang Lain')
                    }
                } else {
                    press = 0;
                    false_notif('Mohon Maaf|Kartu Prabayar Anda Diterbitkan Oleh Bank Lain ('+bankName+')\nUntuk Sementara Kartu Anda Belum Dapat Digunakan Pada Mesin Ini')
                }
            }
        }
    }

    Text {
        id: small_notif
        x: 0
        color: "white"
        visible: !standard_notif_view.visible && !popup_loading.visible
        text: ""
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 150
        wrapMode: Text.WordWrap
        font.italic: true
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"Microsoft YaHei"
        font.pixelSize: 20
    }


    //==============================================================

//    ConfirmView{
//        id: confirm_view
//        show_text: "Dear Customer"
//        show_detail: "Proceed This ?."
//        z: 99
//        MouseArea{
//            id: ok_confirm_view
//            x: 668; y:691
//            width: 190; height: 50;
//            onClicked: {
//            }
//        }
//    }

//    NotifView{
//        id: notif_view
//        isSuccess: false
//        show_text: "Dear Customer"
//        show_detail: "Please Ensure You have set Your plan correctly."
//        z: 99
//    }

//    LoadingView{
//        id:loading_view
//        z: 99
//        show_text: "Finding Flight..."
//    }

    StandardNotifView{
        id: standard_notif_view
//        visible: true
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
                console.log('alternative button is pressed..!')
                popup_loading.open();
                _SLOT.start_check_balance();
                parent.visible = false;
                parent.buttonEnabled = true;
            }
        }
    }

    PopupLoading{
        id: popup_loading
    }


    GlobalFrame{
        id: global_frame
    }




}

