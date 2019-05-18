import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0


Base{
    id: base_page
    property var press: "0"
    property int tvc_timeout: 60
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
    property bool mandiriAvailable: false
    isPanelActive: false

    Stack.onStatusChanged:{
        if(Stack.status == Stack.Activating){
            _SLOT.get_kiosk_status();
            _SLOT.start_idle_mode();
            _SLOT.kiosk_get_product_stock();
            press = "0";
            resetMediaTimer();
            kalogButton = false;
            productCount1 = 0;
            productCount2 = 0;
            productCount3 = 0;
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
    }

    function resetMediaTimer(){
        if(isMedia){
            tvc_loading.counter = tvc_timeout;
            show_tvc_loading.start();
        }
    }

    function ka_login_status(t){
        console.log('ka_login_status', t);
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
        console.log('topup_readiness', t);
        if (t=='TOPUP_READY|ERROR'){
            kalog_notif();
            return;
        }
        var tr = JSON.parse(t);
        mandiriTopupWallet = parseInt(tr.balance_mandiri);
        bniTopupWallet = parseInt(tr.balance_bni);
        if (tr.mandiri == 'AVAILABLE') {
            mandiriTopupActive = true;
            if (mandiriTopupWallet > 0) mandiriAvailable = true;
        }
        if (tr.bni == 'AVAILABLE') bniTopupActive = true;
    }

    function get_product_stock(p){
        console.log('product_stock', p);
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
        productCountAll = productCount1 + productCount2 + productCount3
        console.log('product stock count : ', productCount1, productCount2, productCount3, productCountAll);
    }

    function get_kiosk_status(r){
        console.log("get_kiosk_status : ", JSON.stringify(r));
        var kiosk = JSON.parse(r);
        base.globalBoxName = kiosk.name;
        box_version.text = kiosk.version;
        box_tid.text = kiosk.tid;
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
        console.log("handle_general : ", result);
        if (result=='') return;
        if (result=='REBOOT'){
            switch_frame('aAsset/loading_static.png', 'Mohon Tunggu Mesin Akan Dimuat Ulang', 'Dalam 30 Detik', 'closeWindow', false )
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
        switch_frame('aAsset/smiley_down.png', 'Maaf Sementara Mesin Tidak Dapat Digunakan', '', 'backToMain', false )
        return;
//        standard_notif_view.z = 100;
//        standard_notif_view._button_text = 'tutup';
//        if (param==undefined){
//            standard_notif_view.show_text = "Mohon Maaf";
//            standard_notif_view.show_detail = "Terjadi Kesalahan Pada Sistem, Mohon Coba Lagi Beberapa Saat";
//        } else {
//            standard_notif_view.show_text = param.split('|')[0];
//            standard_notif_view.show_detail = param.split('|')[1];
//        }
//        standard_notif_view.open();
    }

    function kalog_notif(param){
        press = '0';
        switch_frame('aAsset/smiley_down.png', 'Maaf Sementara Mesin Tidak Dapat Untuk', 'Melakukan Pengisian Kartu', 'closeWindow', false )
        return;
//        kalogin_notif_view.z = 100;
//        kalogin_notif_view._button_text = 'login';
//        if (param==undefined){
//            kalogin_notif_view.show_text = "Dear Admin";
//            kalogin_notif_view.show_detail = "Silakan Tempelkan Kartu Login Terlebih Dahulu Untuk Aktivasi Fitur Topup";
//        } else {
//            kalogin_notif_view.show_text = param.split('|')[0];
//            kalogin_notif_view.show_detail = param.split('|')[1];
//        }
//        kalogin_notif_view.open();
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
        show_text: 'Selamat Datang di Mandiri e-Money Terminal'
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
            img_: "aAsset/cek_saldo.png"
            text_: qsTr("Cek Saldo")
            text2_: qsTr("Balance Check")
            modeReverse: false
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press "Cek Saldo"');
                    resetMediaTimer();
                    if (press!="0") return;
                    press = "1";
                    my_layer.push(check_balance, {mandiriAvailable: mandiriAvailable});
                    _SLOT.stop_idle_mode();
                    show_tvc_loading.stop();
                }
            }
        }

        MasterButtonNew {
            id: topup_saldo_button
            x: 150
            anchors.verticalCenter: parent.verticalCenter
            img_: "aAsset/topup_kartu.png"
            text_: qsTr("Topup Saldo")
            text2_: qsTr("Topup Balance")
            modeReverse: false
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press "TopUp Saldo"');
                    resetMediaTimer();
                    if (!mandiriAvailable) {
                        kalog_notif();
                        return;
                    }
                    if (press!="0") return;
                    press = "1";
                    my_layer.push(topup_prepaid_denom);
                    _SLOT.stop_idle_mode();
                    show_tvc_loading.stop();
                }
            }
        }

        MasterButtonNew {
            id: buy_saldo_button
            x: 150
            anchors.verticalCenter: parent.verticalCenter
            img_: "aAsset/beli_kartu.png"
            text_: qsTr("Beli Kartu")
            text2_: qsTr("Buy Card")
            modeReverse: false
            color_: (productCountAll > 0) ? 'white' : 'gray'
            opacity: 1
            MouseArea{
                enabled: (productCountAll > 0) ? true : false
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press "Beli Kartu"');
                    resetMediaTimer();
                    if (press!="0") return;
                    press = "1";
                    my_layer.push(mandiri_shop_card, {productData: productData, shop_type: 'shop', productCount: productCountAll});
//                    _SLOT.set_tvc_player("STOP");
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
                if(tvc_loading.counter == 0){
                    console.log("starting tvc player...");
                    if (!mediaOnPlaying) my_layer.push(media_page, {mode: 'mediaPlayer'});
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
        anchors.topMargin: 150
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
            source: 'aAsset/adult-male.png'
            fillMode: Image.PreserveAspectFit
        }

        MouseArea{
            anchors.fill: parent
            onDoubleClicked: {
                _SLOT.user_action_log('Press "Admin" Button');
                console.log('Admin Button is Pressed..!');
                _SLOT.stop_idle_mode();
                my_layer.push(admin_login);
            }
        }
    }

    Rectangle{
        id: machine_status_rec
        color: "#ffffff"
        anchors.right: parent.right
        anchors.rightMargin: 250
        opacity: 0.75
        border.width: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        width: 265
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
                source: 'aAsset/icon/kiosk.png'
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
                source: 'aAsset/icons-cards-2.png'
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
                source: 'aAsset/icons-cards-2.png'
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
                source: 'aAsset/icons-cards-2.png'
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

    NotifView{
        id: notif_view
        isSuccess: false
        z: 99
    }

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

}
