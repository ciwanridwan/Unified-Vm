import QtQuick 2.4
import QtQuick.Controls 1.2

Base{
    id: base_page
    property var press: "0"
    property var gui_version: ""
    property int tvc_timeout: 60
    property bool isMedia: true
    property bool kioskStatus: false
    property bool withSlider: true
    property var productData: undefined
    property var productCount: 0
    property var mandiriTopupWallet: 0
    property var bniTopupWallet: 0
    property bool kalogButton: false
    property var mandiriLogin: false
//    withSlider: true


    Stack.onStatusChanged:{
        if(Stack.status == Stack.Activating){
            _SLOT.get_kiosk_status();
            _SLOT.start_idle_mode();
            _SLOT.kiosk_get_product_stock();
            press = "0";
            if(isMedia){
                tvc_loading.counter = tvc_timeout;
                show_tvc_loading.start();
            }
            kalogButton = false;
        }
        if(Stack.status==Stack.Deactivating){
            loading_view.close();
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
        base.result_get_gui_version.disconnect(get_gui_version);
        base.result_product_stock.connect(get_product_stock);
        base.result_generate_pdf.disconnect(get_pdf);
        base.result_general.disconnect(handle_general);
        base.result_kiosk_status.disconnect(get_kiosk_status);
        base.result_topup_readiness.disconnect(topup_readiness);
        base.result_auth_qprox.disconnect(ka_login_status);
    }


    function ka_login_status(t){
        console.log('ka_login_status', t);
        popup_loading.close()
        var result = t.split('|')[1]
        if (result == 'ERROR'){
            kalog_notif()
            kalogButton = false
        } else if (result == 'SUCCESS'){
            kalog_notif('Selamat|Login KA Mandiri Berhasil');
            kalogin_notif_view._button_text = 'tutup';
            kalogButton = false;
        } else {
            kalog_notif('Mohon Maaf|Login KA Mandiri Gagal, Kode Error ['+result+'], Silakan Coba Lagi')
            kalogButton = true
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
        var mandiri_login = tr.mandiri
        if (!mandiriLogin){
            if (mandiri_login != 'AVAILABLE'){
                kalog_notif('Dear Admin|Mohon Tempelkan Kartu Login KA Mandiri');
                kalogButton = true;
            } else {
                mandiriLogin = true;
                kalogButton = false;
            }
        }
    }

    function get_product_stock(p){
        console.log('product_stock', p);
        productData = JSON.parse(p);
        productCount = parseInt(productData[0].stock);
        console.log('product_count', productCount);
    }

    function get_kiosk_status(r){
        console.log("get_kiosk_status : ", JSON.stringify(r));
        var kiosk = JSON.parse(r);
        box_name.text = kiosk.name
        box_version.text = kiosk.version
        if (kiosk.status == "ONLINE" || kiosk.status == "AVAILABLE") {
            kioskStatus = true;
            box_connection.text = 'ONLINE';
            box_connection.color = 'green'
        } else {
            box_connection.text = 'OFFLINE';
            box_connection.color = 'red'
            kioskStatus = false;
            not_authorized();
        }
        _SLOT.start_get_mandiri_login();
    }

    function not_authorized(){
        press = '0';
        loading_view.close()
        false_notif('Mohon Maaf|Mesin Tidak Dapat Digunakan, Silakan Periksa Koneksi Internet');
    }

    function handle_general(result){
        console.log("handle_general : ", result)
        if (result=='') return
        if (result=='REBOOT'){
            loading_view.close()
            notif_view.z = 99
            notif_view.isSuccess = false
            notif_view.closeButton = false
            notif_view.show_text = qsTr("Dear User")
            notif_view.show_detail = qsTr("This Kiosk Machine will be rebooted in 30 seconds.")
            notif_view.open()
        }
    }


    function get_pdf(pdf){
        console.log("get_pdf : ", pdf)
    }

    function get_gui_version(result){
        console.log("GUI VERSION : ", result)
        gui_version = result
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

    function kalog_notif(param){
        press = '0';
        kalogin_notif_view.z = 100;
        kalogin_notif_view._button_text = 'login';
        if (param==undefined){
            kalogin_notif_view.show_text = "Mohon Maaf";
            kalogin_notif_view.show_detail = "Terjadi Kesalahan Pada Saat Login Kartu KA Mandiri, Mohon Coba Lagi";
        } else {
            kalogin_notif_view.show_text = param.split('|')[0];
            kalogin_notif_view.show_detail = param.split('|')[1];
        }
        kalogin_notif_view.open();
    }

    Rectangle{
        id: opacity_slider
        x: 0; y:base_page.header_heigth;
        color: "firebrick"
        visible: withSlider
    }

    LoadingViewNew{
        id: slider
        x: 0; y:base_page.header_heigth;
        visible: withSlider
        show_caption: false
        opacity: .5
    }


    Row{
        id: row_button
        anchors.verticalCenterOffset: 125
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 60
        anchors.verticalCenter: parent.verticalCenter
        visible: (!standard_notif_view.visible && !kalogin_notif_view.visible && !popup_loading.visible) ? true : false;

        MasterButtonNew {
            id: check_saldo_button
            x: 150
            anchors.verticalCenter: parent.verticalCenter
            img_: "aAsset/cek_saldo.png"
            text_: qsTr("Cek Saldo")
            text2_: qsTr("Balance Check")
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    if (kioskStatus===true){
                        if (press!="0") return
                        press = "1"
                        my_layer.push(check_balance)
                        _SLOT.set_tvc_player("STOP")
                        _SLOT.stop_idle_mode()
                        show_tvc_loading.stop()
                    } else {
                        not_authorized();
                    }
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
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    if (kioskStatus===true){
                        if (press!="0") return
                        press = "1"
                        my_layer.push(select_prepaid_provider)
                        _SLOT.set_tvc_player("STOP")
                        _SLOT.stop_idle_mode()
                        show_tvc_loading.stop()
                    } else {
                        not_authorized();
                    }
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
            color_: (productCount > 0) ? 'black' : 'gray'
            opacity: 1
            MouseArea{
                enabled: (productCount > 0) ? true : false
                anchors.fill: parent
                onClicked: {
                    if (kioskStatus===true){
                        if (press!="0") return
                        press = "1"
                        my_layer.push(shop_prepaid_card, {productData: productData, shop_type: 'shop', productCount: productCount})
                        _SLOT.set_tvc_player("STOP")
                        _SLOT.stop_idle_mode()
                        show_tvc_loading.stop()
                    } else {
                        not_authorized();
                    }
                }
            }
            Rectangle{
                id: oos_overlay
                width: 280
                height: 50
                color: "#ffffff"
                anchors.verticalCenterOffset: 100
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                opacity: 0.8
                visible: (productCount > 0) ? false : true
                Text {
                    id: text_oos
                    text: qsTr("HABIS")
                    anchors.fill: parent
                    font.pixelSize: 20
                    color: 'darkred'
                    font.bold: true
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
                    console.log("starting tvc player...")
                    _SLOT.set_tvc_player("START")
                    tvc_loading.counter = tvc_timeout
                    show_tvc_loading.restart()
                }
            }
        }
    }

    Rectangle{
        id: machine_status_rec
        color: "#ffffff"
        opacity: 0.75
        border.width: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        width: 280
        height: 30
        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.top: parent.top
            spacing: 10
            Text{
                id: box_name
                height: parent.height
                verticalAlignment: Text.AlignVCenter
            }
            Text{
                id: box_version
                height: parent.height
                verticalAlignment: Text.AlignVCenter

            }
            Text{
                id: box_connection
                font.bold: true
                height: parent.height
                verticalAlignment: Text.AlignVCenter

            }
        }

    }

    Rectangle{
        id: product_stock_status
        color: "#fff000"
        opacity: 0.75
        border.width: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: machine_status_rec.width
        width: 80
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
                text: productCount
                font.bold: true
                color: 'blue'
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

//    Rectangle{
//        id: mandiri_topup_status
//        color: "blue"
//        opacity: 0.75
//        border.width: 0
//        anchors.bottom: parent.bottom
//        anchors.bottomMargin: 0
//        anchors.left: parent.left
//        anchors.leftMargin: product_stock_status.width
//        width: 80
//        height: 30
//        Row{
//            anchors.horizontalCenter: parent.horizontalCenter
//            anchors.verticalCenter: parent.verticalCenter
//            anchors.top: parent.top
//            spacing: 10
//            Image{
//                id: img_mandiri
//                height: parent.height
//                source: 'aAsset/icons-coins.png'
//                fillMode: Image.PreserveAspectFit
//                scale: .8
//                verticalAlignment: Text.AlignVCenter
//            }
//            Text{
//                id: mandiri_topup_wallet
//                height: parent.height
//                text: mandiriTopupWallet
//                font.bold: true
//                color: 'white'
//                verticalAlignment: Text.AlignVCenter
//            }
//        }
//    }

//    Rectangle{
//        id: bni_topup_status
//        color: "orange"
//        opacity: 0.75
//        border.width: 0
//        anchors.bottom: parent.bottom
//        anchors.bottomMargin: 0
//        anchors.left: parent.left
//        anchors.leftMargin: mandiri_topup_status.width
//        width: 80
//        height: 30
//        Row{
//            anchors.horizontalCenter: parent.horizontalCenter
//            anchors.verticalCenter: parent.verticalCenter
//            anchors.top: parent.top
//            spacing: 10
//            Image{
//                id: img_bni
//                height: parent.height
//                source: 'aAsset/icons-coins.png'
//                fillMode: Image.PreserveAspectFit
//                scale: .8
//                verticalAlignment: Text.AlignVCenter
//            }
//            Text{
//                id: bni_topup_wallet
//                height: parent.height
//                text: bniTopupWallet
//                font.bold: true
//                color: 'white'
//                verticalAlignment: Text.AlignVCenter
//            }
//        }
//    }


    LoadingView{
        id:loading_view
        z: 99
        show_text: qsTr("Preparing...")
    }

    NotifView{
        id: notif_view
        isSuccess: false
        z: 99
    }

    StandardNotifView{
        id: standard_notif_view
        withBackground: false
        modeReverse: true
        show_text: "Dear Customer"
        show_detail: "Please Ensure You have set Your plan correctly."
        z: 99
    }

    StandardNotifView{
        id: kalogin_notif_view
//        visible: true
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

}
