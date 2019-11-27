import QtQuick 2.4
import QtQuick.Controls 1.3
import QtGraphicalEffects 1.0
import "base_function.js" as FUNC


Base{
    id: check_prepaid_balance
    property int timer_value: 300
    property var press: '0'
    property var cardNo: ''
    property var balance: '0'
    property var topupData: undefined
    property var bankType: undefined
    property var bankName: undefined
    property var ableTopupCode: undefined
    property var imageSource: undefined
    property bool emoneyAvailable: false
    property bool tapcashAvailable: false
    property bool brizziAvailable: false
    property bool flazzAvailable: false
    property bool jakcardAvailable: false
    property var actionMode: 'check_balance'
    property variant allowedBank: []

    imgPanel: 'source/cek_saldo.png'
    textPanel: 'Cek Saldo Kartu Prabayar'

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            _SLOT.start_get_topup_readiness();
            preload_check_card.open();
            abc.counter = timer_value;
            my_timer.start();
            press = '0';
            cardNo = '';
            balance = 0;
            bankType = undefined;
            bankName = undefined;
            imageSource = undefined;
            ableTopupCode = undefined;
            actionMode = 'check_balance';
        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
        }
    }

    Component.onCompleted:{
        base.result_balance_qprox.connect(get_balance);
        base.result_topup_readiness.connect(topup_readiness);
//        base.result_topup_amount.connect(get_topup_amount);
        base.result_update_balance_online.connect(update_balance_online_result);
    }

    Component.onDestruction:{
        base.result_balance_qprox.disconnect(get_balance);
        base.result_topup_readiness.disconnect(topup_readiness);
//        base.result_topup_amount.disconnect(get_topup_amount);
        base.result_update_balance_online.disconnect(update_balance_online_result);
    }

    function update_balance_online_result(u){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss");
        console.log("update_balance_online_result : ", now, u);
        var func = u.split('|')[0]
        var result = u.split('|')[1]
        popup_loading.close();
        if (['ERROR', 'UNKNOWN_BANK'].indexOf(result) > -1){
            switch_frame('source/smiley_down.png', 'Terjadi Kesalahan Saat Update Balance', '', 'closeWindow', false )
            press = '0';
            return;
        }
        if (['MANDIRI_GENERAL_ERROR'].indexOf(result) > -1){
            switch_frame('source/take_prepaid_white.png', 'Update Saldo Hampir Berhasil', 'Angkat Dan Tempelkan Kembali Kartu Anda', 'closeWindow', true )
            press = '0';
            return;
        }
        if (['MANDIRI_NO_PENDING'].indexOf(result) > -1){
            switch_frame('source/smiley_down.png', 'Update Saldo Gagal', 'Kartu Anda Tidak Memiliki Pending Balance', 'closeWindow', true )
            press = '0';
            return;
        }
        if (result == 'SUCCESS'){
            var info = JSON.parse(u.split('|')[2]);
            var topup_amount = info.topup_amount;
            cardNo = info.card_no;
            balance = info.last_balance;
            switch_frame('source/success.png', 'Penambahan Saldo '+FUNC.insert_dot(topup_amount)+' Berhasil', 'Saldo Akhir Kartu Anda ' + FUNC.insert_dot(balance), 'backToMain', true );
            return;
        }
    }

//    function get_topup_amount(r){
//        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss");
//        console.log('get_topup_amount', now, r);
//        topupData = JSON.parse(r);
//    }

    function topup_readiness(r){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss");
        console.log('topup_readiness', now, r);
        popup_loading.close();
        var ready = JSON.parse(r);
        topupData = r;
        if (ready.mandiri=='AVAILABLE') {
            emoneyAvailable = true;
            allowedBank.push('MANDIRI');
        }
        if (ready.bni=='AVAILABLE') {
            tapcashAvailable = true;
            allowedBank.push('BNI');
        }
        if (ready.bri=='AVAILABLE') {
            brizziAvailable = true;
            allowedBank.push('BRI');
        }
        if (ready.dki=='AVAILABLE') {
            jakcardAvailable = true;
            allowedBank.push('DKI');
        }
        if (ready.bca=='AVAILABLE') {
            flazzAvailable = true;
            allowedBank.push('BCA');
        }
    }

    function get_balance(text){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss");
        console.log('get_balance', now, text);
        press = '0';
        popup_loading.close();
        standard_notif_view.buttonEnabled = true;
        var result = text.split('|')[1];
        if (result == 'ERROR'){
            cardNo = '';
            balance = 0;
            bankType = undefined;
            switch_frame('source/insert_card_new.png', 'Anda tidak meletakkan kartu', 'atau kartu Anda tidak dapat digunakan', 'backToMain', false );
            return;
//            false_notif('Mohon Maaf|Gagal Mendapatkan Saldo, Pastikan Kartu Prabayar Anda Sudah Ditempelkan Pada Reader');
//            image_prepaid_card.source = "source/card_tj_original.png";
//            imageSource = "source/card_tj_original.png";
//            notif_saldo.text = "Saldo Kartu Prabayar Anda\nRp. 0, -";
        }
//        else {
//            if (bankName == 'MANDIRI'){
//                image_prepaid_card.source = "source/mandiri_emoney_card.png";
//                imageSource = "source/mandiri_emoney_card.png";
//                notif_saldo.text = "Saldo Kartu Prabayar e-Money Anda\nRp. " + FUNC.insert_dot(balance) + ",-";
//            } else if (bankName == 'BNI'){
//                image_prepaid_card.source = "source/bni_tapcash_card.png";
//                imageSource = "source/bni_tapcash_card.png";
//                notif_saldo.text = "Saldo Kartu Prabayar TapCash Anda\nRp. " + FUNC.insert_dot(balance) + ",-";
//            } else if (bankName == 'BCA'){
//                image_prepaid_card.source = "source/bca_flazz_card.png";
//                imageSource = "source/bca_flazz_card.png";
//                notif_saldo.text = "Saldo Kartu Prabayar Flazz Anda\nRp. " + FUNC.insert_dot(balance) + ",-";
//            }else {
//                image_prepaid_card.source = "source/card_tj_original.png";
//                imageSource = "source/card_tj_original.png";
//                notif_saldo.text = "Saldo Kartu Prabayar Anda\nRp. " + FUNC.insert_dot(balance) + ",-";
//            }
//        }
        var info = JSON.parse(result);
        balance = info.balance.toString();
        cardNo = info.card_no;
        bankType = info.bank_type;
        bankName = info.bank_name;
        ableTopupCode = info.able_topup;
        var cardNo__ = FUNC.insert_space_four(cardNo)
        content_card_no.text = cardNo__.substring(0, cardNo__.length-3);
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
        anchors.leftMargin: 50
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        button_text: 'BATAL'
        modeReverse: true
        visible: !popup_loading.visible && !preload_check_card.visible
        MouseArea{
            anchors.fill: parent
            onClicked: {
                _SLOT.user_action_log('Press Back Button "Check Balance"');
                my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
            }
        }
    }

    CircleButtonBig{
        id: update_online_button
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        button_text: 'UPDATE SALDO'
        modeReverse: true
        visible: !popup_loading.visible && !preload_check_card.visible && (['MANDIRI'].indexOf(bankName) > -1)
        MouseArea{
            anchors.fill: parent
            onClicked: {
                _SLOT.user_action_log('Press "UPDATE SALDO"');
                actionMode = 'update_balance_online';
                preload_check_card.open();
            }
        }
    }

    CircleButton{
        id: next_button
        anchors.right: parent.right
        anchors.rightMargin: 50
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        button_text: 'ISI SALDO'
        modeReverse: true
        visible: !popup_loading.visible && !preload_check_card.visible
        blinkingMode: true
        MouseArea{
            anchors.fill: parent
            onClicked: {
                _SLOT.user_action_log('Press "ISI SALDO"');
                preload_check_card.close();
                if (press!='0') return;
                press = '1'
                if (allowedBank.indexOf(bankName) > -1){
                    if ((bankName=='MANDIRI' && !emoneyAvailable) ||
                            (bankName=='BNI' && !tapcashAvailable) ||
                            (bankName=='BRI' && !brizziAvailable) ||
                            (bankName=='DKI' && !jakcardAvailable) ||
                            (bankName=='BCA' && !flazzAvailable)){
                        switch_frame('source/smiley_down.png', 'Mohon Maaf, fitur topup bank '+bankName, 'sedang tidak dapat digunakan saat ini', 'backToMain', false );
                        return;
                    }
                    var _cardData = {
                        'balance': balance,
                        'card_no': cardNo,
                        'bank_type': bankType,
                        'bank_name': bankName,
                        'imageSource': imageSource,
                        'notifSaldo': ''
                    }
                    my_layer.push(topup_prepaid_denom, {cardData: _cardData, shopType: 'topup', topupData: topupData, allowedBank: allowedBank});
//                    if (ableTopupCode=='0000'){
////                    } else if (ableTopupCode=='1008'){
////                        press = 0;
////                        false_notif('Mohon Maaf|Kartu BNI TapCash Anda Sudah Tidak Aktif\nSilakan Hubungi Bank BNI Terdekat')
////                        switch_frame('source/smiley_down.png', 'Maaf Kartu Anda Sudah Tidak Aktif', '', 'closeWindow', false );
////                        return;
////                    }  else if (ableTopupCode=='5106'){
////                        press = 0;
////                        false_notif('Mohon Maaf|Kartu BNI TapCash Anda Tidak Resmi\nSilakan Gunakan Kartu TapCash Yang Lain')
////                        switch_frame('source/smiley_down.png', 'Maaf Kartu Anda Sudah Tidak Resmi', 'Gunakan Kartu lainnya', 'closeWindow', false );
////                        return;
//                    } else {
//                        press = 0;
////                        false_notif('Mohon Maaf|Terjadi Kesalahan Pada Kartu BNI TapCash Anda\nSilakan Gunakan Kartu TapCash Yang Lain');
//                        switch_frame('source/insert_card_new.png', 'Maaf terjadi kesalahan pada kartu Anda', 'gunakan kartu lainnya', 'closeWindow', false );
//                        return;
//                    }
                } else {
                    switch_frame('source/smiley_down.png', 'Mohon Maaf, fitur topup bank '+bankName, 'tidak tersedia saat ini', 'backToMain', false );
                    return;
                }
            }
        }
    }

    //==============================================================
    //PUT MAIN COMPONENT HERE


    function false_notif(img, msg){
        if (img==undefined) img = 'source/smiley_down.png';
        if (msg==undefined) msg = 'Maaf Sementara Mesin Tidak Dapat Digunakan';
        press = '0';
        switch_frame(img, msg, '', 'backToMain', false )
        return;
    }

    function switch_frame(imageSource, textMain, textSlave, closeMode, smallerText){
        global_frame.imageSource = imageSource;
        global_frame.textMain = textMain;
        global_frame.textSlave = textSlave;
        global_frame.closeMode = closeMode;
        global_frame.smallerSlaveSize = smallerText;
        global_frame.open();
    }

    Text {
        id: label_card_no
        color: "white"
        text: "Nomor kartu Anda"
        anchors.top: parent.top
        anchors.topMargin: 375
        anchors.left: parent.left
        anchors.leftMargin: 350
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"Gotham"
        font.pixelSize: 50
        visible: !popup_loading.visible && !preload_check_card.visible
    }

    Text {
        id: content_card_no
        width: 600
        color: "white"
        text: (cardNo==undefined) ? '' : cardNo
        anchors.right: parent.right
        anchors.rightMargin: 350
        anchors.top: parent.top
        anchors.topMargin: 375
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.family:"Gotham"
        font.pixelSize: 50
        visible: !popup_loading.visible && !preload_check_card.visible
    }

    Text {
        id: label_card_balance
        color: "white"
        text: "Saldo kartu Anda"
        anchors.top: parent.top
        anchors.topMargin: 500
        anchors.left: parent.left
        anchors.leftMargin: 350
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"Gotham"
        font.pixelSize: 50
        visible: !popup_loading.visible && !preload_check_card.visible
    }

    Text {
        id: content_balance
        width: 400
        color: "white"
        text: (balance=='0') ? 'Rp 0' : 'Rp ' + FUNC.insert_dot(balance)
        anchors.right: parent.right
        anchors.rightMargin: 350
        anchors.top: parent.top
        anchors.topMargin: 500
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.family:"Gotham"
        font.pixelSize: 50
        visible: !popup_loading.visible && !preload_check_card.visible
    }

    Text {
        id: label_card_type
        color: "white"
        text: "Penerbit kartu"
        anchors.top: parent.top
        anchors.topMargin: 250
        anchors.left: parent.left
        anchors.leftMargin: 350
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"Gotham"
        font.pixelSize: 50
        visible: !popup_loading.visible && !preload_check_card.visible
    }

    Text {
        id: content_card_type
        width: 600
        color: "white"
        text: (bankName==undefined) ? '' : bankName
        anchors.right: parent.right
        anchors.rightMargin: 350
        anchors.top: parent.top
        anchors.topMargin: 250
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.family:"Gotham"
        font.pixelSize: 50
        visible: !popup_loading.visible && !preload_check_card.visible
    }

    /*

    Image{
        id: image_prepaid_card
        visible: !standard_notif_view.visible && !popup_loading.visible
        source: "source/card_tj_original.png"
        width: 400
        height: 250
        anchors.horizontalCenterOffset: -150
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        Text{
            id: card_no_prepaid
            font.pixelSize: 16
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
        font.family:"Gotham"
        font.pixelSize: 20
    }

    */


    //==============================================================


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

    PreloadCheckCard{
        id: preload_check_card
//        visible: true
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
            blinkingMode: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press "LANJUT"');
                    if (press!='0') return;
                    press = '1'
                    popup_loading.open();
                    switch(actionMode){
                    case 'check_balance':
                        _SLOT.start_check_balance();
                        break;
                    case 'update_balance_online':
                        _SLOT.start_update_balance_online(bankName);
                        break;
                    }
                    preload_check_card.close();
                }
            }
        }
    }

}

