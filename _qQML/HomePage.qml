import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0
import "screen.js" as SCREEN
import "config.js" as CONF

Base{
    id: base_page
    width: parseInt(SCREEN.size.width)
    height: parseInt(SCREEN.size.height)
    property var press: "0"
    property int tvc_timeout: parseInt(CONF.tvc_waiting_time)
    property bool isMedia: true
    property bool kioskStatus: false
    property var productData: undefined
    property var productCountAll: 0
    property var productCount1: 0
    property var productCount2: 0
    property var productCount3: 0
    property var mandiriTopupWallet: 0
    property bool mandiriTopupActive: false
    property bool bniTopupActive: false
    property var bniTopupWallet: 0
    property bool kalogButton: false
    property bool withSlider: true
    property bool first_run: true
    isPanelActive: false

    Stack.onStatusChanged:{
        if(Stack.status == Stack.Activating){
            _SLOT.start_idle_mode();
            if (first_run) _SLOT.get_kiosk_status();
            _SLOT.kiosk_get_product_stock();
            press = "0";
            resetMediaTimer();
            kalogButton = false;
            productCount1 = 0;
            productCount2 = 0;
            productCount3 = 0;
            popup_loading.close();
        }
        if(Stack.status==Stack.Deactivating){
            show_tvc_loading.stop();
        }
    }

    Component.onCompleted: {
        base.result_get_gui_version.connect(get_gui_version);
        base.result_product_stock.connect(get_product_stock);
        base.result_generate_pdf.connect(get_pdf);
        base.result_general.connect(handle_general);
        base.result_kiosk_status.connect(get_kiosk_status);
        base.result_topup_readiness.connect(topup_readiness);
        base.result_auth_qprox.connect(ka_login_status);
        base.result_get_ppob_product.connect(get_ppob_product);
    }

    Component.onDestruction: {
//        slider.close();
        base.result_get_gui_version.disconnect(get_gui_version);
        base.result_product_stock.connect(get_product_stock);
        base.result_generate_pdf.disconnect(get_pdf);
        base.result_general.disconnect(handle_general);
        base.result_kiosk_status.disconnect(get_kiosk_status);
        base.result_topup_readiness.disconnect(topup_readiness);
        base.result_auth_qprox.disconnect(ka_login_status);
        base.result_get_ppob_product.disconnect(get_ppob_product);
    }

    function get_ppob_product(p){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('get_ppob_product', now, p);
         press = '0';
         my_layer.push(ppob_category, {ppobData: p});
        popup_loading.close();
    }

    function resetMediaTimer(){
        if(isMedia){
            tvc_loading.counter = tvc_timeout;
            show_tvc_loading.start();
        }
    }

    function ka_login_status(t){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('ka_login_status', now, t);
        popup_loading.close()
        var result = t.split('|')[1]
        if (result == 'ERROR'){
            kalog_notif();
            kalogButton = false;
        } else if (result == 'SUCCESS'){
            kalog_notif('Selamat|Login KA Mandiri Berhasil');
            kalogin_notif_view._button_text = 'tutup';
            kalogButton = false;
        } else {
            kalog_notif('Mohon Maaf|Login KA Mandiri Gagal, Kode Error ['+result+'], Silakan Coba Lagi');
            kalogButton = true;
        }
    }

    function topup_readiness(t){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('topup_readiness', now, t);
        if (t=='TOPUP_READY|ERROR'){
            kalog_notif();
            return;
        }
        var tr = JSON.parse(t);
        mandiriTopupWallet = parseInt(tr.balance_mandiri);
        bniTopupWallet = parseInt(tr.balance_bni);
        if (tr.mandiri == 'AVAILABLE' || tr.mandiri == 'TEST_MODE') {
            if (mandiriTopupWallet > 0) mandiriTopupActive = true;
        }
        if (tr.bni == 'AVAILABLE') {
            if (bniTopupWallet > 0) bniTopupActive = true;
        }
    }

    function get_product_stock(p){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('product_stock', now, p);
        productData = JSON.parse(p);
        if (productData.length > 0) {
            if (productData[0].status==101 && parseInt(productData[0].stock) > 0) productCount1 = parseInt(productData[0].stock);
            if (productData[0].status==102 && parseInt(productData[0].stock) > 0) productCount2 = parseInt(productData[0].stock);
            if (productData[0].status==103 && parseInt(productData[0].stock) > 0) productCount3 = parseInt(productData[0].stock);
        }

        if (productData.length > 1) {
            if (productData[1].status==101 && parseInt(productData[1].stock) > 0) productCount1 = parseInt(productData[1].stock);
            if (productData[1].status==102 && parseInt(productData[1].stock) > 0) productCount2 = parseInt(productData[1].stock);
            if (productData[1].status==103 && parseInt(productData[1].stock) > 0) productCount3 = parseInt(productData[1].stock);
        }
        if (productData.length > 2) {
            if (productData[2].status==101 && parseInt(productData[2].stock) > 0) productCount1 = parseInt(productData[2].stock);
            if (productData[2].status==102 && parseInt(productData[2].stock) > 0) productCount2 = parseInt(productData[2].stock);
            if (productData[2].status==103 && parseInt(productData[2].stock) > 0) productCount3 = parseInt(productData[2].stock);
        }
        productCountAll = productCount1 + productCount2 + productCount3;
//        console.log('product stock count : ', productCount1, productCount2, productCount3, productCountAll);
    }

    function get_kiosk_status(r){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log("get_kiosk_status", now, r);

        first_run = false;

        var kiosk = JSON.parse(r);
        base.globalBoxName = kiosk.name;
        box_version.text = kiosk.version;
        box_tid.text = kiosk.tid;

        //Handle Feature Button From Kiosk Status
        check_saldo_button.visible = (kiosk.feature.balance_check == 1)
        topup_saldo_button.visible = (kiosk.feature.top_up_balance == 1)
        buy_card_button.visible = (kiosk.feature.buy_card == 1)
        ppob_button.visible = (kiosk.feature.ppob == 1)
        search_trx_button.visible = (kiosk.feature.search_trx == 1)
        wa_voucher_button.visible = (kiosk.feature.whatsapp_voucher == 1)

        if (kiosk.status == "ONLINE" || kiosk.status == "AVAILABLE") {
            kioskStatus = true;
            box_connection.color = 'green';
            box_connection.text = kiosk.real_status;
            if (kiosk.real_status=='OFFLINE') box_connection.color = 'red';
        } else {
            box_connection.text = kiosk.real_status;
            box_connection.color = 'red';
            kioskStatus = false;
        }
        _SLOT.start_get_topup_readiness();
    }

    function not_authorized(){
        press = '0';
//        slider.close();
        false_notif('Mohon Maaf|Mesin Tidak Dapat Digunakan, Silakan Periksa Koneksi Internet');
    }

    function handle_general(result){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log("handle_general : ", now, result);
        if (result=='') return;
        if (result=='REBOOT'){
            switch_frame('source/loading_static.png', 'Mohon Tunggu Mesin Akan Dimuat Ulang', 'Dalam 30 Detik', 'closeWindow', false )
            return;
        }
    }

    function get_pdf(pdf){
        console.log("get_pdf : ", pdf);
    }

    function get_gui_version(result){
        console.log("get_gui_version : ", result);
    }

    function false_notif(param){
        press = '0';
        switch_frame('source/smiley_down.png', 'Maaf Sementara Mesin Tidak Dapat Digunakan', '', 'backToMain', false )
        return;
    }

    function kalog_notif(param){
        press = '0';
        switch_frame('source/smiley_down.png', 'Maaf Sementara Mesin Tidak Dapat Untuk', 'Melakukan Pengisian Kartu', 'closeWindow', false )
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

//    LoadingViewNew{
//        id: slider
//        x: 0; y:0;
//        visible: withSlider
//        show_caption: false
//        height: 1080
//        width: 1920
//    }

    MainTitle{
        anchors.top: parent.top
        anchors.topMargin: 350
        anchors.horizontalCenter: parent.horizontalCenter
        show_text: 'Selamat Datang, Silakan Pilih Menu Berikut : '
        visible: !popup_loading.visible
        size_: 50
        color_: "white"

    }

    Row{
        id: row_button
        anchors.verticalCenterOffset: 100
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 60
        visible: (!standard_notif_view.visible && !kalogin_notif_view.visible && !popup_loading.visible) ? true : false;

        MasterButtonNew {
            id: check_saldo_button
            x: 150
            anchors.verticalCenter: parent.verticalCenter
            img_: "source/cek_saldo.png"
            text_: qsTr("Cek Saldo")
            text2_: qsTr("Balance Check")
            modeReverse: false
            visible: false
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press "Cek Saldo"');
                    resetMediaTimer();
                    if (press!="0") return;
                    press = "1";
                    _SLOT.set_tvc_player("STOP");
                    my_layer.push(check_balance, {mandiriAvailable: mandiriTopupActive});
                    _SLOT.stop_idle_mode();
                    show_tvc_loading.stop();
                }
            }
        }

        MasterButtonNew {
            id: topup_saldo_button
            x: 150
            anchors.verticalCenter: parent.verticalCenter
            img_: "source/topup_kartu.png"
            text_: qsTr("Topup Saldo")
            text2_: qsTr("Topup Balance")
            modeReverse: false
            visible: false
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press "TopUp Saldo"');
                    resetMediaTimer();
                    if (!mandiriTopupActive) {
                        kalog_notif();
                        return;
                    }
                    if (press!="0") return;
                    press = "1";
                    _SLOT.set_tvc_player("STOP");
                    my_layer.push(topup_prepaid_denom, {shopType: 'topup'});
                    _SLOT.stop_idle_mode();
                    show_tvc_loading.stop();
                }
            }
        }

        MasterButtonNew {
            id: buy_card_button
            x: 150
            anchors.verticalCenter: parent.verticalCenter
            img_: "source/beli_kartu.png"
            text_: qsTr("Beli Kartu")
            text2_: qsTr("Buy Card")
            modeReverse: false
            color_: (productCountAll > 0) ? 'white' : 'gray'
            opacity: 1
            visible: false
            MouseArea{
                enabled: (productCountAll > 0) ? true : false
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press "Beli Kartu"');
                    resetMediaTimer();
                    if (press!="0") return;
                    press = "1";
                    _SLOT.set_tvc_player("STOP");
                    my_layer.push(mandiri_shop_card, {productData: productData, shop_type: 'shop', productCount: productCountAll});
                    _SLOT.stop_idle_mode();
                    show_tvc_loading.stop();
                }
            }
            Rectangle{
                id: oos_overlay
                y: 0
                width: parent.width
                height: 50
                color: "#ffffff"
                border.width: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 25
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.8
                visible: (productCountAll > 0) ? false : true
                Text {
                    id: text_oos
                    text: qsTr("HABIS")
                    anchors.fill: parent
                    font.pixelSize: 25
                    color: "#000000"
                    font.bold: false
                    font.family:"Ubuntu"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        MasterButtonNew {
            id: ppob_button
            x: 150
            anchors.verticalCenter: parent.verticalCenter
            img_: "source/shop_cart.png"
            text_: qsTr("Bayar/Beli")
            text2_: qsTr("Pay/Buy")
            modeReverse: false
            visible: false
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press "Bayar/Beli"');
                    resetMediaTimer();
                    if (press!="0") return;
                    press = "1";
                    _SLOT.set_tvc_player("STOP");
                    popup_loading.open();
                    _SLOT.start_get_ppob_product();
//                    my_layer.push(topup_prepaid_denom, {shopType: 'topup'});
                    _SLOT.stop_idle_mode();
                    show_tvc_loading.stop();
                }
            }
        }

    }

    Rectangle{
        id: timer_tvc
        width: 10
        height: 10
        x:0
        y:0
        visible: false
        QtObject{
            id:tvc_loading
            property int counter
            Component.onCompleted:{
                tvc_loading.counter = tvc_timeout;
            }
        }
        Timer{
            id:show_tvc_loading
            interval:1000
            repeat:true
            running:false
            triggeredOnStart:true
            onTriggered:{
                tvc_loading.counter -= 1
                if (tvc_loading.counter%2==0){
                    search_trx_button.color = 'silver';
                    wa_voucher_button.color = '#4FCE5D';
                } else {
                    search_trx_button.color = 'white';
                    wa_voucher_button.color = 'white';
                }
//                _SLOT.post_tvc_log('Integrasi Transportasi.mp4');
                if(tvc_loading.counter == 0){
                    if (!mediaOnPlaying) {
                        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
                        console.log("starting tvc player...", now);
                        my_layer.push(media_page, {mode: 'mediaPlayer'});
                    }
//                    _SLOT.set_tvc_player('START')
                    tvc_loading.counter = tvc_timeout;
                    show_tvc_loading.restart();
                }
            }
        }
    }

    Rectangle{
        id: login_button_rec
        color: 'white'
        radius: 20
        anchors.top: parent.top
        anchors.topMargin: 200
        anchors.left: parent.left
        anchors.leftMargin: -30
        width: 100
        height: 80
        Image{
            id: login_button_img
            width: 80
            height: 90
            anchors.horizontalCenterOffset: 10
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.horizontalCenter: parent.horizontalCenter
            scale: 0.75
            source: 'source/adult-male.png'
            fillMode: Image.PreserveAspectFit
        }

        MouseArea{
            anchors.fill: parent
            onDoubleClicked: {
                _SLOT.user_action_log('Press "Admin" Button');
                console.log('Admin Button is Pressed..!');
                _SLOT.set_tvc_player("STOP");
                _SLOT.stop_idle_mode();
                resetMediaTimer();
                my_layer.push(admin_login);
            }
        }
    }

    Rectangle{
        id: search_trx_button
        color: 'white'
        radius: 20
        anchors.right: parent.right
        anchors.rightMargin: -15
        anchors.top: parent.top
        anchors.topMargin: 200
        width: 100
        height: 300
        visible: false
        Text{
            text: 'CEK\nTRANSAKSI'
            font.pixelSize: 30
            anchors.horizontalCenterOffset: -10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 80
            anchors.horizontalCenter: parent.horizontalCenter
            font.family:"Ubuntu"
            font.bold: true
            rotation: 270
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        Image{
            width: 80
            height: 90
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            scale: 0.75
            source: "source/find.png"
            fillMode: Image.PreserveAspectFit
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                if (press!="0") return;
                press = "1";
                _SLOT.user_action_log('Press "SEARCH_TRX" Button');
                console.log('Search Trx Button is Pressed..!');
                _SLOT.set_tvc_player("STOP");
                _SLOT.stop_idle_mode();
                resetMediaTimer();
                my_layer.push(global_input_number, {mode: 'SEARCH_TRX'});
            }
        }
    }

    Rectangle{
        id: wa_voucher_button
        color: 'white'
        radius: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 275
        anchors.right: parent.right
        anchors.rightMargin: -15
        width: 100
        height: 300
        visible: false
        Text{
            text: "WHATSAPP\nVOUCHER"
            font.pixelSize: 28
            anchors.horizontalCenterOffset: -10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 80
            anchors.horizontalCenter: parent.horizontalCenter
            font.family:"Ubuntu"
            font.bold: true
            rotation: 270
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        Image{
            y: 0
            width: 100
            height: 100
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            scale: 0.75
            source: "source/whatsapp_transparent_black.png"
            fillMode: Image.PreserveAspectCrop
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                if (press!="0") return;
                press = "1";
                _SLOT.user_action_log('Press "WA_VOUCHER" Button');
                console.log('WA Voucher Button is Pressed..!');
                _SLOT.set_tvc_player("STOP");
                _SLOT.stop_idle_mode();
                resetMediaTimer();
                preload_whatasapp_voucher.open()
            }
        }
    }


    Rectangle{
        id: machine_status_rec
        color: "#ffffff"
        anchors.right: parent.right
        anchors.rightMargin: 300
        opacity: 0.75
        border.width: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        width: 300
        height: 30
        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.top: parent.top
            spacing: 10
            Text{
                id: box_tid
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                color: "#000000"
                font.family:"Ubuntu"
            }
            Text{
                id: box_version
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                color: "#000000"
                font.family:"Ubuntu"
            }
            Image{
                id: img_kiosk
                height: parent.height
                source: 'source/icon/kiosk.png'
                fillMode: Image.PreserveAspectFit
                scale: .8
                verticalAlignment: Text.AlignVCenter
            }
            Text{
                id: box_connection
                font.bold: true
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                color: 'white'
                font.family:"Ubuntu"
            }
        }

    }

    Rectangle{
        id: product_stock_status1
        color: "#fff000"
        anchors.leftMargin: 0
        opacity: 0.75
        border.width: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: machine_status_rec.right
        width: 75
        height: 30
        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.top: parent.top
            spacing: 10
            Image{
                id: img_product
                height: parent.height
                source: 'source/icons-cards-2.png'
                fillMode: Image.PreserveAspectFit
                scale: .8
                verticalAlignment: Text.AlignVCenter
            }
            Text{
                id: product_count
                height: parent.height
                text: productCount1
                font.bold: true
                color: 'blue'
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Rectangle{
        id: product_stock_status2
        color: "#ff0000"
        anchors.leftMargin: 0
        opacity: 0.75
        border.width: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: product_stock_status1.right
        width: 75
        height: 30
        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.top: parent.top
            spacing: 10
            Image{
                id: img_product2
                height: parent.height
                source: 'source/icons-cards-2.png'
                fillMode: Image.PreserveAspectFit
                scale: .8
                verticalAlignment: Text.AlignVCenter
            }
            Text{
                id: product_count2
                height: parent.height
                text: productCount2
                font.bold: true
                color: 'white'
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Rectangle{
        id: product_stock_status3
        color: "#00f00f"
        anchors.leftMargin: 0
        opacity: 0.75
        border.width: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: product_stock_status2.right
        width: 75
        height: 30
        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.top: parent.top
            spacing: 10
            Image{
                id: img_product3
                height: parent.height
                source: 'source/icons-cards-2.png'
                fillMode: Image.PreserveAspectFit
                scale: .8
                verticalAlignment: Text.AlignVCenter
            }
            Text{
                id: product_count3
                height: parent.height
                text: productCount3
                font.bold: true
                color: 'white'
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

//    NotifView{
//        id: notif_view
//        isSuccess: false
//        z: 99
//    }

    StandardNotifView{
        id: standard_notif_view
//        withBackground: false
        modeReverse: true
        show_text: "Dear Customer"
        show_detail: "Please Ensure You have set Your plan correctly."
        z: 99
    }

    StandardNotifView{
        id: kalogin_notif_view
        withBackground: false
        buttonEnabled: false
        modeReverse: true
        show_text: "Dear Customer"
        show_detail: "Please Ensure You have set Your plan correctly."
        z: 999
        MouseArea{
            id: kalog_button
            enabled: kalogButton
            x: 550; y: 666
            width: 180
            height: 90
            onClicked: {
                popup_loading.open();
                _SLOT.start_auth_ka();
                parent.visible = false;
            }
        }
    }

    PopupLoading{
        id: popup_loading
    }

    GlobalFrame{
        id: global_frame
    }

    PreloadWhatsappVoucher{
        id: preload_whatasapp_voucher
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
                    preload_whatasapp_voucher.close();
                    _SLOT.start_idle_mode();
                    _SLOT.kiosk_get_product_stock();
                    if (first_run) _SLOT.get_kiosk_status();
        //            _SLOT.start_get_topup_readiness();
                    press = "0";
                    resetMediaTimer();
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
                    preload_whatasapp_voucher.close()
                    my_layer.push(global_input_number, {mode: 'WA_VOUCHER'});

                }
            }
        }

    }

}
