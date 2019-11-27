import QtQuick 2.4
import QtQuick.Controls 1.3
import QtGraphicalEffects 1.0
import "base_function.js" as FUNC

Base{
    id: shop_prepaid_card
    property int timer_value: 300
    property var press: '0'
    property var cart: undefined
    property var shop_type: 'shop' // 'shop', 'topup'
    property var productData: undefined
    property var productCount: 0
    property var itemCount: 1
    property var itemMax: 10
    property var itemPrice: 0
    property var totalFee: 0
    property var adminFee: 1500
    property bool isConfirm: false
    property bool multipleEject: false
    property int productIdx: -1
    property bool cashEnable: false
    property bool debitEnable: false
    property var cdReadiness: undefined
    idx_bg: 2
    imgPanel: 'source/beli_kartu.png'
    textPanel: 'Pembelian Kartu Prabayar'
    signal get_payment_method_signal(string str)

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            console.log('shop_type', shop_type);
            popup_loading.open();
            cdReadiness = undefined;
            _SLOT.kiosk_get_cd_readiness();
            _SLOT.start_get_device_status();
            _SLOT.start_get_multiple_eject_status();
            if (cart != undefined) {
                console.log('cart', JSON.stringify(cart));
                adminFee = cart.admin_fee;
                _provider.labelContent = cart.provider;
                _nominal.labelContent =  'Rp. ' + FUNC.insert_dot(cart.value) + ',-';
                _biaya_admin.labelContent =  'Rp. ' + FUNC.insert_dot(cart.admin_fee) + ',-';
                small_notif.text = '*Biaya Admin sebesar Rp. 1.500,- Dikenakan Untuk Tiap Transaksi Isi Ulang.';
                small_notif.visible = true;
            }
//            if (productData != undefined) {
//                console.log('productData', JSON.stringify(productData));
//                parseDataProduct(productData);
//            }
            abc.counter = timer_value;
            my_timer.start();
            press = '0';
            productIdx = -1;
            isConfirm = false;

        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
            loading_view.close()
        }
    }

    Component.onCompleted:{
        get_payment_method_signal.connect(process_selected_payment);
        base.result_get_device.connect(get_device_status);
        base.result_balance_qprox.connect(get_balance);
        base.result_multiple_eject.connect(get_status_multiple);
        base.result_cd_readiness.connect(get_cd_readiness);
    }

    Component.onDestruction:{
        get_payment_method_signal.disconnect(process_selected_payment);
        base.result_get_device.disconnect(get_device_status);
        base.result_balance_qprox.disconnect(get_balance);
        base.result_multiple_eject.disconnect(get_status_multiple);
        base.result_cd_readiness.disconnect(get_cd_readiness);
    }


    function get_cd_readiness(c){
        console.log('get_cd_readiness', c);
        cdReadiness = JSON.parse(c);
        if (productData != undefined) {
            console.log('productData', JSON.stringify(productData));
            parseDataProduct(productData);
        }
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

    function process_selected_payment(p){
        console.log('process_selected_payment', p);
        var get_details = get_cart_details(p);
        my_layer.push(process_shop, {details: get_details});
    }

    function get_status_multiple(m){
        console.log('get_status_multiple', m);
        if (m == 'AVAILABLE'){
            multipleEject = true;
            small_notif.text = "*Silakan Tentukan Jumlah Kartu Yang Akan Dibeli.";
        } else {
            small_notif.text = "*Saat Ini Anda Hanya Dapat Membeli 1 (satu) Kartu Tiap Sesi.";
        }
        small_notif.visible = true;
    }

    function get_balance(text){
        console.log('get_balance', text);
    }

    function get_wording(i){
        if (i=='shop') return 'Pembelian Kartu';
        if (i=='topup') return 'TopUp Kartu';
    }

    function adjust_count(t){
        if (t == 'plus'){
            if (itemCount == productData[productIdx].stock) return;
            if (itemCount == itemMax) return;
            itemCount++;
        }
        if (t == 'minus'){
            if (itemCount == 1) return;
            itemCount--;
        }
    }

    function parseDataProduct(products){
        //Undefined the gridview model
        gridview.model = undefined;
        var items = products;
        if(!groceryItem_listModel.count){
            for(var x in items) {
                var item_name = items[x].name;
                var item_price = items[x].sell_price;
                var item_stock = items[x].stock;
                var item_desc = items[x].remarks;
                var item_status = items[x].status;
                var item_image = items[x].image;
                var item_id = items[x].pid;
                if (cdReadiness != undefined){
                    if (item_status==101 && cdReadiness.port1 == 'N/A') item_stock = '0';
                    if (item_status==102 && cdReadiness.port2 == 'N/A') item_stock = '0';
                    if (item_status==103 && cdReadiness.port3 == 'N/A') item_stock = '0';
                }
                if (item_image=='') item_image = 'source/bni_tapcash_card.png';
                groceryItem_listModel.append({
                                                 _item_index: x,
                                                 _item_name: item_name,
                                                 _item_price: item_price.toString(),
                                                 _item_stock: parseInt(item_stock),
                                                 _item_desc: item_desc,
                                                 _item_status: item_status,
                                                 _item_image: item_image,
                                                 _item_id: item_id,
                                             });
            }
            gridview.model = groceryItem_listModel;
            popup_loading.close();
        }
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

    function get_cart_details(channel){
        var details = {
            payment: channel,
            shop_type: shop_type,
            time: new Date().toLocaleTimeString(Qt.locale("id_ID"), "hh:mm:ss"),
            date: new Date().toLocaleDateString(Qt.locale("id_ID"), Locale.ShortFormat),
            epoch: new Date().getTime()
        }
        switch(shop_type){
            case 'shop':
                details.qty = itemCount;
                details.value = productData[productIdx].sell_price.toString();
                details.provider = productData[productIdx].name;
                details.admin_fee = '0';
                details.status = productData[productIdx].status;
                details.raw = productData[productIdx];
                  return details;
            case 'topup':
                details.qty = 1;
                details.value = cart.value;
                details.provider = cart.provider;
                details.admin_fee = cart.admin_fee;
                details.status = '1';
                details.raw = cart;
                return details;
        }
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
        visible: !standard_notif_view.visible && !popup_loading.visible
        anchors.top: parent.top
        anchors.topMargin: 150
        anchors.horizontalCenterOffset: 150
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: "white"
        wrapMode: Text.WordWrap
        text: "Pilih Kartu Prabayar";
        font.bold: false
        font.family: "Ubuntu"
        font.pixelSize: 45
    }


    Item{
        id: prod_item_view
        visible: (shop_type=='shop') ? true : false
        width: 1100
        height: 450
        anchors.verticalCenterOffset: -100
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenterOffset: 150
        anchors.horizontalCenter: parent.horizontalCenter
        focus: true

        ListView{
            id: gridview
            spacing: 0
            orientation: ListView.Horizontal
            flickableDirection: Flickable.HorizontalFlick
            focus: true
            clip: true
            anchors.bottomMargin: 0
            anchors.topMargin: 0
            flickDeceleration: 750
            maximumFlickVelocity: 1500
            anchors.centerIn: parent
            layoutDirection: Qt.LeftToRight
            boundsBehavior: Flickable.StopAtBounds
            snapMode: GridView.SnapToRow
            anchors.fill: parent
            anchors.margins: 20
            delegate: delegate_item_view
            //model: groceryItem_listModel -> Defined on function below
        }

        ListModel {
            id: groceryItem_listModel
            dynamicRoles: true
        }

        Component{
            id: delegate_item_view
            PrepaidProductItemLite{
                id: item_product_view
                itemName: _item_name
                itemImage: _item_image
                itemPrice: _item_price
                itemStock: _item_stock
                itemDesc: _item_desc
                MouseArea{
                    anchors.fill: parent
                    enabled: (_item_stock > 0) ? true : false
                    onClicked: {
                        productIdx = _item_index;
                        _prod_name.labelContent = _item_name;
                        _prod_desc.labelContent = _item_desc;
                        _prod_price.labelContent = 'Rp. ' + FUNC.insert_dot(_item_price) + ',-';
                    }
                }
            }
        }
    }

    Rectangle{
        id: base_selected_product
        width: 920
        height: 180
        visible: (productIdx>-1) ? true : false;
        color: 'white'
        anchors.horizontalCenterOffset: 150
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 225
        opacity: .8
        radius: 30
        Column{
            id: row_texts;
            anchors.topMargin: 10
            anchors.fill: parent
            spacing: 25;
            TextDetailRow{
                id: _prod_name
                labelName: qsTr('Nama Produk')
                contentSize: 25
                labelSize: 25
                theme: '#1D294D'
            }
            TextDetailRow{
                id: _prod_desc
                labelName: qsTr('Deskripsi')
                contentSize: 25
                labelSize: 25
                theme: '#1D294D'
            }
            TextDetailRow{
                id: _prod_price
                labelName: qsTr('Harga Produk')
                contentSize: 25
                labelSize: 25
                theme: '#1D294D'
            }
        }
    }


    NextButton{
        id: confirm_button
        anchors.horizontalCenterOffset: 150
        visible: !standard_notif_view.visible && !popup_loading.visible
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        anchors.horizontalCenter: parent.horizontalCenter
        button_text: 'lanjut'
        modeReverse: true
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if (productIdx == -1) return;
                if (cashEnable && debitEnable){
                    isConfirm = true;
                } else if (cashEnable && !debitEnable){
                    process_selected_payment('cash');
                } else if (!cashEnable && debitEnable){
                    process_selected_payment('debit');
                } else if (!cashEnable && !debitEnable){
                    false_notif('Mohon Maaf|Tidak Terdapat Metode Pembayaran Yang Aktif.');
                    return;
                }
            }
        }
    }


    Text {
        id: small_notif
        x: 0
        color: "white"
        visible: false;
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        wrapMode: Text.WordWrap
        font.italic: true
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenterOffset: 150
        font.family:"Ubuntu"
        font.pixelSize: 20
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

    SelectPaymentPopupNotif{
        id: select_payment
        visible: isConfirm
        calledFrom: 'shop_prepaid_card'

    }

    PopupLoading{
        id: popup_loading
    }




}

