import QtQuick 2.4
import QtQuick.Controls 1.3
import QtGraphicalEffects 1.0
import "base_function.js" as FUNC

Base{
    id: mandiri_shop_card
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

    property variant availItems: []

    property string cancelText: 'BATAL'
    property string proceedText: 'LANJUT'
    property bool frameWithButton: false
    property var modeButtonPopup: 'check_balance';

    property var defaultItemPrice: 50000
    property int boxSize: 80

    property bool mainVisible: false

    idx_bg: 2
    imgPanel: 'source/beli_kartu.png'
    textPanel: 'Pembelian Kartu Prabayar'
    signal get_payment_method_signal(string str)

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            console.log('shop_type', shop_type);
            preload_shop_card.open();
            cdReadiness = undefined;
            _SLOT.kiosk_get_cd_readiness();
            _SLOT.start_get_device_status();
            _SLOT.start_get_multiple_eject_status();
            if (cart != undefined) {
                console.log('cart', JSON.stringify(cart));
                adminFee = cart.admin_fee;
//                _provider.labelContent = cart.provider;
//                _nominal.labelContent =  'Rp. ' + FUNC.insert_dot(cart.value) + ',-';
//                _biaya_admin.labelContent =  'Rp. ' + FUNC.insert_dot(cart.admin_fee) + ',-';
//                small_notif.text = '*Biaya Admin sebesar Rp. 1.500,- Dikenakan Untuk Tiap Transaksi Isi Ulang.';
//                small_notif.visible = true;
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
            availItems = [];
        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop();
//            loading_view.close()
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
//            parseDataProduct(productData);
            defineProductIndex(productData);
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
        my_layer.push(mandiri_payment_process, {details: get_details});
    }

    function get_status_multiple(m){
        console.log('get_status_multiple', m);
        if (m == 'AVAILABLE'){
            multipleEject = true;
//            small_notif.text = "*Silakan Tentukan Jumlah Kartu Yang Akan Dibeli.";
        } else {
//            small_notif.text = "*Saat Ini Anda Hanya Dapat Membeli 1 (satu) Kartu Tiap Sesi.";
        }
//        small_notif.visible = true;
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

    function defineProductIndex(products){
        var items = products;
        for(var x in items) {
            var item_stock = items[x].stock;
            var item_status = items[x].status;
            var item_price = items[x].sell_price;
            if (cdReadiness != undefined){
                if (item_status==101 && cdReadiness.port1 == 'N/A') item_stock = '0';
                if (item_status==102 && cdReadiness.port2 == 'N/A') item_stock = '0';
                if (item_status==103 && cdReadiness.port3 == 'N/A') item_stock = '0';
            }
            if (parseInt(item_stock) > 0) availItems.push({index: x, stock: parseInt(item_stock), price: parseInt(item_price)});
        }

        if (availItems.length == 0){
            switch_frame('source/smiley_down.png', 'Maaf Sementara Mesin Tidak Dapat Untuk', 'Melakukan Pembelian Kartu', 'backToMain', false )
            return;
        }

        var max = availItems.reduce(function (prev, current) {
           return (prev.stock > current.stock) ? prev : current
        });
//        productIdx = parseInt(max);
        productIdx = availItems.indexOf(max);
        defaultItemPrice = availItems[productIdx].price;
        console.log('defined_index', JSON.stringify(max), productIdx, defaultItemPrice);
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
        visible: !popup_loading.visible && !global_frame.visible
        modeReverse: true
        MouseArea{
            anchors.fill: parent
            onClicked: {
                my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
            }
        }
    }

    CircleButton{
        id: next_button
        anchors.right: parent.right
        anchors.rightMargin: 50
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        button_text: 'LANJUT'
        visible: !popup_loading.visible && !global_frame.visible
        modeReverse: true
        MouseArea{
            anchors.fill: parent
            onClicked: {
                _SLOT.user_action_log('Press "LANJUT"');
                if (press!='0') return;
                press = '1';
                var globalDetails = get_cart_details('cash');
                my_layer.push(mandiri_payment_process, {details: globalDetails});
            }
        }
    }



    //==============================================================
    //PUT MAIN COMPONENT HERE

    function open_preload_notif(){
        press = '0';
        switch_frame('source/insert_money.png', 'Masukkan Uang Anda', '', 'closeWindow', false )
        return;
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

    function get_cart_details(channel){
        var details = {
            payment: channel,
            shop_type: shop_type,
            time: new Date().toLocaleTimeString(Qt.locale("id_ID"), "hh:mm:ss"),
            date: new Date().toLocaleDateString(Qt.locale("id_ID"), Locale.ShortFormat),
            epoch: new Date().getTime()
        }
        details.qty = itemCount;
        details.value = productData[productIdx].sell_price.toString();
        details.provider = productData[productIdx].name;
        details.admin_fee = '0';
        details.status = productData[productIdx].status;
        details.raw = productData[productIdx];
        return details;
    }

    function reset_button_color(){
        count1.modeReverse = true;
        count2.modeReverse = true;
        count3.modeReverse = true;
        count4.modeReverse = true;
    }


/*

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

*/


    MainTitle{
        anchors.top: parent.top
        anchors.topMargin: 250
        anchors.horizontalCenter: parent.horizontalCenter
        show_text: 'Pilih Jumlah Pembelian Kartu'
        size_: 50
        color_: "white"
        visible: !global_frame.visible && !popup_loading.visible && mainVisible

    }

    Text {
        id: label_choose_qty
        color: "white"
        text: "Pilih jumlah kartu"
        anchors.top: parent.top
        anchors.topMargin: 400
        anchors.left: parent.left
        anchors.leftMargin: 250
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.family:"Ubuntu"
        font.pixelSize: 45
        visible: !global_frame.visible && !popup_loading.visible && mainVisible
    }

    Row{
        id: button_item
        width: 500
        height: 100
        anchors.top: parent.top
        anchors.topMargin: 475
        anchors.left: parent.left
        anchors.leftMargin: 250
        spacing: 20
        visible: !global_frame.visible && !popup_loading.visible && mainVisible

        BoxTitle{
            id: count1
            boxColor: '#1D294D'
            modeReverse: true
            radius: boxSize/2
            width: boxSize
            height: boxSize
            title_text: '1'
            fontBold: true
            fontSize: 40
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    itemCount = 1;
                    reset_button_color();
                    parent.modeReverse = false;
                }
            }
        }

        BoxTitle{
            id: count2
            boxColor: '#1D294D'
            modeReverse: true
            radius: boxSize/2
            width: boxSize
            height: boxSize
            title_text: '2'
            fontBold: true
            fontSize: 40
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    itemCount = 2;
                    reset_button_color();
                    parent.modeReverse = false;
                }
            }
        }

        BoxTitle{
            id: count3
            boxColor: '#1D294D'
            modeReverse: true
            radius: boxSize/2
            width: boxSize
            height: boxSize
            title_text: '3'
            fontBold: true
            fontSize: 40
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    itemCount = 3;
                    reset_button_color();
                    parent.modeReverse = false;
                }
            }
        }

        BoxTitle{
            id: count4
            boxColor: '#1D294D'
            modeReverse: true
            radius: boxSize/2
            width: boxSize
            height: boxSize
            title_text: '4'
            fontBold: true
            fontSize: 40
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    itemCount = 4;
                    reset_button_color();
                    parent.modeReverse = false;
                }
            }
        }

    }

    Text {
        id: label_total_qty
        color: "white"
        text: "Total Kartu"
        anchors.right: parent.right
        anchors.rightMargin: 350
        anchors.top: parent.top
        anchors.topMargin: 400
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.family:"Ubuntu"
        font.pixelSize: 45
        visible: !global_frame.visible && !popup_loading.visible && mainVisible
    }

    Text {
        id: label_total_pay
        color: "white"
        text: "Total Bayar"
        anchors.right: parent.right
        anchors.rightMargin: 350
        anchors.top: parent.top
        anchors.topMargin: 575
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.family:"Ubuntu"
        font.pixelSize: 45
        visible: !global_frame.visible && !popup_loading.visible && mainVisible
    }

    BoxTitle{
        id: content_item_count
        boxColor: '#1D294D'
        modeReverse: true
        anchors.top: parent.top
        anchors.topMargin: 475
        anchors.right: parent.right
        anchors.rightMargin: 500
        radius: boxSize/2
        width: boxSize
        height: boxSize
        title_text: itemCount
        fontBold: true
        fontSize: 40
        visible: !global_frame.visible && !popup_loading.visible && mainVisible

    }

    NextButton{
        id: reset_button
        width: boxSize*2
        height: boxSize
        radius: 20
        anchors.right: parent.right
        anchors.rightMargin: 300
        anchors.top: parent.top
        anchors.topMargin: 475
        button_text: 'RESET'
        modeReverse: true
        visible: !global_frame.visible && !popup_loading.visible && mainVisible
        MouseArea{
            anchors.fill: parent
            onClicked: {
                reset_button_color();
                itemCount = 1;
                count1.modeReverse = false;
            }
        }
    }

    Text {
        id: content_total_pay
        color: "white"
        text: 'Rp ' + FUNC.insert_dot((itemCount * defaultItemPrice).toString())
        anchors.right: parent.right
        anchors.rightMargin: 350
        anchors.top: parent.top
        anchors.topMargin: 650
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.family:"Ubuntu"
        font.pixelSize: 50
        visible: !global_frame.visible && !popup_loading.visible && mainVisible
    }

    //==============================================================


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

    GlobalFrame{
        id: global_frame
        NextButton{
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

        NextButton{
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
                    default:
                        break;
                    }
                    popup_loading.open();
                }
            }
        }
    }

    PreloadShopCard{
        id: preload_shop_card
        NextButton{
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

        NextButton{
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
                    mainVisible = true;
                    preload_shop_card.close();
                }
            }
        }
    }






}

