import QtQuick 2.4
import QtQuick.Controls 1.3
import QtGraphicalEffects 1.0
import "base_function.js" as FUNC
import "screen.js" as SCREEN
import "config.js" as CONF


Base{
    id: general_payment_process
    width: parseInt(SCREEN.size.width)
    height: parseInt(SCREEN.size.height)
    property int timer_value: 300
    property var press: '0'
    property var details
    property var notif_text: 'Masukan Uang Tunai Anda Pada Bill Acceptor di bawah'
    property bool isPaid: false
    property int receivedCash: 0
    property var lastBalance: '999000'
    property var cardNo: '6024123443211234'
    property var totalPrice: 0
    property var getDenom: 0
    property var adminFee: 0
    property var modeButtonPopup;
    property bool topupSuccess: false
    property int reprintAttempt: 0
    property var uniqueCode: ''

    property bool frameWithButton: false
    property bool centerOnlyButton: false
    property int attemptCD: 0

    property var qrPayload
    property var preloadNotif: 'refundWhatsapp'
    property var customerPhone: ''

    property var notifTitle: ''
    property var notifMessage: ''

    signal framingSignal(string str)

    idx_bg: 0
    imgPanel: 'source/cash black.png'
    textPanel: 'Proses Pembayaran'
    imgPanelScale: .8

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            if (details != undefined) console.log('product details', JSON.stringify(details));
            if (preloadNotif==undefined){
                define_first_notif();
            } else {
                popup_input_number.open('Silakan Masukkan No WhatsApp Anda')
            }
            modeButtonPopup = 'check_balance';
            abc.counter = timer_value;
            my_timer.start();
            reset_default();
        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
        }
    }

    Component.onCompleted:{
        base.result_balance_qprox.connect(get_balance);
        base.result_sale_edc.connect(edc_payment_result);
        base.result_accept_mei.connect(mei_payment_result);
        base.result_dis_accept_mei.connect(mei_payment_result);
        base.result_stack_mei.connect(mei_payment_result);
        base.result_return_mei.connect(mei_payment_result);
        base.result_store_es_mei.connect(mei_payment_result);
        base.result_cd_move.connect(card_eject_result);
        base.result_store_transaction.connect(store_result);
        base.result_sale_print.connect(print_result);
        base.result_topup_qprox.connect(topup_result);
        base.result_store_topup.connect(store_result);
        base.result_grg_receive.connect(grg_payment_result);
        base.result_grg_stop.connect(grg_payment_result);
        base.result_grg_status.connect(grg_payment_result);
        base.result_get_qr.connect(qr_get_result);
        base.result_check_qr.connect(qr_check_result);
        base.result_trx_ppob.connect(ppob_trx_result);
        base.result_pay_qr.connect(qr_check_result);
        base.result_diva_transfer_balance.connect(transfer_balance_result)
        framingSignal.connect(get_signal_frame)
    }

    Component.onDestruction:{
        base.result_balance_qprox.disconnect(get_balance);
        base.result_sale_edc.disconnect(edc_payment_result);
        base.result_accept_mei.disconnect(mei_payment_result);
        base.result_dis_accept_mei.disconnect(mei_payment_result);
        base.result_stack_mei.disconnect(mei_payment_result);
        base.result_return_mei.disconnect(mei_payment_result);
        base.result_store_es_mei.disconnect(mei_payment_result);
        base.result_cd_move.disconnect(card_eject_result);
        base.result_store_transaction.disconnect(store_result);
        base.result_sale_print.disconnect(print_result);
        base.result_topup_qprox.disconnect(topup_result);
        base.result_store_topup.disconnect(store_result);
        base.result_grg_receive.disconnect(grg_payment_result);
        base.result_grg_stop.disconnect(grg_payment_result);
        base.result_grg_status.disconnect(grg_payment_result);
        base.result_get_qr.disconnect(qr_get_result);
        base.result_check_qr.disconnect(qr_check_result);
        base.result_trx_ppob.disconnect(ppob_trx_result);
        base.result_pay_qr.disconnect(qr_check_result);
        base.result_diva_transfer_balance.disconnect(transfer_balance_result)
        framingSignal.disconnect(get_signal_frame)

    }


    function reset_default(){
        press = '0';
        uniqueCode = '';
        customerPhone = '';
        notifTitle = '';
        notifMessage = ''
        receivedCash = 0;
        isPaid = false;
        topupSuccess = false;
        reprintAttempt = 0;
        qrPayload = undefined;
        attemptCD = 0;
        frameWithButton = false;
        centerOnlyButton = false;
    }

    function release_print_with_refund(refund_amount, title, message){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        set_refund_number(customerPhone);
        popup_loading.open();
        if (refund_amount==undefined) {
            console.log('release_print_with_refund', now, 'MISSING_REFUND_AMOUNT');
            return;
        }
        details.refund_amount = refund_amount;
        var refundPayload = {
            amount: refund_amount.toString(),
            customer: customerPhone,
            reff_no: details.shop_type + details.epoch.toString(),
        }
        if (title!=undefined) notifTitle = title;
        if (message!=undefined) notifMessage = message;
        console.log('release_print_with_refund', now, JSON.stringify(refundPayload));
        _SLOT.start_transfer_balance(JSON.stringify(refundPayload))
    }


    function transfer_balance_result(transfer){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('transfer_balance_result', now, transfer);
        popup_loading.close();
        var result = transfer.split('|')[1];
        if (['MISSING_REFF_NO','MISSING_AMOUNT','MISSING_CUSTOMER', 'ERROR'].indexOf(result) > -1){
            details.refund_status = 'PENDING';
        }
        if (result=='SUCCESS'){
            details.refund_status = 'SUKSES';
        }
        release_print_only(notifTitle, notifMessage);
    }

    function release_print_only(title, msg){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        popup_loading.close();
        if (title==undefined || title.length == 0) title = 'Terima Kasih';
        if (msg==undefined || msg.length == 0) msg = 'Silakan Ambil Struk Transaksi Anda';
        console.log('release_print_only', now, title, msg);
        switch_frame('source/take_receipt.png', title, msg, 'backToMain', true );
        _SLOT.start_direct_store_transaction_data(JSON.stringify(details));
        _SLOT.python_dump(JSON.stringify(details))
        _SLOT.start_sale_print_global();
        reset_default();
    }

    function ppob_trx_result(p){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('ppob_trx_result', now, p);
        popup_loading.close();
        var result = p.split('|')[1]
        if (['ovo', 'gopay', 'dana', 'linkaja'].indexOf(details.payment) > -1) qr_payment_frame.close();
        if (['MISSING_MSISDN', 'MISSING_PRODUCT_ID','MISSING_AMOUNT','MISSING_OPERATOR', 'MISSING_PAYMENT_TYPE', 'MISSING_PRODUCT_CATEGORY', 'MISSING_REFF_NO', 'ERROR'].indexOf(result) > -1){
            details.process_error = 1
            if (customerPhone!='') {
//                switch_frame('source/smiley_down.png', 'Terjadi Kesalahan', 'Memproses Pengembalian Dana Anda', 'closeWindow', true );
                var refund_amount = details.value.toString();
                if (details.payment=='cash') refund_amount = receivedCash.toString();
                release_print_with_refund(refund_amount, 'Terjadi Kesalahan', 'Silakan Ambil Struk Sebagai Bukti');
            } else {
//                switch_frame('source/smiley_down.png', 'Terjadi Kesalahan', 'Silakan Ambil Struk Sebagai Bukti', 'backToMain', true )
                release_print_only('Terjadi Kesalahan', 'Silakan Ambil Struk Sebagai Bukti');
            }
        }
        if (validate_cash_refundable()){
            var exceed = receivedCash - totalPrice;
            release_print_with_refund(exceed.toString());
//                popup_loading.textSlave = 'Memproses Pengembalian Kelebihan Bayar Anda';
        } else {
            var info = JSON.parse(result);
            details.ppob_details = info;
            release_print_only();
        }
    }

    function validate_cash_refundable(){
        return (details.payment == 'cash' && receivedCash > totalPrice)
    }

    function qr_check_result(r){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('qr_check_result', now, r);
        var mode = r.split('|')[1]
        var result = r.split('|')[2]
        popup_loading.close();
        if (['NOT_AVAILABLE', 'MISSING_AMOUNT', 'MISSING_TRX_ID', 'ERROR'].indexOf(result) > -1){
            switch_frame('source/smiley_down.png', 'Terjadi Kesalahan', 'Silakan Coba Lagi Dalam Beberapa Saat', 'backToMain', true )
            return;
        }
        if (result=='SUCCESS'){
            var info = JSON.parse(r.split('|')[3]);
            now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
            console.log('qr_check_result', now, mode, result, info);
            qr_payment_frame.success(15)
            details.payment_details = info;
            details.payment_received = details.value.toString();
            payment_complete(details.shop_type);
//            var qrMode = mode.toLowerCase();
//            switch(qrMode){
//            case 'ovo':
//                _SLOT.start_confirm_ovo_qr(JSON.stringify(qrPayload));
//                break;
//            }
        }
    }

    function qr_get_result(r){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('qr_get_result', now, r);
        var mode = r.split('|')[1]
        var result = r.split('|')[2]
        if (['NOT_AVAILABLE', 'MISSING_AMOUNT', 'MISSING_TRX_ID', 'ERROR', 'MODE_NOT_FOUND'].indexOf(result) > -1){
            switch_frame('source/smiley_down.png', 'Terjadi Kesalahan', 'Silakan Coba Lagi Dalam Beberapa Saat', 'backToMain', true )
            return;
        }
        popup_loading.close();
        var info = JSON.parse(result);
        var qrMode = mode.toLowerCase();
        qr_payment_frame.modeQR = qrMode;
        qr_payment_frame.imageSource = info.qr;
//        if (qrMode=='ovo') _SLOT.start_do_pay_ovo_qr(JSON.stringify(qrPayload));
//        if (qrMode=='gopay') _SLOT.start_do_check_gopay_qr(JSON.stringify(qrPayload));
//        if (qrMode=='linkaja') _SLOT.start_do_check_linkaja_qr(JSON.stringify(qrPayload));
        qr_payment_frame.open();
    }

    function topup_result(t){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('topup_result', now, t);
        global_frame.close();
        popup_loading.close();
        if (['ovo', 'gopay', 'dana', 'linkaja'].indexOf(details.payment) > -1) qr_payment_frame.close();
        abc.counter = 30;
        my_timer.restart();
        if (t==undefined||t.indexOf('ERROR') > -1||t=='TOPUP_ERROR'||t=='TOPUP_FAILED_BALANCE_EXPIRED'||t.indexOf('TOPUP_SAM_REQUIRED')> -1){
            if (t=='TOPUP_FAILED_BALANCE_EXPIRED') _SLOT.start_reset_mandiri_settlement();
            if (t.indexOf('TOPUP_SAM_REQUIRED')> -1) {
                var slot_topup = t.split('|')[1]
                _SLOT.start_do_topup_bni(slot_topup);
                console.log('do topup action for slot : ', now, slot_topup)
            }
            switch_frame('source/smiley_down.png', 'Terjadi Kesalahan', 'Pada Proses Isi Ulang Saldo Prabayar Anda', 'closeWindow|3', true )
        } else if (t=='TOPUP_FAILED_CARD_NOT_MATCH'){
            switch_frame('source/smiley_down.png', 'Terjadi Kesalahan', 'Terdeteksi Perbedaan Kartu Saat Isi Ulang', 'closeWindow|3', true )
        } else {
            var output = t.split('|')
            var topupResponse = output[0]
            var result = JSON.parse(output[1]);
            if (topupResponse=='0000'){
                topupSuccess = true;
                details.topup_details = result;
                cardNo = result.card_no;
                lastBalance = result.last_balance;
                _SLOT.start_store_topup_transaction(JSON.stringify(details));
//                switch_frame('source/take_receipt.png', 'Terima Kasih', 'Silakan Ambil Struk Transaksi Anda', 'backToMain', true );
                _SLOT.start_do_mandiri_topup_settlement();
//                card_no_prepaid.text = FUNC.insert_space_four(cardNo);
//                image_prepaid_card.source = "source/tapcash-card.png";
//                notif_saldo.text = "Isi Ulang Berhasil.\nSaldo Kartu TapCash Anda\nRp. "+FUNC.insert_dot(lastBalance)+",-\nAmbil Struk Anda di Bawah."
//                if (cardNo.substring(0, 4) == '6032'){
//                  image_prepaid_card.source = "source/emoney-card.png";
//                  notif_saldo.text = "Isi Ulang Berhasil.\nSaldo Kartu e-Money Anda\nRp. "+FUNC.insert_dot(lastBalance)+",-\nAmbil Struk Anda di Bawah."
//                } else if (cardNo.substring(0, 4) == '7546'){
//                  image_prepaid_card.source = "source/tapcash-card.png";
//                  notif_saldo.text = "Isi Ulang Berhasil.\nSaldo Kartu TapCash Anda\nRp. "+FUNC.insert_dot(lastBalance)+",-\nAmbil Struk Anda di Bawah."
//                }
//            } else if (topupResponse=='5106'||topupResponse=='5103'){
//                slave_title.text = 'Terdeteksi Kegagalan Pada Proses Isi Ulang Karena Kartu Tidak Sesuai.\nSilakan Ambil Struk Anda Di Bawah dan Hubungi Layanan Pelanggan.';
//                slave_title.visible = true;
//            } else if (topupResponse=='1008'){
//                slave_title.text = 'Terdeteksi Kegagalan Pada Proses Isi Ulang Karena Kartu Sudah Tidak Aktif.\nSilakan Ambil Struk Anda Di Bawah dan Hubungi Layanan Pelanggan.';
//                slave_title.visible = true;
//            } else if (topupResponse=='FFFE'){
//                slave_title.text = 'Terjadi Kegagalan Pada Proses Isi Ulang Karena Kartu Tidak Terdeteksi.\nSilakan Ambil Struk Anda Di Bawah dan Hubungi Layanan Pelanggan.';
//                slave_title.visible = true;
                if (validate_cash_refundable()){
                    var exceed = receivedCash - totalPrice;
                    release_print_with_refund(exceed.toString());
    //                popup_loading.textSlave = 'Memproses Pengembalian Kelebihan Bayar Anda';
                } else {
                    release_print_only();
                }
                return;
            }
        }
        details.process_error = 1;
        if (customerPhone!='') {
//            switch_frame('source/smiley_down.png', 'Terjadi Kesalahan', 'Memproses Pengembalian Dana Anda', 'closeWindow', true );
            var refund_amount = details.value.toString();
            if (details.payment=='cash') refund_amount = receivedCash.toString();
            release_print_with_refund(refund_amount, 'Terjadi Kesalahan', 'Silakan Ambil Struk Sebagai Bukti')
        } else {
            release_print_only('Terjadi Kesalahan', 'Silakan Ambil Struk Sebagai Bukti');
        }
        // Check Manual Update SAM Saldo Here
        // if (topupSuccess) _SLOT.start_manual_topup_bni();
    }

    function print_result(p){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('print_result', now, p)
//        if (p!='SALEPRINT|DONE'){
//            abc.counter = 10;
//            my_timer.restart();
//            false_notif('Dear User|Jika Struk Tidak Keluar, Silakan Tekan Tombol Berikut');
//            modeButtonPopup = 'reprint';
//            standard_notif_view._button_text = 'cetak lagi';
//            standard_notif_view.buttonEnabled = false;
//        }
    }

    function store_result(r){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('store_result', now, r)
        if (r.indexOf('ERROR') > -1 || r.indexOf('FAILED|STORE_TRX') > -1){
//            _SLOT.retry_store_transaction_global()
            console.log('Retry To Store The Data into DB')
        }
    }

    function print_failed_transaction(channel, issue){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('print_failed_transaction', now, channel, issue, receivedCash, customerPhone, JSON.stringify(details));
        if (issue==undefined) issue = 'GRG_ERROR';
        if (channel=='cash'){
            details.payment_error = issue;
            details.payment_received = receivedCash.toString();
            if (customerPhone!=''){
//                switch_frame('source/smiley_down.png', 'Terjadi Kesalahan/Pembatalan', 'Memproses Pengembalian Dana Anda', 'closeWindow', true );
                var refund_amount = receivedCash.toString();
                release_print_with_refund(refund_amount, 'Terjadi Kesalahan/Pembatalan', 'Silakan Ambil Struk Sebagai Bukti');
            } else {
                release_print_only();
            }
        }
    }

    function card_eject_result(r){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('card_eject_result', now, r);
        global_frame.close();
        popup_loading.close();
        if (['ovo', 'gopay', 'dana', 'linkaja'].indexOf(details.payment) > -1) qr_payment_frame.close();
        abc.counter = 30;
        my_timer.restart();
        if (r=='EJECT|PARTIAL'){
            press = '0';
            attemptCD -= 1;
            switch_frame('source/take_card.png', 'Silakan Ambil Kartu Anda', 'Kemudian Tekan Tombol Lanjut', 'closeWindow|25', true );
            centerOnlyButton = true;
            modeButtonPopup = 'retrigger_card';
            return;
        }
        if (r == 'EJECT|ERROR') {
            details.process_error = 1
//            slave_title.text = 'Silakan Ambil Struk Anda Di Bawah.\nJika Kartu Tidak Keluar, Silakan Hubungi Layanan Pelanggan.';
            if (customerPhone!='') {
//                switch_frame('source/smiley_down.png', 'Terjadi Kesalahan', 'Memproses Pengembalian Dana Anda', 'closeWindow', true );
                var refund_amount = details.value.toString();
                if (details.payment=='cash') refund_amount = receivedCash.toString();
                release_print_with_refund(refund_amount, 'Terjadi Kesalahan', 'Silakan Ambil Struk Sebagai Bukti');
                return;
            } else {
//                switch_frame('source/smiley_down.png', 'Terjadi Kesalahan', 'Silakan Ambil Struk Transaksi Anda Hubungi Layanan Pelanggan', 'backToMain', true )
                release_print_only('Terjadi Kesalahan', 'Silakan Ambil Struk Sebagai Bukti');
            }
        }
        if (r == 'EJECT|SUCCESS') {
//            var qty = details.qty.toString()
//            slave_title.text = 'Silakan Ambil Struk dan ' + unit + ' pcs Kartu Prabayar Baru Anda Di Bawah.';
            if (validate_cash_refundable()){
                var exceed = receivedCash - totalPrice;
                release_print_with_refund(exceed.toString());
//                popup_loading.textSlave = 'Memproses Pengembalian Kelebihan Bayar Anda';
            } else {
                release_print_only();
            }
//            switch_frame('source/thumb_ok.png', 'Silakan Ambil Kartu dan Struk Transaksi Anda', 'Terima Kasih', 'backToMain', false )
        }
    }

    function payment_complete(mode){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
    //        popup_loading.close();
        if (mode != undefined){
            console.log('payment_complete', now, mode)
            details.notes = mode + ' - ' + new Date().getTime().toString();
        }
        console.log('payment_complete', now, JSON.stringify(details))
        if (details.provider==undefined) details.provider = 'e-Money Mandiri';
        if (details.shop_type!='ppob') _SLOT.start_store_transaction_global(JSON.stringify(details))
        isPaid = true;
        abc.counter = timer_value;
        my_timer.restart();
//        arrow_down.visible = false;
//        arrow_down.anchors.rightMargin = 900;
//        back_button.button_text = 'selesai';
//        back_button.visible = true;
        switch(details.shop_type){
            case 'shop':
//                var unit = details.qty.toString() change to details.status
                attemptCD = details.qty;
                var attempt = details.status.toString();
                var multiply = details.qty.toString();
                _SLOT.start_multiple_eject(attempt, multiply);
//                var textMain1 = 'Ambil Kartu Prabayar Anda Segera Setelah Keluar Dari Mesin'
//                switch_frame('source/insert_card_new.png', textMain1, '', 'closeWindow|10', false )
//                slave_title.text = 'Sedang Memproses Kartu Prabayar Baru Anda Dalam Beberapa Saat...'
                break;
            case 'topup':
//                open_preload_notif();
//                modeButtonPopup = 'do_topup';
//                standard_notif_view._button_text = 'lanjut';
//                standard_notif_view.buttonEnabled = false;
                var textMain2 = 'Letakkan kartu prabayar Anda di alat pembaca kartu yang bertanda'
                var textSlave2 = 'Pastikan kartu Anda tetap berada di alat pembaca kartu sampai transaksi selesai'
                switch_frame('source/reader_sign.png', textMain2, textSlave2, 'closeWindow|10', false )
                perform_do_topup();
//                slave_title.text = 'Sedang Memproses Isi Ulang Kartu Prabayar Anda...\nPastikan Kartu Prabayar Anda Masih Menempel Di Reader.'
                break;
            case 'ppob':
                var payload = {
                    msisdn: details.msisdn,
                    product_id: details.product_id,
                    amount: details.value.toString(),
                    reff_no: details.shop_type + details.epoch.toString(),
                    product_category: details.category,
                    payment_type: details.payment,
                    operator: details.operator
                }
                if (details.ppob_mode=='tagihan'){
                    _SLOT.start_do_pay_ppob(JSON.stringify(payload));
                } else {
                    _SLOT.start_do_topup_ppob(JSON.stringify(payload));
                }
                break;
        }
    }

    function grg_payment_result(r){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log("grg_payment_result : ", now, r)
        var grgFunction = r.split('|')[0]
        var grgResult = r.split('|')[1]
        if (grgFunction == 'RECEIVE_GRG'){
            if (grgResult == "ERROR" || grgResult == 'TIMEOUT' || grgResult == 'JAMMED'){
                false_notif('closeWindow', 'Terjadi Kegagalan Pada Bill Acceptor');
                if (receivedCash > 0){                    
                    print_failed_transaction('cash', 'GRG_ERROR');
                }
                return;
            } else if (grgResult == 'COMPLETE'){
//                _SLOT.start_dis_accept_mei();
//                _SLOT.start_store_es_mei();
                popup_loading.textMain = 'Harap Tunggu Sebentar';
                popup_loading.textSlave = 'Memproses Penyimpanan Uang Anda';
                _SLOT.stop_grg_receive_note();
                back_button.visible = false;
                popup_loading.smallerSlaveSize = true;
                popup_loading.open();
//                notif_text = qsTr('Mohon Tunggu, Memproses Penyimpanan Uang Anda.');
            } else if (grgResult == 'EXCEED'){
//                false_notif('Mohon Maaf|Silakan Hanya Masukan Nilai Uang Yang Sesuai Dengan Nominal Transaksi.\n(Ambil Terlebih Dahulu Uang Anda Sebelum Menekan Tombol)');
//                standard_notif_view.buttonEnabled = false;
//                standard_notif_view._button_text = 'coba lagi';
                modeButtonPopup = 'retrigger_grg';
//                proceedText = 'COBA LAGI';
                switch_frame_with_button('source/insert_money.png', 'Masukan Nilai Uang Yang Sesuai Dengan Nominal Transaksi', '(Ambil Terlebih Dahulu Uang Anda Sebelum Menekan Tombol)', 'closeWindow|30', true );
                return;
            } else if (grgResult == 'BAD_NOTES'){
//                false_notif('Mohon Maaf|Pastikan Uang Anda Dalam Kondisi Baik Dan Tidak Lusuh.\n(Ambil Terlebih Dahulu Uang Anda Sebelum Menekan Tombol)');
//                standard_notif_view.buttonEnabled = false;
//                standard_notif_view._button_text = 'coba lagi';
                modeButtonPopup = 'retrigger_grg';
//                proceedText = 'COBA LAGI';
                switch_frame_with_button('source/insert_money.png', 'Masukan Nilai Uang Yang Sesuai Dengan Nominal Transaksi', '(Ambil Terlebih Dahulu Uang Anda Sebelum Menekan Tombol)', 'closeWindow|30', true );
                press = '0'
                return;
            } else {
                receivedCash = parseInt(grgResult);
                abc.counter = timer_value;
                my_timer.restart();
//                _SLOT.start_grg_receive_note();
            }
        } else if (grgFunction == 'STOP_GRG'){
            if(grgResult.indexOf('SUCCESS') > -1 && receivedCash >= totalPrice) {
                var cashResponse = JSON.parse(r.replace('STOP_GRG|SUCCESS-', ''))
                details.payment_details = cashResponse;
                details.payment_received = cashResponse.total;
                payment_complete();
            }
        } else if (grgFunction == 'STATUS_GRG'){
            if(grgResult=='ERROR') {
                false_notif('backToMain', 'Terjadi Kegagalan Pada Bill Acceptor');
                return;
            }
        }
    }

    function mei_payment_result(r){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log("mei_payment_result : ", now, r)
        var meiFunction = r.split('|')[0]
        var meiResult = r.split('|')[1]
        if (meiFunction == 'STACK'){
            if (meiResult == "ERROR"||meiResult == "REJECTED"||meiResult == "OSERROR"){
                false_notif();
                if (receivedCash > 0){
                    _SLOT.start_return_es_mei();
                }
            } if (meiResult == 'COMPLETE'){
                _SLOT.start_dis_accept_mei();
                _SLOT.start_store_es_mei();
                back_button.visible = false;
                popup_loading.textMain = 'Harap Tunggu Sebentar'
                popup_loading.textSlave = 'Memproses Penyimpanan Uang Anda'
                popup_loading.open();
//                notif_text = qsTr('Mohon Tunggu, Memproses Penyimpanan Uang Anda.');
            } else {
                receivedCash = parseInt(meiResult);
            }
        } else if (meiFunction == 'STORE_ES'){
            if(meiResult.indexOf('SUCCESS') > -1) {
                var cashResponse = JSON.parse(r.replace('STORE_ES|SUCCESS-', ''))
                details.payment_details = cashResponse;
                details.payment_received = cashResponse.total;
                payment_complete();
            }
        } else if (meiFunction == 'ACCEPT'){
            if(meiResult=='ERROR') {
                false_notif();
                return;
            }
        }
    }

    function edc_payment_result(r){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss");
        console.log("edc_payment_result : ", now, r)
        var edcFunction = r.split('|')[0]
        var edcResult = r.split('|')[1]
        global_frame.close();
        popup_loading.close();
        if (['ERROR'].indexOf(edcResult) > -1){
            switch_frame_with_button('source/insert_money.png', 'Pembayaran Debit Gagal', 'Mohon Ulangi Transaksi Dalam Beberapa Saat', 'backToMain', true );
            return;
        }
        if (edcResult=='SUCCESS') {
            receivedCash = totalPrice;
            details.payment_details = JSON.parse(r.replace('SALE|SUCCESS|', ''));
            details.payment_received = totalPrice;
            payment_complete();
            popup_loading.open();
            return;
        }
        if (edcFunction == 'SALE'){
            switch(edcResult){
            case 'SR':
                notif_text = qsTr('Mohon Tunggu, Sedang Mensinkronisasi Ulang.');
                arrow_down.visible = false;
                break;
            case 'CI':
                notif_text  = qsTr('Silakan Masukan Kartu Anda Di Slot Tersedia.');
                back_button.visible = true;
                arrow_down.visible = true;
                break;
            case 'PI':
                notif_text = qsTr('Kartu Terdeteksi, Silakan Masukkan Kode PIN.');
                back_button.visible = false;
                arrow_down.visible = false;
                break;
            case 'DO':
                notif_text = qsTr('Kode Pin Diterima, Menunggu Balasan Sistem.');
                back_button.visible = false;
                arrow_down.visible = false;
                break;
            case 'TC':
                notif_text = qsTr('Mohon Maaf, Terjadi Pembatalan Pada Proses Pembayaran.');
                back_button.visible = true;
                arrow_down.visible = true;
                break;
            case 'CO':
                notif_text = qsTr('Silakan Ambil Kembali Kartu Anda Dari Slot.');
                back_button.visible = false;
                arrow_down.visible = true;
                break;
            case 'CR#EXCEPTION': case 'CR#UNKNOWN':
                notif_text = qsTr('Terjadi Suatu Kesalahan, Transaksi Anda Dibatalkan.');
                back_button.visible = true;
                arrow_down.visible = true;
                break;
            case 'CR#CARD_ERROR':
                notif_text = qsTr('Terjadi Kesalahan Pada Kartu, Transaksi Anda Dibatalkan.');
                back_button.visible = true;
                arrow_down.visible = true;
                break;
            case 'CR#PIN_ERROR':
                notif_text = qsTr('Terjadi Kesalahan Pada PIN, Transaksi Anda Dibatalkan.');
                back_button.visible = true;
                arrow_down.visible = true;
                break;
            case 'CR#SERVER_ERROR':
                notif_text = qsTr('Terjadi Kesalahan Pada Sistem, Transaksi Anda Dibatalkan.');
                back_button.visible = true;
                arrow_down.visible = true;
                break;
            case 'CR#NORMAL_CASE':
                notif_text = qsTr('Silakan Ambil Kembali Kartu Anda untuk Melanjutkan Transaksi.');
                back_button.visible = true;
                arrow_down.visible = false;
                break;
            default:
                back_button.visible = true;
                arrow_down.visible = true;
                break;
            }
        }
    }

    function get_balance(text){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('get_balance', now, text);
        press = '0';
        standard_notif_view.buttonEnabled = true;
        popup_loading.close();
        var result = text.split('|')[1];
        if (result == 'ERROR'){
            false_notif('Mohon Maaf|Gagal Mendapatkan Saldo, Pastikan Kartu Prabayar Anda sudah ditempelkan pada Reader');
            return;
        } else {
            var info = JSON.parse(result);
            var balance = info.balance
            cardNo = info.card_no;
            var bankName = info.bank_name;
            var bankType = info.bank_type;
            if (cardNo.substring(0, 4) == '6032'){
                false_notif('Pelanggan YTH|Nomor Kartu e-Money Anda ['+cardNo+']\nSisa Saldo Rp. '+ FUNC.insert_dot(balance));
            } else if (cardNo.substring(0, 4) == '7546'){
                false_notif('Pelanggan YTH|Nomor Kartu TapCash Anda ['+cardNo+']\nSisa Saldo Rp. '+ FUNC.insert_dot(balance));
            } else {
                false_notif('Pelanggan YTH|Nomor Kartu Prabayar Anda ['+cardNo+']\nSisa Saldo Rp. '+ FUNC.insert_dot(balance));
            }
            modeButtonPopup = 'do_topup';
            standard_notif_view._button_text = 'topup';
            standard_notif_view.buttonEnabled = false;
        }
    }

    function perform_do_topup(){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        var provider = details.provider;
        if (provider==undefined) provider = 'e-Money Mandiri';
        var amount = getDenom.toString();
        var structId = details.shop_type + details.epoch.toString();
        if (provider.indexOf('Mandiri') > -1 || cardNo.substring(0, 4) == '6032'){
            _SLOT.start_top_up_mandiri(amount, structId);
        } else if (provider.indexOf('BNI') > -1 || cardNo.substring(0, 4) == '7546'){
            _SLOT.start_top_up_bni(amount, structId);
        }
    }

    function get_wording(i){
        if (i=='shop') return 'Pembelian Kartu';
        if (i=='topup') return 'TopUp Kartu';
        if (i=='cash') return 'Tunai';
        if (i=='debit') return 'Kartu Debit';
        if (i=='ppob') return 'Pembayaran/Pembelian';
    }

    function define_first_notif(){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        adminFee = parseInt(details.admin_fee);
        var epoch_string = details.epoch.toString();
        uniqueCode = epoch_string.substring(epoch_string.length-6);
        _SLOT.start_set_payment(details.payment);
        if (['ovo', 'gopay', 'dana', 'linkaja'].indexOf(details.payment) > -1){
            console.log('generating_qr', now, details.payment);
            var msg = 'Persiapkan Aplikasi ' + details.payment.toUpperCase() + ' Pada Gawai Anda!';
            open_preload_notif(msg, 'source/phone_qr.png');
            totalPrice = parseInt(details.value) * parseInt(details.qty);
            qrPayload = {
                trx_id: details.shop_type + details.epoch.toString(),
                amount: totalPrice.toString(),
                mode: details.payment
            }
            _SLOT.start_get_qr_global(JSON.stringify(qrPayload));
            _SLOT.python_dump(JSON.stringify(qrPayload));
//            if (details.payment=='linkaja') _SLOT.start_get_qr_linkaja(JSON.stringify(qrPayload));
//            if (details.payment=='ovo') _SLOT.start_get_qr_ovo(JSON.stringify(qrPayload));
//            if (details.payment=='gopay') _SLOT.start_get_qr_gopay(JSON.stringify(qrPayload));
//            if (details.payment=='dana') _SLOT.start_get_qr_dana(JSON.stringify(qrPayload));
            popup_loading.open();
            return;
        }
        if (details.payment == 'cash') {
            open_preload_notif();
            totalPrice = parseInt(details.value) * parseInt(details.qty);
            getDenom = totalPrice - adminFee;
//            notif_text = 'Masukan Uang Tunai Anda Pada Bill Acceptor Di Bawah';
            _SLOT.start_set_direct_price(totalPrice.toString());
//            _SLOT.start_accept_mei();
            _SLOT.start_grg_receive_note();
            return;
        }
        if (details.payment == 'debit') {
//            open_preload_notif('Masukkan Kartu Debit dan PIN Anda Pada EDC', 'source/insert_card_new.png');
            switch_frame('source/insert_card_new.png', 'Masukkan Kartu Debit dan PIN Anda Pada EDC', '', 'closeWindow|90', false )
            getDenom = parseInt(details.value);
            totalPrice = getDenom + adminFee;
            var structId = details.shop_type + details.epoch.toString();
            _SLOT.create_sale_edc_with_struct_id(totalPrice.toString(), structId);
//            notif_text = 'Masukan Kartu Debit dan Kode PIN Pada EDC Di Bawah';
            return;
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
                abc.counter -= 1;
                notice_no_change.modeReverse = (abc.counter % 2 == 0) ? true : false;
                if(abc.counter < 0){
                    if (details.payment=='cash' && !isPaid) {
                        _SLOT.stop_grg_receive_note();
                        if (receivedCash > 0){
                            print_failed_transaction('cash', 'PAYMENT_TIMEOUT');
    //                        _SLOT.start_return_es_mei();
                        }
    //                    _SLOT.start_dis_accept_mei();
                    }
                    my_timer.stop();
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }));
                }
            }
        }
    }

    CircleButton{
        id:back_button
        anchors.left: parent.left
        anchors.leftMargin: 100
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        button_text: 'BATAL'
        modeReverse: true
        z: 10
        visible: !popup_loading.visible && !global_frame.visible && !qr_payment_frame.visible

        MouseArea{
            anchors.fill: parent
            onClicked: {
                _SLOT.user_action_log('Press Cancel Button "Payment Process"');
                if (press != '0') return;
                press = '1';
                if (details.payment=='cash' && !isPaid) {
                    _SLOT.stop_grg_receive_note();
                    if (receivedCash > 0){
                        print_failed_transaction('cash', 'USER_CANCELLATION');
//                        _SLOT.start_return_es_mei();
                    }
//                    _SLOT.start_dis_accept_mei();
                }
                my_timer.stop()
                my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }));
            }
        }
    }

    //==============================================================
    //PUT MAIN COMPONENT HERE

    function open_preload_notif(msg, img){
        press = '0';
        if (msg==undefined) msg = 'Masukkan Uang Anda Pada Bill Acceptor';
        if (img==undefined) img = 'source/insert_money.png';
        switch_frame(img, msg, '', 'closeWindow', false )
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
        global_frame.withTimer = false;
        if (closeMode.indexOf('|') > -1){
            closeMode = closeMode.split('|')[0];
            var timer = closeMode.split('|')[1];
            global_frame.timerDuration = parseInt(timer);
            global_frame.withTimer = true;
        }
        global_frame.imageSource = imageSource;
        global_frame.textMain = textMain;
        global_frame.textSlave = textSlave;
        global_frame.closeMode = closeMode;
        global_frame.smallerSlaveSize = smallerText;
        global_frame.open();
    }


/*

    Text {
        id: main_title
        height: 100
        color: "white"
        visible: !standard_notif_view.visible
        text: (isPaid==true) ? "Pembayaran Berhasil" : "Pembayaran " + get_wording(details.payment)
        anchors.top: parent.top
        anchors.topMargin: 150
        wrapMode: Text.WordWrap
        font.bold: false
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenterOffset: 150
        font.family: "Ubuntu"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 45
    }

    Text {
        id: slave_title
        width: 900
        height: 300
        color: "white"
        visible: (isPaid && details.shop_type=='shop') ? true : false;
        text: "Silakan Ambil Struk Anda Di Bawah.\nJika Kartu Tidak Keluar, Silakan Hubungi Layanan Pelanggan."
        anchors.top: parent.top
        anchors.topMargin: 300
        wrapMode: Text.WordWrap
        font.bold: false
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenterOffset: 150
        font.family: "Ubuntu"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 30
    }

    Text {
        id: sub_slave_title
        width: 900
        height: 300
        color: "white"
        visible: isPaid
        text: "Simpan Kode Unik Anda ("+uniqueCode+"). Jika Struk Gagal Keluar, Tekan Tombol Berikut."
        anchors.top: parent.top
        anchors.topMargin: 425
        wrapMode: Text.WordWrap
        font.bold: false
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenterOffset: 150
        font.family: "Ubuntu"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 30
    }

    BackButton{
        id:reprint_button
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 355
        anchors.horizontalCenterOffset: 150
        anchors.horizontalCenter: parent.horizontalCenter
        z: 10
        visible: isPaid
        modeReverse: true
        button_text: 'cetak lagi'
        MouseArea{
            anchors.fill: parent
            enabled: (reprintAttempt<3) ? true : false
            onClicked: {
                _SLOT.user_action_log('Press Button "Cetak Lagi"');
                reprintAttempt += 1;
                parent.visible = false;
                _SLOT.start_reprint_global();
//                _SLOT.start_sale_print_global();
            }
        }
    }

    AnimatedImage{
        id: arrow_down2
        visible: isPaid
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        anchors.horizontalCenterOffset: 150
        anchors.horizontalCenter: parent.horizontalCenter
        source: "source/arrow_down.gif"
    }

    GroupBox{
        id: group_box_topup_success
        anchors.horizontalCenterOffset: 150
        anchors.verticalCenterOffset: -150
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        flat: true
        width: 1066
        height: 400
        visible: (isPaid && details.shop_type=='topup' && topupSuccess) ? true : false;
        Text {
            id: notif_saldo
            width: 600
            height: 200
            color: "white"
            visible: !standard_notif_view.visible
            text: "Isi Ulang Berhasil.\nSaldo Kartu Prabayar Anda\nRp. 0, -\nAmbil Struk Anda di Bawah."
            wrapMode: Text.WordWrap
            anchors.verticalCenter: parent.verticalCenter
            font.bold: false
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenterOffset: 200
            font.family: "Ubuntu"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 30
        }
        Image{
            id: image_prepaid_card
            source: "source/card_tj_original.png"
            width: 400
            height: 250
            anchors.horizontalCenterOffset: -300
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
                color: 'white'
//                text: FUNC.insert_space_four('6123321441233214')
            }
        }
    }

    Column{
        id: row_texts
        anchors.horizontalCenterOffset: 150
        visible: !isPaid
        anchors.verticalCenterOffset: -50
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 25
        TextDetailRow{
            id: _shop_type
            labelName: qsTr('Tipe Pembelian')
            labelContent: get_wording(details.shop_type)
            contentSize: 30
            labelSize: 30
            theme: 'white'
        }
        TextDetailRow{
            id: _provider
            labelName: qsTr('Tipe Kartu')
            labelContent: details.provider
            contentSize: 30
            labelSize: 30
            theme: 'white'
        }
        TextDetailRow{
            id: _nominal
            labelName: qsTr('Nominal')
            labelContent: 'Rp. ' +  FUNC.insert_dot(getDenom.toString()) + ',-';
            contentSize: 30
            labelSize: 30
            theme: 'white'
        }
        TextDetailRow{
            id: _jumlahUnit
            labelName: qsTr('Jumlah Unit')
            labelContent: details.qty;
            contentSize: 30
            labelSize: 30
            theme: 'white'
        }
        TextDetailRow{
            id: _biaya_admin
            visible: (details.shop_type=='topup') ? true : false;
            labelName: qsTr('Biaya Admin')
            labelContent: 'Rp. ' +  FUNC.insert_dot(adminFee.toString()) + ',-';
            contentSize: 30
            labelSize: 30
            theme: 'white'
        }
        TextDetailRow{
            id: _total_biaya
            labelName: qsTr('Total')
            labelContent: 'Rp. ' +  FUNC.insert_dot(totalPrice.toString()) + ',-';
            contentSize: 30
            labelSize: 30
            theme: 'white'
        }
        TextDetailRow{
            id: _uang_tunai
            labelName: qsTr('Uang Diterima')
            labelContent: 'Rp. ' + FUNC.insert_dot(receivedCash.toString()) + ',-';
            contentSize: 30
            labelSize: 30
            theme: 'white'
        }

    }

    Row{
        id: row_edc
        anchors.horizontalCenterOffset: 150
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 150
        visible: (details.payment=='debit' && !isPaid) ? true : false
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 25
        AnimatedImage{
            width: 300; height: 200;
            source: "source/insert_card_realistic.jpg"
            fillMode: Image.PreserveAspectFit
        }
        AnimatedImage{
            width: 300; height: 200;
            source: "source/input_card_pin_realistic.jpeg"
            fillMode: Image.PreserveAspectFit
        }
    }

    Row{
        id: row_note_cash
        property int adjust_point: 75
        width: 500
        height: 100
        layoutDirection: Qt.LeftToRight
        anchors.horizontalCenterOffset: 150
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 175
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 30
        visible: (details.payment=='cash' && !isPaid && !standard_notif_view.visible) ? true : false
        Image{
            id: img_count_100
            width: 100; height: 100
            source: "source/denom_100k.png"
            fillMode: Image.PreserveAspectFit
        }
        Image{
            id: img_count_50
            width: 100; height: 100;
            source: "source/denom_50k.png"
            fillMode: Image.PreserveAspectFit
        }
        Image{
            id: img_count_20
           width: 100; height: 100;
            source: "source/denom_20k.png"
            fillMode: Image.PreserveAspectFit
        }
        Image{
            id: img_count_10
            width: 100; height: 100;
            source: "source/denom_10k.png"
            fillMode: Image.PreserveAspectFit
        }
//        Image{
//            id: img_count_5
//            width: 100; height: 50;
//            rotation: 30
//            source: "source/5rb.png"
//            fillMode: Image.PreserveAspectFit
//        }
//        Image{
//            id: img_count_2
//            width: 100; height: 50;
//            rotation: 30
//            source: "source/2rb.png"
//            fillMode: Image.PreserveAspectFit
//        }

    }

    AnimatedImage{
        id: arrow_down
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 25
        anchors.right: parent.right
        anchors.rightMargin: 50
        source: "source/arrow_down.gif"
    }

    Rectangle{
        id: rec_notif
        visible: (!isPaid && details.shop_type=='shop') ? true : false;
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"
        radius: 30
        anchors.horizontalCenterOffset: 150
        border.width: 0
        opacity: 0.7
        width: 1000
        height: 100
        Text {
            id: process_notif
            anchors.fill: parent
            color: "#ffffff"
            text: "*" + notif_text
            wrapMode: Text.WordWrap
            font.italic: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenterOffset: 0
            font.family:"Ubuntu"
            font.pixelSize: 30
        }

    }

    */


    MainTitle{
        anchors.top: parent.top
        anchors.topMargin: 250
        anchors.horizontalCenter: parent.horizontalCenter
        show_text: 'Silakan Masukkan Uang Anda'
        size_: 50
        color_: "white"
        visible: !global_frame.visible && !popup_loading.visible && !qr_payment_frame.visible

    }

    Text {
        id: label_money_in
        color: "white"
        text: "Uang Masuk                       :"
        anchors.top: parent.top
        anchors.topMargin: 400
        anchors.left: parent.left
        anchors.leftMargin: 200
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"Ubuntu"
        font.pixelSize: 50
        visible: !global_frame.visible && !popup_loading.visible && !qr_payment_frame.visible
    }

    Text {
        id: content_money_in
        color: "white"
        text: (receivedCash==0) ? 'Rp 0' : 'Rp ' + FUNC.insert_dot(receivedCash.toString())
        anchors.right: parent.right
        anchors.rightMargin: 350
        anchors.top: parent.top
        anchors.topMargin: 400
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.family:"Ubuntu"
        font.pixelSize: 50
        visible: !global_frame.visible && !popup_loading.visible && !qr_payment_frame.visible
    }

    Text {
        id: label_target_money
        color: "white"
        text: "Total Pembayaran             :"
        anchors.top: parent.top
        anchors.topMargin: 550
        anchors.left: parent.left
        anchors.leftMargin: 200
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"Ubuntu"
        font.pixelSize: 50
        visible: !global_frame.visible && !popup_loading.visible && !qr_payment_frame.visible
    }

    Text {
        id: content_balance
        color: "white"
        text: 'Rp ' + FUNC.insert_dot(totalPrice.toString())
        anchors.right: parent.right
        anchors.rightMargin: 350
        anchors.top: parent.top
        anchors.topMargin: 550
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.family:"Ubuntu"
        font.pixelSize: 50
        visible: !global_frame.visible && !popup_loading.visible && !qr_payment_frame.visible
    }

    BoxTitle{
        id: notice_no_change
        width: 1200
        height: 120
        visible: !isPaid && (details.payment=='cash')
        radius: 50
        fontSize: 30
        border.width: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 200
        anchors.horizontalCenter: parent.horizontalCenter
        title_text: 'JIKA TERJADI GAGAL/BATAL TRANSAKSI\nPENGEMBALIAN DANA DIALIHKAN KE AKUN ANDA ' + customerPhone+ ' (Powered By DUWIT)'
//        modeReverse: (abc.counter %2 == 0) ? true : false
        boxColor: CONF.frame_color

    }

    //==============================================================

    StandardNotifView{
        id: standard_notif_view
        withBackground: false
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
                if (modeButtonPopup=='check_balance'){
                    popup_loading.open();
                    _SLOT.start_check_balance();
                }
                if (modeButtonPopup=='do_topup'){
                    popup_loading.open();
                    perform_do_topup();
                }
                if (modeButtonPopup=='retrigger_grg') {
                    _SLOT.start_grg_receive_note();
                }
                if (modeButtonPopup=='reprint') {
                    _SLOT.start_reprint_global();
                }
                parent.visible = false;
            }
        }
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
            anchors.rightMargin: (centerOnlyButton) ? 825 : 100
            anchors.bottom: parent.bottom
            anchors.bottomMargin: (centerOnlyButton) ? 100 : 50
            button_text: 'LANJUT'
            modeReverse: true
            visible: frameWithButton || centerOnlyButton
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press "LANJUT"');
                    if (press!='0') return;
                    press = '1'
                    switch(modeButtonPopup){
                    case 'retrigger_grg':
                        _SLOT.start_grg_receive_note();
                        open_preload_notif();
                        break;
                    case 'do_topup':
                        perform_do_topup();
                        popup_loading.open();
                        break;
                    case 'reprint':
                        _SLOT.start_reprint_global();
                        popup_loading.open();
                        break;
                    case 'retrigger_card':
                        var attempt = details.status.toString();
                        _SLOT.start_multiple_eject(attempt, attemptCD.toString());
                        centerOnlyButton = false;
                        popup_loading.open();
                        break;
                    case 'check_balance':
                        _SLOT.start_check_balance();
                        popup_loading.open();
                        break;
                    }
                }
            }
        }
    }


    QRPaymentFrame{
        id: qr_payment_frame
    }

    function get_signal_frame(s){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('get_signal_frame', s, now);
        var res = s.split('|')[1];
        set_refund_number(res);
        next_button_input_number.visible = true;
    }


   function set_refund_number(n){
       var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
       customerPhone = n;
       details.refund_number = customerPhone;
       console.log('customerPhone as refund_number', customerPhone, now);
   }


    PopupInputNumber{
        id: popup_input_number
//        calledFrom: 'general_payment_process'
        handleButtonVisibility: next_button_input_number

        CircleButton{
            id: cancel_button_input_number
            anchors.left: parent.left
            anchors.leftMargin: 100
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            button_text: 'BATAL'
            modeReverse: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press "BATAL" in Input Whatsapp Number');
                    popup_input_number.close()
                    my_layer.pop();
                }
            }
        }

        CircleButton{
            id: next_button_input_number
            anchors.right: parent.right
            anchors.rightMargin: 100
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            button_text: 'LANJUT'
            modeReverse: true
            visible: false
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    if (press != '0') return;
                    press = '1';
                    _SLOT.user_action_log('Press "LANJUT" Input Whatsapp Number ' + customerPhone);
                    if (popup_input_number.handleButtonVisibility!=undefined){
                        set_refund_number(popup_input_number.numberInput);
                    }
                    popup_input_number.close();
                    define_first_notif();
                }
            }
        }
    }

}

