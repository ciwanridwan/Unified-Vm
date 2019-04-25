import QtQuick 2.4
import QtQuick.Controls 1.3
import QtGraphicalEffects 1.0
import "base_function.js" as FUNC

Base{
    id: select_provider_prepaid
    property int timer_value: 300
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
    signal topup_denom_signal(string str)

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            popup_loading.open();
            _SLOT.get_kiosk_price_setting();
            if (directTopup==undefined && topupData==undefined){
                _SLOT.start_kiosk_get_topup_amount();
                _SLOT.start_get_topup_readiness();
            } else {
                console.log('directTopup', JSON.stringify(directTopup));
                console.log('topupData', JSON.stringify(topupData));
                perform_direct_topup();
            }
            abc.counter = timer_value;
            my_timer.start();
            press = '0';
            denomTopup = undefined
            provider = undefined
        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
            loading_view.close()
        }
    }

    Component.onCompleted:{
        select_provider_prepaid.topup_denom_signal.connect(selected_denom);
        base.result_balance_qprox.connect(get_balance);
        base.result_topup_readiness.connect(topup_readiness);
        base.result_topup_amount.connect(get_topup_amount);
        base.result_price_setting.connect(define_price);
    }

    Component.onDestruction:{
        select_provider_prepaid.topup_denom_signal.disconnect(selected_denom);
        base.result_balance_qprox.disconnect(get_balance);
        base.result_topup_readiness.disconnect(topup_readiness);
        base.result_topup_amount.disconnect(get_topup_amount);
        base.result_price_setting.disconnect(define_price);

    }

    function define_price(p){
        console.log('define_price', p);
        var price = JSON.parse(p);
        adminFee = parseInt(price.adminFee);
        console.log('adminFee', adminFee);
    }


    function perform_direct_topup(){
        console.log('perform_direct_topup', JSON.stringify(directTopup));
        popup_loading.close();
        emoneyAvailable = directTopup.emoneyAvailable;
        tapcashAvailable = directTopup.tapcashAvailable;
        mandiriTopupWallet = directTopup.mandiriTopupWallet;
        bniTopupWallet = directTopup.bniTopupWallet;
        var bin = directTopup.cardNo.substring(0, 4);
        if (bin=='6032'){
            if (mandiriTopupWallet > 0){
                init_topup_denom('MANDIRI');
                provider = 'e-Money Mandiri';
            } else {
                false_notif('Mohon Maaf|Terjadi Kesalahan Saat Memeriksa Saldo Isi Ulang, Mohon Hubungi Layanan Pelanggan')
            }
        }
        if (bin=='7546'){
            if (bniTopupWallet > 0){
                init_topup_denom('BNI');
                provider = 'TapCash BNI';
            } else {
                false_notif('Mohon Maaf|Terjadi Kesalahan Saat Memeriksa Saldo Isi Ulang, Mohon Hubungi Layanan Pelanggan')
            }
        }
    }

    function topup_readiness(r){
        console.log('topup_readiness', r);
        var ready = JSON.parse(r)
        if (ready.mandiri=='AVAILABLE') emoneyAvailable = true;
        if (ready.bni=='AVAILABLE') tapcashAvailable = true;
        mandiriTopupWallet = parseInt(ready.balance_mandiri);
        bniTopupWallet = parseInt(ready.balance_bni);
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
        var cart = JSON.parse(d)
        my_layer.push(shop_prepaid_card, {shop_type: 'topup', cart: cart})
    }


    function get_topup_amount(r){
        console.log('get_topup_amount', r);
        topupData = JSON.parse(r)
    }

    function get_balance(text){
        console.log('get_balance', text);
        press = '0';
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

    BackButton{
        id:back_button
        x: 20;y: 122
        visible: !popup_loading.visible
        MouseArea{
            anchors.fill: parent
            onClicked: {
                my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
            }
        }
    }

    //==============================================================
    //PUT MAIN COMPONENT HERE

    function open_preload_notif(){
        false_notif('Penumpang YTH|Silakan Tempelkan Kartu Prabayar Anda Pada Reader Sebelum Melanjutkan');
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

    Text {
        id: main_title
        height: 100
        color: "white"
        visible: (provider==undefined && !popup_loading.visible) ? true : false
        text: "Pilih Kartu Prabayar"
        anchors.top: parent.top
        anchors.topMargin: 160
        wrapMode: Text.WordWrap
        font.bold: false
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenterOffset: 0
        font.family: "Ubuntu"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 45
    }

    Row{
        id: row_button
        width: 800
        height: 350
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 50
        visible: (provider==undefined && !popup_loading.visible) ? true : false
        Image {
            id: emoney_mandiri
            source: "aAsset/emoney-card.png"
            width: 400
            height: 300
            fillMode: Image.PreserveAspectFit
            MouseArea{
                enabled: emoneyAvailable
                anchors.fill: parent
                onClicked: {
                    if (mandiriTopupWallet > 0){
                        init_topup_denom('MANDIRI');
                        provider = 'e-Money Mandiri';
                    } else {
                        false_notif('Mohon Maaf|Terjadi Kesalahan Saat Memeriksa Saldo Isi Ulang, Mohon Hubungi Layanan Pelanggan')
                    }
                }
            }
            ColorOverlay{
                visible: !emoneyAvailable
                anchors.fill: parent
                source: parent
                color: 'gray'
                opacity: .5
            }
            Text {
                id: not_available_mandiri
                text: qsTr("TIDAK TERSEDIA")
                anchors.rightMargin: 0
                anchors.leftMargin: 0
                anchors.bottomMargin: 0
                anchors.topMargin: 0
                anchors.top: parent.bottom
                anchors.right: parent.left
                anchors.bottom: parent.top
                anchors.left: parent.right
                visible: !emoneyAvailable
                font.pixelSize: 20
                color: 'white'
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
        Image {
            id: tapcash_bni
            source: "aAsset/tapcash-card.png"
            width: 400
            height: 300
            fillMode: Image.PreserveAspectFit
            MouseArea{
                enabled: tapcashAvailable
                anchors.fill: parent
                onClicked: {
                    if (bniTopupWallet > 0){
                        init_topup_denom('BNI');
                        provider = 'TapCash BNI';
                    } else {
                        false_notif('Mohon Maaf|Terjadi Kesalahan Saat Memeriksa Saldo Isi Ulang, Mohon Hubungi Layanan Pelanggan')
                    }
                }
            }
            ColorOverlay{
                visible: !tapcashAvailable
                anchors.fill: parent
                source: parent
                color: 'gray'
                opacity: .5
            }
            Text {
                id: not_available_bni
                visible: !tapcashAvailable
                text: qsTr("TIDAK TERSEDIA")
                anchors.rightMargin: 0
                anchors.leftMargin: 0
                anchors.bottomMargin: 0
                anchors.topMargin: 0
                anchors.top: parent.bottom
                anchors.right: parent.left
                anchors.bottom: parent.top
                anchors.left: parent.right
                font.pixelSize: 20
                color: 'white'
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

    }


    Text {
        id: small_notif
        x: 0
        color: "white"
        visible: !standard_notif_view.visible && !popup_loading.visible
        text: "*Pastikan Kartu Prabayar Anda masih ditempelkan di reader."
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        anchors.horizontalCenter: parent.horizontalCenter
        wrapMode: Text.WordWrap
        font.italic: true
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenterOffset: 0
        font.family:"Ubuntu"
        font.pixelSize: 20
    }

        Rectangle{
            id: mandiri_topup_status
            color: "blue"
            opacity: 0.75
            border.width: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: product_stock_status.width
            width: 200
            height: 30
            Row{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.top: parent.top
                spacing: 10
                Text{
                    id: mandiri_topup_wallet
                    height: parent.height
                    text: 'MANDIRI : ' + FUNC.insert_dot(mandiriTopupWallet.toString())
                    font.bold: true
                    color: 'white'
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Rectangle{
            id: bni_topup_status
            color: "orange"
            opacity: 0.75
            border.width: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: mandiri_topup_status.width
            width: 200
            height: 30
            Row{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.top: parent.top
                spacing: 10
                Text{
                    id: bni_topup_wallet
                    height: parent.height
                    text: 'BNI : ' + FUNC.insert_dot(bniTopupWallet.toString())
                    font.bold: true
                    color: 'white'
                    verticalAlignment: Text.AlignVCenter
                }
            }
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
        withBackground: false
        modeReverse: true
        show_text: "Dear Customer"
        show_detail: "Please Ensure You have set Your plan correctly."
        z: 99
    }

    SelectDenomTopupNotif{
        id: select_denom
        visible: (provider==undefined) ? false : true
        _provider: provider
        bigDenomAmount: 100
        smallDenomAmount: 50
        _adminFee: adminFee
        tinyDenomAmount: 0
    }

    PopupLoading{
        id: popup_loading
    }





}

