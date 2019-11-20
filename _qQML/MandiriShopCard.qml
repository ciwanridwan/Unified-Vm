import QtQuick 2.4
import QtQuick.Controls 1.3
import QtGraphicalEffects 1.0
import "base_function.js" as FUNC

Base{
    id: mandiri_shop_card
    property int timer_value: 300
    property var press: '0'
    property var cart: undefined
    property var shop_type: 'shop' // 'shop', 'topup', 'ppob'
    property var productData: undefined
    property var productCount: 0
    property var itemCount: 1
    property var itemMax: 10
    property var itemPrice: 0
    property var totalFee: 0
    property var adminFee: 1500
    property bool isConfirm: false
    property bool multipleEject: true
    property int productIdx: -1
    property bool cashEnable: false
    property bool cardEnable: false
    property bool qrOvoEnable: false
    property bool qrDanaEnable: false
    property bool qrGopayEnable: false
    property bool qrLinkajaEnable: false
    property var cdReadiness: undefined
    property var totalPaymentEnable: 0

    property variant availItems: []

    property bool frameWithButton: false
    property var modeButtonPopup: 'check_balance';

    property var defaultItemPrice: 50000
    property int boxSize: 80

    property bool mainVisible: false

    idx_bg: 0
    imgPanel: 'source/beli_kartu.png'
    textPanel: 'Pembelian Kartu Prabayar'

    signal get_payment_method_signal(string str)
    signal set_confirmation(string str)


    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            console.log('shop_type', shop_type);
//            preload_shop_card.open();
            mainVisible = true;
            cdReadiness = undefined;
            _SLOT.kiosk_get_cd_readiness();
            _SLOT.start_get_device_status();
//            _SLOT.start_get_multiple_eject_status();
            if (cart != undefined) {
                console.log('cart', JSON.stringify(cart));
                adminFee = cart.admin_fee;
//                _provider.labelContent = cart.provider;
//                _nominal.labelContent =  'Rp. ' + FUNC.insert_dot(cart.value) + ',-';
//                _biaya_admin.labelContent =  'Rp. ' + FUNC.insert_dot(cart.admin_fee) + ',-';
//                small_notif.text = '*Biaya Admin sebesar Rp. 1.500,- Dikenakan Untuk Tiap Transaksi Isi Ulang.';
//                small_notif.visible = true;
            }
            if (productData != undefined) {
                console.log('productData', JSON.stringify(productData));
                parseDataProduct(productData);
            }
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
        set_confirmation.connect(do_set_confirm);
        get_payment_method_signal.connect(process_selected_payment);
        base.result_get_device.connect(get_device_status);
        base.result_balance_qprox.connect(get_balance);
        base.result_multiple_eject.connect(get_status_multiple);
        base.result_cd_readiness.connect(get_cd_readiness);
    }

    Component.onDestruction:{
        set_confirmation.disconnect(do_set_confirm);
        get_payment_method_signal.disconnect(process_selected_payment);
        base.result_get_device.disconnect(get_device_status);
        base.result_balance_qprox.disconnect(get_balance);
        base.result_multiple_eject.disconnect(get_status_multiple);
        base.result_cd_readiness.disconnect(get_cd_readiness);
    }


    function do_set_confirm(_mode){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('Confirmation Flagged By', _mode, now)
        global_confirmation_frame.no_button();
        popup_loading.close();
        press = '0';
        isConfirm = true;
    }

    function get_cd_readiness(c){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('get_cd_readiness', c, now);
        cdReadiness = JSON.parse(c);
        if (productData != undefined) {
            console.log('productData', JSON.stringify(productData));
//            parseDataProduct(productData);
//            defineProductIndex(productData);
        }
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

    function process_selected_payment(p){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('process_selected_payment', p, now);
        var get_details = get_cart_details(p);
        my_layer.push(mandiri_payment_process, {details: get_details});
    }

    function get_status_multiple(m){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('get_status_multiple', m, now);
        if (m == 'AVAILABLE'){
            multipleEject = true;
//            small_notif.text = "*Silakan Tentukan Jumlah Kartu Yang Akan Dibeli.";
        } else {
//            small_notif.text = "*Saat Ini Anda Hanya Dapat Membeli 1 (satu) Kartu Tiap Sesi.";
        }
//        small_notif.visible = true;
    }

    function get_balance(text){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('get_balance', text, now);
    }

    function get_wording(i){
        if (i=='shop') return 'Pembelian Kartu';
        if (i=='topup') return 'TopUp Kartu';
        if (i=='ppob') return 'Pembayaran/Pembelian Item';
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
        var items = products;
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
            if (item_image=='') item_image = 'source/card/bni_tapcash_card.png';
            if (item_status==101){
                card_show_1.visible = true;
                card_show_1.itemName = item_name;
                card_show_1.itemImage = item_image;
                card_show_1.itemPrice = item_price.toString();
                card_show_1.itemStock = parseInt(item_stock);
            }
            if (item_status==102){
                card_show_2.visible = true;
                card_show_2.itemName = item_name;
                card_show_2.itemImage = item_image;
                card_show_2.itemPrice = item_price.toString();
                card_show_2.itemStock = parseInt(item_stock);
            }
            if (item_status==103){
                card_show_3.visible = true;
                card_show_3.itemName = item_name;
                card_show_3.itemImage = item_image;
                card_show_3.itemPrice = item_price.toString();
                card_show_3.itemStock = parseInt(item_stock);
            }
            if (item_stock!='0') availItems.push(item_id);
        }
//        console.log('avaialable_items', availItems.length);
        popup_loading.close();
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
        visible: !popup_loading.visible && !global_frame.visible && itemCount > 0 && productIdx > -1
        modeReverse: true
        MouseArea{
            anchors.fill: parent
            onClicked: {
                _SLOT.user_action_log('Press "LANJUT"');
                popup_loading.close();
                var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss");
                var unit_price = parseInt(productData[productIdx].sell_price);
                var total_price = itemCount * unit_price;
                var rows = [
                    {label: 'Tanggal', content: now},
                    {label: 'Produk', content: productData[productIdx].name},
                    {label: 'Deskripsi', content: productData[productIdx].remarks},
                    {label: 'Jumlah', content: itemCount.toString()},
                    {label: 'Harga', content: FUNC.insert_dot(unit_price.toString())},
                    {label: 'Total', content: FUNC.insert_dot(total_price.toString())},
                ]
                generateConfirm(rows, true);
            }
        }
    }

    function define_card(idx){
        defaultItemPrice = parseInt(productData[idx].sell_price);
        switch(idx){
        case 0:
            card_show_1.set_select();
            card_show_2.release_select();
            card_show_3.release_select();
            break;
        case 1:
            card_show_1.release_select();
            card_show_2.set_select();
            card_show_3.release_select();
            break;
        case 2:
            card_show_1.release_select();
            card_show_2.release_select();
            card_show_3.set_select();
            break;
        }
    }

    //==============================================================
    //PUT MAIN COMPONENT HERE

    MainTitle{
        anchors.top: parent.top
        anchors.topMargin: 180
        anchors.horizontalCenter: parent.horizontalCenter
        show_text: 'Pilih Jenis Dan Jumlah Kartu Tersedia'
        size_: 50
        color_: "white"
        visible: !global_frame.visible && !popup_loading.visible && mainVisible

    }

    Row{
        id: rec_card_images
//        width: (availItems.length * 420)
        height: 450
        anchors.verticalCenterOffset: -50
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20
        visible: !global_frame.visible && !popup_loading.visible && mainVisible
        PrepaidProductItemLite{
            id: card_show_1
//            visible: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    if (parent.itemStock < 1) return;
                    var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss");
                    productIdx = 0;
                    console.log('select_product_1', productIdx, now);
                    define_card(productIdx);
                }
            }
        }
        PrepaidProductItemLite{
            id: card_show_2
//            visible: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    if (parent.itemStock < 1) return;
                    var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss");
                    productIdx = 1;
                    console.log('select_product_2', productIdx, now);
                    define_card(productIdx);
                }
            }
        }
        PrepaidProductItemLite{
            id: card_show_3
//            visible: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    if (parent.itemStock < 1) return;
                    var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss");
                    productIdx = 2;
                    console.log('select_product_3', productIdx, now);
                    define_card(productIdx);
                }
            }
        }

   }

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
        var unit_price = parseInt(productData[productIdx].sell_price);
        var total_price = itemCount * unit_price;
        details.qty = itemCount;
        details.value = total_price.toString();
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

    function generateConfirm(rows, isConfirm, closeMode, timer){
        if (rows==undefined || rows.length == 0) return;
        if (isConfirm==undefined) isConfirm = false;
        if (closeMode==undefined) closeMode = 'closeWindow';
        if (timer!==undefined){
            global_confirmation_frame.withTimer = true;
            global_confirmation_frame.timerDuration = parseInt(timer);
        }
        global_confirmation_frame.modeConfirm = isConfirm;
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


    Text {
        id: label_choose_qty
        color: "white"
        text: "Pilih jumlah kartu"
        anchors.top: parent.top
        anchors.topMargin: 700
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
        anchors.topMargin: 775
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
                    count1.modeReverse = false;
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
                    count2.modeReverse = false;
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
                    count3.modeReverse = false;
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
                    count4.modeReverse = false;
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
        anchors.topMargin: 700
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.family:"Ubuntu"
        font.pixelSize: 45
        visible: !global_frame.visible && !popup_loading.visible && mainVisible
    }

//    Text {
//        id: label_total_pay
//        color: "white"
//        text: "Total Bayar"
//        anchors.right: parent.right
//        anchors.rightMargin: 350
//        anchors.top: parent.top
//        anchors.topMargin: 875
//        wrapMode: Text.WordWrap
//        verticalAlignment: Text.AlignVCenter
//        horizontalAlignment: Text.AlignLeft
//        font.family:"Ubuntu"
//        font.pixelSize: 45
//        visible: !global_frame.visible && !popup_loading.visible && mainVisible
//    }

    BoxTitle{
        id: content_item_count
        boxColor: '#1D294D'
        modeReverse: true
        anchors.top: parent.top
        anchors.topMargin: 775
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
        anchors.topMargin: 775
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

//    Text {
//        id: content_total_pay
//        color: "white"
//        text: 'Rp ' + FUNC.insert_dot((itemCount * defaultItemPrice).toString())
//        anchors.right: parent.right
//        anchors.rightMargin: 350
//        anchors.top: parent.top
//        anchors.topMargin: 850
//        wrapMode: Text.WordWrap
//        verticalAlignment: Text.AlignVCenter
//        horizontalAlignment: Text.AlignLeft
//        font.family:"Ubuntu"
//        font.pixelSize: 50
//        visible: !global_frame.visible && !popup_loading.visible && mainVisible
//    }

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
        calledFrom: 'mandiri_shop_card'
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
            button_text: 'BATAL'
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
            button_text: 'LANJUT'
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
                    mainVisible = true;
                    preload_shop_card.close();
                }
            }
        }
    }

    GlobalConfirmationFrame{
        id: global_confirmation_frame
        calledFrom: 'mandiri_shop_card'

    }






}

