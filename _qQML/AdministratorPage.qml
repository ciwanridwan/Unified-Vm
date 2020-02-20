import QtQuick 2.4
import QtQuick.Controls 1.3
import "base_function.js" as FUNC

Base{
    id: admin_page
    property var press: '0'
    property int timer_value: 240
    property var userData: undefined
    property var productData: undefined
    property variant actionList: []
    isPanelActive: false
    isHeaderActive: true
    logo_vis: false
    isBoxNameActive: false
    signal update_product_stock(string str)

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            abc.counter = timer_value;
            my_timer.start();
            popup_loading.open();
            _SLOT.kiosk_get_machine_summary();
            _SLOT.kiosk_get_product_stock();
            actionList = []
            if (userData!=undefined) parse_user_data();
        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop();
        }
    }

    Component.onCompleted:{
        update_product_stock.connect(do_action_signal);
        base.result_kiosk_admin_summary.connect(parse_machine_summary);
        base.result_product_stock.connect(get_product_stock);
        base.result_process_settlement.connect(get_admin_action);
        base.result_collect_cash.connect(get_admin_action);
        base.result_change_stock.connect(get_admin_action);
        base.result_admin_print.connect(get_admin_action);
        base.result_init_grg.connect(get_admin_action);
        base.result_activation_bni.connect(get_admin_action);
        base.result_auth_qprox.connect(ka_login_status);
        base.result_mandiri_settlement.connect(get_admin_action);
        base.result_update_app.connect(get_admin_action);
        base.result_process_settlement.connect(get_admin_action);
        base.result_init_online_qprox.connect(get_admin_action);
        base.result_admin_sync_stock.connect(get_admin_action);
        base.result_do_topup_bni.connect(get_topup_bni_result)
    }

    Component.onDestruction:{
        update_product_stock.disconnect(do_action_signal);
        base.result_kiosk_admin_summary.disconnect(parse_machine_summary);
        base.result_product_stock.disconnect(get_product_stock);
        base.result_process_settlement.disconnect(get_admin_action);
        base.result_collect_cash.disconnect(get_admin_action);
        base.result_change_stock.disconnect(get_admin_action);
        base.result_admin_print.disconnect(get_admin_action);
        base.result_init_grg.disconnect(get_admin_action);
        base.result_activation_bni.disconnect(get_admin_action);
        base.result_auth_qprox.disconnect(ka_login_status);
        base.result_mandiri_settlement.disconnect(get_admin_action);
        base.result_update_app.disconnect(get_admin_action);
        base.result_process_settlement.disconnect(get_admin_action);
        base.result_init_online_qprox.disconnect(get_admin_action);
        base.result_admin_sync_stock.disconnect(get_admin_action);
        base.result_do_topup_bni.disconnect(get_topup_bni_result)
    }

    function do_action_signal(s){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('do_action_signal', now, s);
        var action = JSON.parse(s)
        if (action.type=='changeStock'){
            popup_loading.open();
            _SLOT.start_change_product_stock(action.port, action.stock);
            actionList.push(action);
        }
    }

    function ka_login_status(t){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('ka_login_status', now, t);
        popup_loading.close();
        var result = t.split('|')[1]
        if (result == 'ERROR'){
            false_notif('Mohon Maaf|Login KA Mandiri Gagal, Kode Error ['+result+'], Silakan Coba Lagi');
        } else if (result == 'SUCCESS'){
            false_notif('Selamat|Login KA Mandiri Berhasil, Fitur Topup Mandiri Telah Diaktifkan');
        } else {
            false_notif('Mohon Maaf|Login KA Mandiri Gagal, Kode Error ['+result+'], Silakan Coba Lagi');
        }
        press = '0';
        _SLOT.kiosk_get_machine_summary();
        _SLOT.kiosk_get_product_stock();
    }

    function get_topup_bni_result(r){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('get_topup_bni_result', now, r);
        popup_loading.close();
        if (r=='SUCCESS_TOPUP_BNI'){
            false_notif('Dear '+userData.first_name+'|Selamat Proses Topup Deposit BNI Berhasil');
            press = '0';
            _SLOT.kiosk_get_machine_summary();
            _SLOT.kiosk_get_product_stock();
        }
        if (r=='FAILED_UPDATE_BALANCE_BNI'){
            false_notif('Dear '+userData.first_name+'|Gagal Memproses, Silakan Aktivasi Ulang Deposit');
            press = '0';
            _SLOT.kiosk_get_machine_summary();
            _SLOT.kiosk_get_product_stock();
        }
        false_notif('Dear '+userData.first_name+'|Perhatian, Kode Proses:\n'+r);
    }

    function get_admin_action(a){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('get_admin_action', now, a);
        popup_loading.close();
        if (a=='CHANGE_PRODUCT|STID_NOT_FOUND'){
            false_notif('Dear '+userData.first_name+'|Update Stock Gagal, Silakan Hubungi Master Admin Untuk Penambahan Product Di Slot Ini');
        } else if (a=='COLLECT_CASH|DONE'){
            false_notif('Dear '+userData.first_name+'|Pastikan Jumlah Uang Dalam Kaset Sama Dengan Tertera Di Layar');
            _SLOT.start_init_grg();
        } else if (a=='ADMIN_PRINT|DONE'){
            false_notif('Dear '+userData.first_name+'|Ambil Dan Tunjukan Bukti Print Status Mesin Di Bawah Pada Petugas Loket TJ');
        } else if (a=='INIT_GRG|DONE'){
            false_notif('Dear '+userData.first_name+'|Reset Bill Acceptor GRG Selesai, Periksa Kembali Kondisi Aktual Mesin');
        } else if (a=='CHANGE_PRODUCT_STOCK|SUCCESS'){
            false_notif('Dear '+userData.first_name+'|Sedang Memproses Perubahan Stok Pada Peladen Pusat\nSilakan Tunggu Beberapa Saat');
        } else if (a=='REFILL_ZERO|SUCCESS'){
            false_notif('Dear '+userData.first_name+'|Siapkan Kartu Master BNI Dan Segera Tempelkan Pada Reader');
        } else if (a.indexOf('MANDIRI_SETTLEMENT') > -1){
            var r = a.split('|')[1]
            if (r.indexOf('FAILED') > -1){
                false_notif('Dear '+userData.first_name+'|Terjadi Kegagalan Pada Settlement Mandiri!\nKode Error ['+r+']');
            } else if (r=='SUCCESS') {
                false_notif('Dear '+userData.first_name+'|Status Proses Settlement Mandiri...\n['+r+']', true);
            } else {
                false_notif('Dear '+userData.first_name+'|Status Proses Settlement Mandiri...\n['+r+']');
                if (r!='WAITING_RSP_UPDATE') return;
            }
        } else if (a.indexOf('APP_UPDATE') > -1){
            if (a == 'APP_UPDATE|SUCCESS'){
                false_notif('Dear '+userData.first_name+'|Pembaharuan Aplikasi Berhasil, Aplikasi Akan Mencoba Memuat Ulang...');
                _SLOT.user_action_log('Admin Page Notif Button "Reboot By Update"');
                _SLOT.start_safely_shutdown('RESTART');
            } else {
                var u = a.split('|')[1]
                if (a.indexOf('APP_UPDATE|VER.') > -1){
                    false_notif('Dear '+userData.first_name+'|Memproses Pembaharuan Aplikasi!\n\nKode Versi Pembaharuan ['+u+']\n\nAplikasi Akan Memuat Ulang.');
                } else {
                    false_notif('Dear '+userData.first_name+'|Memproses Pembaharuan Aplikasi!\n\nProses Eksekusi ['+u+']\n\nMohon Tunggu Hingga Semua Proses Selesai.');
                }
            }
            return;
        } else if (a.indexOf('EDC_SETTLEMENT') > -1){
            var e = a.split('|')[1]
            if (e=='PROCESSED') {
                false_notif('Dear '+userData.first_name+'|Status Proses EDC Settlement...\n['+e+']', true);
            } else {
                false_notif('Dear '+userData.first_name+'|Status Proses EDC Settlement...\n['+e+']');
            }
        } else if (a.indexOf('SYNC_PRODUCT_STOCK') > -1){
            var s = a.split('|')[1]
            false_notif('Dear '+userData.first_name+'|Status Proses Sync Product Stock..\n['+s+']');

        } else {
            false_notif('Dear '+userData.first_name+'|Perhatian, Kode Proses:\n'+a);
        }
        press = '0';
        _SLOT.kiosk_get_machine_summary();
        _SLOT.kiosk_get_product_stock();
    }

    function get_product_stock(p){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('product_stock', now, p);
        productData = JSON.parse(p);
        if (productData.length > 0) {
            if (productData[0].status==101) _total_stock_101.labelContent = productData[0].stock.toString();
            if (productData[0].status==102) _total_stock_102.labelContent = productData[0].stock.toString();
            if (productData[0].status==103) _total_stock_103.labelContent = productData[0].stock.toString();
        }
        if (productData.length > 1) {
            if (productData[1].status==101) _total_stock_101.labelContent = productData[1].stock.toString();
            if (productData[1].status==102) _total_stock_102.labelContent = productData[1].stock.toString();
            if (productData[1].status==103) _total_stock_103.labelContent = productData[1].stock.toString();
        }
        if (productData.length > 2) {
            if (productData[2].status==101) _total_stock_101.labelContent = productData[2].stock.toString();
            if (productData[2].status==102) _total_stock_102.labelContent = productData[2].stock.toString();
            if (productData[2].status==103) _total_stock_103.labelContent = productData[2].stock.toString();
        }
        popup_loading.close();
    }

    function parse_user_data(){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('parse_user_data', now, JSON.stringify(userData));
        if (userData.isAbleCollect==0){
            false_notif('Selamat Datang '+userData.first_name+'|Akses Akun Anda Terbatas, Jika Anda Memerlukan Perubahan, Silakan Hubungi Master Admin')
        } else {
            if (userData.first_name=='Offline'){
                false_notif('Mode '+userData.first_name+'|Segala Aktifitas Perubahan Data Akan Disinkronisasi Setelah Terhubung Ke Internet')
            } else {
                false_notif('Selamat Datang '+userData.first_name+'|Segala Aktifitas Perubahan Data Berikut Ini Akan Tercatat Di Peladen Pusat')
            }
        }
    }

    function parse_machine_summary(s){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('parse_machine_summary', now, s);
        var info = JSON.parse(s);
        _online_status.labelContent = info.online_status;
        _cpu_temp.labelContent = info.cpu_temp;
        _disk_c.labelContent = info.c_space + ' | '+ info.d_space;
        _service_status.labelContent = info.service_ver;
        _ram_status.labelContent = info.ram_space;
        _theme_status.labelContent = info.theme;
        _version_status.labelContent = info.gui_version;
        _last_sync.labelContent = info.last_sync;
        _edc_error.labelContent = (info.edc_error=='') ? '---' : info.edc_error;
        _nfc_error.labelContent = (info.nfc_error=='') ? '---' : info.nfc_error;
        _bill_error.labelContent = (info.mei_error=='') ? '---' : info.mei_error;
        _scanner_error.labelContent = (info.scanner_error=='') ? '---' : info.scanner_error;
        _webcam_error.labelContent = (info.webcam_error=='') ? '---' : info.webcam_error;
        _cd1_error.labelContent = (info.cd1_error=='') ? '---' : info.cd1_error;
        _cd2_error.labelContent = (info.cd2_error=='') ? '---' : info.cd2_error;
        _cd3_error.labelContent = (info.cd3_error=='') ? '---' : info.cd3_error;
        _today_trx.labelContent = info.today_trx;
        _total_trx.labelContent = info.total_trx;
        _cash_trx.labelContent = info.cash_trx;
        _edc_trx.labelContent = info.edc_trx;
        _mandiri_wallet.labelContent = FUNC.insert_dot(info.mandiri_wallet.toString());
        _mandiri_active_slot.labelContent = info.mandiri_active;
        _bni_wallet.labelContent = FUNC.insert_dot(info.bni_wallet.toString());
        _bni_active_slot.labelContent = info.bni_active;
        _total_cash_available.labelContent = FUNC.insert_dot(info.cash_available.toString());
        _total_edc_available.labelContent = FUNC.insert_dot(info.edc_not_settle.toString());
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
                if (abc.counter%2==0 && print_receipt_button.visible==true){
                    print_receipt_button.modeReverse = true;
                } else {
                    print_receipt_button.modeReverse = false;
                }
            }
        }
    }

    Row{
        id: admin_buttons_rows
        spacing: 8
        anchors.left: parent.left
        anchors.leftMargin: 15
        anchors.top: parent.top
        anchors.topMargin: 20
        width: parent.width - 500
        height: 100

        AdminPanelButton{
            id:back_button
            z: 10
            button_text: 'exit'
            visible: !popup_loading.visible
            modeReverse: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Admin Page "Cancel"');
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
                }
            }
        }

        AdminPanelButton{
            id:refresh_button
            z: 10
            button_text: 'refresh'
            visible: !popup_loading.visible
            modeReverse: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Admin Page "Refresh"');
                    console.log('refresh_button is pressed..!');
                    popup_loading.open();
                    _SLOT.kiosk_get_machine_summary();
                    _SLOT.kiosk_get_product_stock();
                }
            }
        }

        AdminPanelButton{
            id: reboot_button
            z: 10
            button_text: 'reboot'
            visible: !popup_loading.visible
            modeReverse: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Admin Page "Reboot"');
                    if (press != '0') return;
                    press = '1';
                    console.log('reboot_button is pressed..!');
                    false_notif('Dear User|Tekan Tombol "reboot" Untuk Melanjutkan Proses.', false);
                    standard_notif_view.buttonEnabled = false;
                }
            }
        }

        AdminPanelButton{
            id: reset_grg_button
            z: 10
            button_text: 'reset grg'
            visible: !popup_loading.visible
            modeReverse: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Admin Page "Reset GRG"');
                    if (press != '0') return;
                    press = '1';
                    console.log('reset_grg_button is pressed..!');
                    popup_loading.open();
                    _SLOT.start_init_grg();
                }
            }
        }

        AdminPanelButton{
            id: ka_login_button
            z: 10
            button_text: 'ka login'
            visible: !popup_loading.visible
            modeReverse: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Admin Page "KA Login"');
                    if (press != '0') return;
                    press = '1';
                    popup_loading.open();
                    _SLOT.start_auth_ka();
                }
            }
        }

        AdminPanelButton{
            id: mandiri_settlement_button
            z: 10
            button_text: 'settle\nmanual'
            visible: !popup_loading.visible
            modeReverse: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Admin Page "Settlement Manual Mandiri"');
                    if (press != '0') return;
                    press = '1';
                    console.log('mandiri_settlement_button is pressed..!');
                    popup_loading.open();
                    _SLOT.start_reset_mandiri_settlement();
                }
            }
        }

        AdminPanelButton{
            id: activation_bni_button
            z: 10
            button_text: 'activate\nbni'
            visible: !popup_loading.visible
            modeReverse: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Admin Page "Activate BNI"');
                    if (press != '0') return;
                    press = '1';
                    console.log('activation_bni_button is pressed..!');
                    popup_loading.open();
                    _SLOT.start_master_activation_bni();
                }
            }
        }

        AdminPanelButton{
            id: topup_bni_deposit_button
            z: 10
            button_text: 'topup bni\ndeposit'
            visible: !popup_loading.visible
            modeReverse: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Admin Page "Topup BNI Deposit"');
                    if (press != '0') return;
                    press = '1';
                    console.log('topup_bni_deposit_button is pressed..!');
                    popup_loading.open();
                    _SLOT.start_do_force_topup_bni();
                }
            }
        }

        AdminPanelButton{
            id: sync_product_stock
            z: 10
            button_text: 'sync\ncard'
            visible: !popup_loading.visible
            modeReverse: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Admin Page "Sync Card"');
                    if (press != '0') return;
                    press = '1';
                    console.log('sync_product_stock is pressed..!');
                    popup_loading.open();
                    _SLOT.start_sync_product_stock();
                }
            }
        }

        AdminPanelButton{
            id: test_update_app
            z: 10
            button_text: 'update\napp'
            visible: !popup_loading.visible
            modeReverse: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Admin Page "Force Update App"');
                    if (press != '0') return;
                    press = '1';
                    console.log('update_app is pressed..!');
                    popup_loading.open();
                    _SLOT.start_do_update();
                }
            }
        }

        AdminPanelButton{
            id: print_receipt_button
            z: 10
            button_text: 'collect\nprint'
            visible: (!popup_loading.visible && actionList.length > 0)
            modeReverse: false
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Admin Page "Collection Print"');
                    if (press != '0') return;
                    press = '1';
                    console.log('print_receipt_button is pressed..!');
                    if (actionList.length > 0){
                        popup_loading.open();
                        var epoch = new Date().getTime();
                        var struct_id = userData.username+epoch;
                        _SLOT.start_admin_print_global(struct_id);
                    } else {
                        false_notif('Dear '+userData.first_name+'|Pastikan Anda Telah Melakukan Pemgambilan Cash Atau Update Stock Item');
                    }
                }
            }
        }

    }


    //==============================================================
    //PUT MAIN COMPONENT HERE
    Row{
        id: row_data
        width: parent.width
        height: parent.height - 180
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        spacing: 10
        visible: (!standard_notif_view.visible && !popup_loading.visible && !popup_update_stock.visible) ? true : false;
        scale: visible ? 1.0 : 0.1
        Behavior on scale {
            NumberAnimation  { duration: 500 ; easing.type: Easing.InOutBounce  }
        }


        GroupBox{
            id: groupBox_1
            flat: true
            height: parent.height
            width: (parent.width/4) - 20
            Rectangle{
                anchors.fill: parent
                color: '#1D294D'
                radius: 25
                opacity: .97
            }
            BoxTitle{
                anchors.top: parent.top
                anchors.topMargin: -25
                anchors.horizontalCenter: parent.horizontalCenter
                title_text: 'KIOSK STATUS'
                boxColor: 'dimgray'
            }
            Column{
                id: col_summary
                width: 300
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.top: parent.top
                anchors.topMargin: 80
                spacing: 25
                TextDetailRowNew{
                    id: _online_status
                    labelName: qsTr('Status Online')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _cpu_temp
                    labelName: qsTr('CPU Temp')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _disk_c
                    labelName: qsTr('Disk C: | D:')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _ram_status
                    labelName: qsTr('Status RAM')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _theme_status
                    labelName: qsTr('Theme Name')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _version_status
                    labelName: qsTr('App Ver.')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _service_status
                    labelName: qsTr('Service Ver.')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _last_sync
                    labelName: qsTr('Last Sync')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }

            }


        }


        GroupBox{
            id: groupBox_2
            flat: true
            height: parent.height
            width: (parent.width/4) - 10
            Rectangle{
                anchors.fill: parent
                color: '#1D294D'
                radius: 25
                opacity: .97
            }
            BoxTitle{
                anchors.top: parent.top
                anchors.topMargin: -25
                anchors.horizontalCenter: parent.horizontalCenter
                title_text: 'TRANSACTION'
                boxColor: 'green'
            }
            Column{
                id: col_summary2
                width: 300
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.top: parent.top
                anchors.topMargin: 80
                spacing: 25
                TextDetailRowNew{
                    id: _today_trx
                    labelName: qsTr('Today TRX')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _total_trx
                    labelName: qsTr('Total TRX')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _cash_trx
                    labelName: qsTr('Cash TRX')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _edc_trx
                    labelName: qsTr('EDC TRX')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _mandiri_wallet
                    labelName: qsTr('Mandiri Wallet')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _mandiri_active_slot
                    labelName: qsTr('Mandiri Active')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _bni_wallet
                    labelName: qsTr('BNI Wallet')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _bni_active_slot
                    labelName: qsTr('BNI Active')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }

            }

        }


        GroupBox{
            id: groupBox_3
            flat: true
            height: parent.height
            width: (parent.width/4) - 10
            Rectangle{
                anchors.fill: parent
                color: '#1D294D'
                radius: 25
                opacity: .97
            }
            BoxTitle{
                anchors.top: parent.top
                anchors.topMargin: -25
                anchors.horizontalCenter: parent.horizontalCenter
                title_text: 'ADMINISTRATIVE'
                boxColor: 'blue'
            }
            Column{
                id: col_summary3
                width: 300
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.top: parent.top
                anchors.topMargin: 80
                spacing: 25
                TextDetailRowNew{
                    id: _total_cash_available
                    labelName: qsTr('Total Cash')
                    contentSize: 30
                    labelContent: '0'
                    labelSize: 22
                    theme: 'white'
                }
                NextButton{
                   id: button_collect_cash
                   width: 110
                   height: 40
                   anchors.right: _total_cash_available.right
                   anchors.rightMargin: 80
                   fontSize: 15
                   modeRadius: false
                   button_text: 're-init grg'
                   modeReverse: true
                   MouseArea{
                       anchors.fill: parent
                       enabled: (parseInt(_total_cash_available.labelContent) > 0) ? true : false
                       onClicked: {
                           _SLOT.user_action_log('Admin Page "Collect Cash"');
                           console.log('Collect Cash Button is Pressed..!')
                           if (userData.isAbleCollect==1){
                               _SLOT.start_begin_collect_cash();
                               popup_loading.open();
                               _total_cash_available.labelContent = '0';
                               actionList.push({
                                                   type: 'collectCash',
                                                   user: userData.first_name
                                               })
                           } else {
                               false_notif('Mohon Maaf|User Anda Tidak Diperkenankan, Hubungi Master Admin')
                           }
                       }
                   }
                }
                TextDetailRowNew{
                    id: _total_edc_available
                    labelName: qsTr('Total EDC')
                    contentSize: 30
                    labelContent: '0'
                    labelSize: 22
                    theme: 'white'
                }
                NextButton{
                   id: button_settle_edc
                   width: 80
                   height: 40
                   anchors.right: _total_edc_available.right
                   anchors.rightMargin: 100
                   fontSize: 15
                   modeRadius: false
                   button_text: 'settle'
                   modeReverse: true
                   MouseArea{
                       anchors.fill: parent
                       enabled: (parseInt(_total_edc_available.labelContent) > 0) ? true : false
                       onClicked: {
                           _SLOT.user_action_log('Admin Page "EDC Settlement"');
                           console.log('Settlement EDC Button is Pressed..!')
                           if (userData.isAbleCollect==1){
                               _SLOT.start_edc_settlement();
                               popup_loading.open();
//                               actionList.push({
//                                                   type: 'settleEdc',
//                                                   user: userData.first_name
//                                               })
                           } else {
                               false_notif('Mohon Maaf|User Anda Tidak Diperkenankan, Hubungi Master Admin')
                           }
                       }
                   }
                }
                TextDetailRowNew{
                    id: _total_stock_101
                    labelName: qsTr('COM 1 Stock')
                    contentSize: 30
                    labelContent: '0'
                    labelSize: 22
                    theme: 'white'
                }
                NextButton{
                   id: button_update_stock1
                   enabled: (_total_stock_101!='---') ? true : false
                   button_text: 'update'
                   width: 80
                   height: 40
                   anchors.right: _total_stock_101.right
                   anchors.rightMargin: 100
                   fontSize: 15
                   modeRadius: false
                   modeReverse: true
                   MouseArea{
                       anchors.fill: parent
                       onClicked: {
                           _SLOT.user_action_log('Admin Page "Update Slot 1"');
                           console.log('Update Stock Button 1 is Pressed..!')
                           if (userData.isAbleCollect==1){
                               popup_update_stock.selectedSlot = '101'
                               popup_update_stock.open();
                           } else {
                               false_notif('Mohon Maaf|User Anda Tidak Diperkenankan, Hubungi Master Admin')
                           }
                       }
                   }
                }
                TextDetailRowNew{
                    id: _total_stock_102
                    labelName: qsTr('COM 2 Stock')
                    contentSize: 30
                    labelContent: '0'
                    labelSize: 22
                    theme: 'white'
                }
                NextButton{
                   id: button_update_stock2
                   enabled: (_total_stock_102!='---') ? true : false
                   button_text: 'update'
                   width: 80
                   height: 40
                   anchors.right: _total_stock_102.right
                   anchors.rightMargin: 100
                   fontSize: 15
                   modeRadius: false
                   modeReverse: true
                   MouseArea{
                       anchors.fill: parent
                       onClicked: {
                           _SLOT.user_action_log('Admin Page "Update Slot 2"');
                           console.log('Update Stock Button 2 is Pressed..!')
                           if (userData.isAbleCollect==1){
                               popup_update_stock.selectedSlot = '102'
                               popup_update_stock.open();
                           } else {
                               false_notif('Mohon Maaf|User Anda Tidak Diperkenankan, Hubungi Master Admin')
                           }
                       }
                   }
                }
                TextDetailRowNew{
                    id: _total_stock_103
                    labelName: qsTr('COM 3 Stock')
                    contentSize: 30
                    labelContent: '0'
                    labelSize: 22
                    theme: 'white'
                }
                NextButton{
                   id: button_update_stock3
                   enabled: (_total_stock_103!='---') ? true : false
                   button_text: 'update'
                   width: 80
                   height: 40
                   anchors.right: _total_stock_103.right
                   anchors.rightMargin: 100
                   fontSize: 15
                   modeRadius: false
                   modeReverse: true
                   MouseArea{
                       anchors.fill: parent
                       onClicked: {
                           _SLOT.user_action_log('Admin Page "Update Slot 3"');
                           console.log('Update Stock Button 3 is Pressed..!')
                           if (userData.isAbleCollect==1){
                               popup_update_stock.selectedSlot = '103'
                               popup_update_stock.open();
                           } else {
                               false_notif('Mohon Maaf|User Anda Tidak Diperkenankan, Hubungi Master Admin')
                           }
                       }
                   }
                }
            }

        }


        GroupBox{
            id: groupBox_4
            flat: true
            height: parent.height
            width: (parent.width/4) - 10
            Rectangle{
                anchors.fill: parent
                color: '#1D294D'
                radius: 25
                opacity: .97
            }
            BoxTitle{
                anchors.top: parent.top
                anchors.topMargin: -25
                anchors.horizontalCenter: parent.horizontalCenter
                title_text: 'ERROR'
                boxColor: 'red'
            }
            Column{
                id: col_summary4
                width: 300
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.top: parent.top
                anchors.topMargin: 80
                spacing: 25
                TextDetailRowNew{
                    id: _edc_error
                    labelName: qsTr('EDC UPT')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _nfc_error
                    labelName: qsTr('Prepaid Reader')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _bill_error
                    labelName: qsTr('Bill Validator')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _scanner_error
                    labelName: qsTr('Scanner Reader')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _webcam_error
                    labelName: qsTr('Webcam')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _cd1_error
                    labelName: qsTr('Card Disp 1')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _cd2_error
                    labelName: qsTr('Card Disp 2')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }
                TextDetailRowNew{
                    id: _cd3_error
                    labelName: qsTr('Card Disp 3')
                    contentSize: 30
                    labelContent: '---'
                    labelSize: 22
                    theme: 'white'
                }

            }

        }

    }

    NextButton{
       id: button_test_slot1
       x: 1293
       y: 665
       visible: row_data.visible
       enabled: (_total_stock_101!='---') ? true : false
       button_text: 'test'
       width: 80
       height: 40
       fontSize: 15
       modeRadius: false
       modeReverse: true
       MouseArea{
           anchors.fill: parent
           onClicked: {
               _SLOT.user_action_log('Admin Page "Test Slot 1"');
               console.log('Test Slot 1 Button is Pressed..!');
               _SLOT.start_multiple_eject('101', '1');
           }
       }
    }

    NextButton{
       id: button_test_slot2
       x: 1293
       y: 825
       visible: row_data.visible
       enabled: (_total_stock_102!='---') ? true : false
       button_text: 'test'
       width: 80
       height: 40
       fontSize: 15
       modeRadius: false
       modeReverse: true
       MouseArea{
           anchors.fill: parent
           onClicked: {
               _SLOT.user_action_log('Admin Page "Test Slot 2"');
               console.log('Test Slot 2 Button is Pressed..!');
               _SLOT.start_multiple_eject('102', '1');
           }
       }
    }

    NextButton{
       id: button_test_slot3
       x: 1293
       y: 985
       visible: row_data.visible
       enabled: (_total_stock_103!='---') ? true : false
       button_text: 'test'
       width: 80
       height: 40
       fontSize: 15
       modeRadius: false
       modeReverse: true
       MouseArea{
           anchors.fill: parent
           onClicked: {
               _SLOT.user_action_log('Admin Page "Test Slot 3"');
               console.log('Test Slot 3 Button is Pressed..!');
               _SLOT.start_multiple_eject('103', '1');
           }
       }
    }

    function false_notif(param, button){
        press = '0';
        standard_notif_view.z = 100;
        standard_notif_view._button_text = 'tutup';
        var buttonEnable = true;
        if (button!=undefined) buttonEnable = button;
        standard_notif_view.buttonEnabled = buttonEnable;
        if (param==undefined){
            standard_notif_view.show_text = "Mohon Maaf";
            standard_notif_view.show_detail = "Terjadi Kesalahan Pada Sistem, Mohon Coba Lagi Beberapa Saat";
        } else {
            standard_notif_view.show_text = param.split('|')[0];
            standard_notif_view.show_detail = param.split('|')[1];
        }
        standard_notif_view.open();
    }


    //==============================================================


    StandardNotifView{
        id: standard_notif_view
//        visible: true
//        withBackground: false
        modeReverse: true
        show_text: "Dear Customer"
        show_detail: "Please Ensure You have set Your plan correctly."
        z: 99
        NextButton{
            id: action_button
            visible: !parent.buttonEnabled
            button_text: 'reboot'
            anchors.verticalCenterOffset: 200
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Admin Page Notif Button "Reboot"');
                    _SLOT.start_safely_shutdown('RESTART');
                }
            }
        }

    }


    PopupLoadingCircle{
        id: popup_loading
    }

    PopupUpdateStock{
        id: popup_update_stock
    }




}

