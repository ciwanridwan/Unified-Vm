import QtQuick 2.4
import QtQuick.Controls 1.3
import "base_function.js" as FUNC

Base{
    id: select_payment
    mode_: "reverse"
    isPanelActive: true
    textPanel: qsTr("Select Available Payment")
    imgPanel: "aAsset/pembayaran_putih.png"
    imgPanelScale: 0.8
    property int timer_value: 360
    property var amount
    property var product
    property var useMode: "TICKET_FLIGHT" //["TICKET","PARKIR","OTHER"]
    property bool isReadyEDC: false
    property bool isReadyMEI: false
    property bool isReadyQPROX: false
    property var departDate//: "2018-10-01"
    property var returnDate//: "2018-12-03"
    property var flightNoDepart//: "JT 8120"
    property var flightNoReturn//: "ID 120"
    property var fromToDepart//: "CGK - BTH"
    property var fromToReturn//: "BTH - CGK"
    property var flightTimeDepart//: "12:00 - 14:00"
    property var flightTimeReturn//: "14:00 - 18:00"
    property var selectedChart
    property var orderList//: ["adt", "cnn", "inf"]
    property var selectedPrice//: [1, 2]
    property var originFrom//: "CGK"//"Tangerang - CGK" //undefined
    property var destinationTo//: "DPS" //"Batam - BTH" //undefined
    property var flightDetailsDepart//: undefined
    property var flightDetailsReturn//: undefined
    property var bookingCodeDepart// : "YUDIOK" //undefined
    property var bookingCodeReturn// : "OKYUDI" //undefined
    property var priceDepart: "0"
    property var priceReturn: "0"
    property var baseFare: "0"
    property var totalPaid: "0"
    property var press: "0"
    property var adminFee: "25000"
    property var surchargeFee: "0"
    property var selectedPayment: undefined
    property var airportNameList: []
    property bool isPaid: false
    property bool isAborted: false
    property var languange_: base.language
    property var customerInfo
    property int defaultMargin: 3
    property var defaultAdminFee: "0"
    property bool cancelAble: true
    property bool confirmAble: true
    property var defaultCancel: 'store' //['return', 'store']
    property var adminKey: undefined
    signal abortPayment(string str)
    signal releaseButton(string str)

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
//            console.log("customerInfo : ", customerInfo)
            loading_view.open();
            reset_value();
//            console.log("selected_chart : ", selectedChart)
            console.log("selected_price : ", selectedPrice)
            _SLOT.start_get_device_status();
            _SLOT.get_kiosk_price_setting();
            _SLOT.start_get_admin_key();
            _SLOT.start_check_wallet('1');
//            _SLOT.start_send_details_passenger()
            handle_passenger(customerInfo);
            abc.counter = timer_value;
            my_timer.start();
            payment_view.visible = false;
            notif_view.close();
            if(useMode=="TICKET_FLIGHT"){
                init_data_ticket(flightDetailsDepart, flightDetailsReturn);
            } else {
                init_data_global(product);
            }
        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop();
            loading_view.close();
            reset_value();
        }
    }

    Component.onCompleted:{
        releaseButton.connect(free_button);
        abortPayment.connect(abort_payment);
        base.result_get_device.connect(define_device);
        base.result_sale_edc.connect(edc_payment_result);
        base.result_accept_mei.connect(mei_payment_result);
        base.result_dis_accept_mei.connect(mei_payment_result);
        base.result_stack_mei.connect(mei_payment_result);
        base.result_return_mei.connect(mei_payment_result);
        base.result_store_es_mei.connect(mei_payment_result);
        base.result_return_es_mei.connect(mei_payment_result);
        base.result_dispense_cou_mei.connect(mei_payment_result);
        base.result_float_down_cou_mei.connect(mei_payment_result);
        base.result_dispense_val_mei.connect(mei_payment_result);
        base.result_float_down_all_mei.connect(mei_payment_result);
        base.result_init_qprox.connect(qprox_payment_result);
        base.result_debit_qprox.connect(qprox_payment_result);
        base.result_auth_qprox.connect(qprox_payment_result);
        base.result_balance_qprox.connect(qprox_payment_result);
        base.result_topup_qprox.connect(qprox_payment_result);
        base.result_ka_info_qprox.connect(qprox_payment_result);
        base.result_online_info_qprox.connect(qprox_payment_result);
        base.result_init_online_qprox.connect(qprox_payment_result);
        base.result_stop_qprox.connect(qprox_payment_result);
        base.result_airport_name.connect(airport_name_result);
        base.result_general.connect(handle_general);
        base.result_passenger.connect(handle_passenger);
        base.result_price_setting.connect(price_setting);
        base.result_create_payment.connect(process_final_payment);
        base.result_admin_key.connect(handle_key);
        base.result_wallet_check.connect(handle_wallet);
    }

    Component.onDestruction:{
        releaseButton.disconnect(free_button);
        abortPayment.disconnect(abort_payment);
        base.result_get_device.disconnect(define_device);
        base.result_sale_edc.disconnect(edc_payment_result);
        base.result_accept_mei.disconnect(mei_payment_result);
        base.result_dis_accept_mei.disconnect(mei_payment_result);
        base.result_stack_mei.disconnect(mei_payment_result);
        base.result_return_mei.disconnect(mei_payment_result);
        base.result_store_es_mei.disconnect(mei_payment_result);
        base.result_return_es_mei.disconnect(mei_payment_result);
        base.result_dispense_cou_mei.disconnect(mei_payment_result);
        base.result_float_down_cou_mei.disconnect(mei_payment_result);
        base.result_dispense_val_mei.disconnect(mei_payment_result);
        base.result_float_down_all_mei.disconnect(mei_payment_result);
        base.result_init_qprox.disconnect(qprox_payment_result);
        base.result_debit_qprox.disconnect(qprox_payment_result);
        base.result_auth_qprox.disconnect(qprox_payment_result);
        base.result_balance_qprox.disconnect(qprox_payment_result);
        base.result_topup_qprox.disconnect(qprox_payment_result);
        base.result_ka_info_qprox.disconnect(qprox_payment_result);
        base.result_online_info_qprox.disconnect(qprox_payment_result);
        base.result_init_online_qprox.disconnect(qprox_payment_result);
        base.result_stop_qprox.disconnect(qprox_payment_result);
        base.result_airport_name.disconnect(airport_name_result);
        base.result_general.disconnect(handle_general);
        base.result_passenger.disconnect(handle_passenger);
        base.result_price_setting.disconnect(price_setting);
        base.result_create_payment.disconnect(process_final_payment);
        base.result_admin_key.disconnect(handle_key);
        base.result_wallet_check.disconnect(handle_wallet);
    }

    function handle_wallet(w){
        console.log('[INFO] Wallet Check : ' + w);
        if (selectedPayment==undefined) return; // To Handle First Wallet Check
        loading_view.close()
        popup_login.textInput = '';
        popup_login.clickAble = false;
        if (w=='ERROR'){
            notif_view.show_text = (language=='INA') ? 'Mohon Maaf' : 'We`re Apologize';
            notif_view.show_detail = (language=='INA') ? 'Terjadi Kesalahan Saat Memerksa Saldo' : 'Something Wrong when Checking the Wallet.' ;
            notif_view.isSuccess = false;
            notif_view.z = 100;
            notif_view.escapeFunction = "backToMain";
            notif_view.open();
            return
        }
        var wallet = JSON.parse(w);
        if (wallet.result == 'OK'){
            _SLOT.start_create_payment(baseFare);
            _SLOT.start_generate('TICKET_WALLET');
            success_payment();
        } else {
            //-----------------------------------------------------------
            selectedPayment = undefined;
            button_rec_edc.color = "white";
            button_rec_mei.color = "white";
            button_rec_qprox.color = "white";
            press = "0";
            adminFee = "25000";
            surchargeFee = (FUNC.round_fare(baseFare) * 0.03).toString();
            admin_fee_text.text = "";
            total_payment_text.text = "";
            totalPaid = "0";
            //-----------------------------------------------------------
            var minus = FUNC.insert_dot(wallet.minus.toString())
            notif_view.show_text = (language=='INA') ? 'Mohon Maaf' : 'We`re Apologize';
            notif_view.show_detail = (language=='INA') ? 'Saldo Admin Tidak Cukup Untuk Transaksi Ini\n[ '+minus+' ]' : 'The Available Wallet Is Not Sufficient For This Transaction\n[ '+minus+' ]' ;
            notif_view.isSuccess = false;
            notif_view.z = 100;
            notif_view.escapeFunction = "closeWindow";
            notif_view.open();
            abc.counter = timer_value;
            my_timer.restart();

        }

    }

    function handle_key(k){
        console.log('[INFO] Admin Key : ' + k);
        adminKey = k;
    }

    function process_final_payment(result){
        console.log('process_final_payment', result)
//        payment_view.modeConfirm = false;
//        if (result=='SUCCESS'){
//            _SLOT.start_store_es_mei();
//            payment_view.modeLoading = true;
//        } else {
//            payment_view.visible = false;
//            failed_payment_view.open();
//            clear_payment_session();
//            // TODO Change to Confirm View
//            abort_payment('VEDALEON_PAYMENT_FAIL');
//        }
    }

    function price_setting(s){
        // TODO check below function
        console.log("price_setting : ", JSON.stringify(s));
        var _s = JSON.parse(s);
        defaultMargin = parseInt(_s.margin);
        adminFee = _s.adminFee.toString();
        defaultAdminFee = adminFee;
        if (_s.cancelAble=='0') cancelAble = false;
        if (_s.confirmAble=='0') confirmAble = false;
    }

    function clear_payment_session(method){
        if (selectedPayment=="EDC"||method=="EDC"){
            button_rec_edc.color = "white";
            payment_view.meiTextMode = "normal";
            payment_view.modeLoading = false;
            payment_view.visible = false;
            selectedPayment = undefined;
            _SLOT.start_disconnect_edc();
            return false;
        }
        if (selectedPayment=="QPROX"||method=="QPROX"){
            button_rec_qprox.color = "white";
            selectedPayment = undefined;
            _SLOT.start_disconnect_qprox();
            return false;
        }
        if (selectedPayment=="MEI"||method=="MEI"){
            if (payment_view.totalGetCount!="0"){
                if (defaultCancel=='return') {
                    _SLOT.start_return_es_mei();
                    console.log("[debug] return_es from abort_transaction");
                } else {
                    isAborted = true;
                    _SLOT.start_store_es_mei();
                    payment_view.modeLoading = true;
                    payment_view.visible = true;
                }
                console.log("[debug] return_es from clear_payment_session");
            } else {
                _SLOT.start_disconnect_mei();
            }
            button_rec_mei.color = "white";
            selectedPayment = undefined;
            return false;
        }
        if (selectedPayment===undefined) return true;
    }

    function reset_button_payment(s){
        if (s=='EDC'){
            button_rec_edc.color = "gray";
            button_rec_mei.color = "white";
            button_rec_qprox.color = "white";
        } else if (s=='QPROX'){
            button_rec_edc.color = "white";
            button_rec_mei.color = "white";
            button_rec_qprox.color = "gray";
        } else if (s=='MEI'){
            button_rec_edc.color = "white";
            button_rec_mei.color = "gray";
            button_rec_qprox.color = "white";
        }
        //Add Press Button Handling
        press = '0';
        //=========================
    }

    function free_button(free){
        console.log("[info] release button from : ", free);
//        loading_view.show_text = qsTr('Closing Previous Payment Session')
//        loading_view.open()
        if (payment_view.escapeFunction=='forceClose') payment_view.visible = false;
        clear_payment_session(free);
        press = "0";
        adminFee = "25000";
        surchargeFee = (FUNC.round_fare(baseFare) * 0.03).toString();
        admin_fee_text.text = "";
        total_payment_text.text = "";
        totalPaid = "0";
        abc.counter = timer_value;
        my_timer.restart();
    }

    function abort_payment(status){
        console.log('[info] abort_payment by ', status);
        notif_view.escapeFunction = 'backToMain'
        notif_view.show_detail = qsTr("Transaction is cancelled by user. Please Wait for the cash return.")
        notif_view.isSuccess = false
        notif_view.escapeFunction = 'closeWindow'
        notif_view.open()
    }

    function reset_value(){
        priceDepart = "0";
        priceReturn = "0";
        press = "0";
        totalPaid = "0";
        baseFare = "0";
        isPaid = false;
        isAborted = false;
        selectedPayment = undefined;
        payment_view.meiTextMode = "normal";
        payment_view.modeLoading = false;
        payment_view.mode55 = false;
        payment_view.modeConfirm = false;
        payment_view.totalGetCount = "0";
    }

    function handle_passenger(passenger){
        console.log('passenger_data : ', passenger)
//        var string_passenger = passenger.toString().replace(',', '\n')
        var new_string = passenger.join(", ")
        passenger_text_content.text = new_string
        rec_passenger_text_title.visible = true
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
        if (result=='CLOSE_LOADING'){
//            loading_view.close()
            payment_view.visible = false;
        }
    }

    function abort_transaction(s){
        isAborted = true;
        if (s=="MEI") {
            if (payment_view.totalGetCount!="0"){
                if(isPaid==false){
                    if (defaultCancel=='return') {
                        _SLOT.start_return_es_mei();
                        console.log("[debug] return_es from abort_transaction");
                    } else {
                        isAborted = true;
                        _SLOT.start_store_es_mei();
                        payment_view.modeLoading = true;
                        payment_view.visible = true;
                    }
                }
            } else {
                _SLOT.start_disconnect_mei();
//                console.log("disconnect_mei from abort_transaction");
            }
        }
        if (s=="EDC") _SLOT.start_disconnect_edc();
        if (s=="QPROX") _SLOT.start_disconnect_qprox();
    }

    function abort_timeout(s){
        isAborted = true;
        if (s=="MEI") {
            if (payment_view.totalGetCount!="0"){
                if (defaultCancel=='return') {
                    _SLOT.start_return_es_mei();
                    console.log("[debug] return_es from abort_transaction");
                } else {
                    _SLOT.start_store_es_mei();
                    payment_view.modeLoading = true;
                    payment_view.visible = true;
                    //abort_store_mei_transaction();
                }
            } else {
                _SLOT.start_disconnect_mei();
            }
        }
        if (s=="EDC") _SLOT.start_disconnect_edc();
        if (s=="QPROX") _SLOT.start_disconnect_qprox();
    }

    function abort_store_mei_transaction(){
        _SLOT.start_generate('TICKET_MEI');
        _SLOT.start_disconnect_mei();
        notif_view.show_detail = qsTr("Cancellation Process is Completed. Please Get The Printed Cancel Receipt Below.")
        notif_view.isSuccess = false
        notif_view.escapeFunction = 'backToMain'
        payment_view.totalGetCount = "0";
        payment_view.mode55 = false;
        payment_view.visible = false;
        notif_view.open()
        abc.counter = 5
    }

    function airport_name_result(text){
//        console.log("airport_from_city : ", base.raw_origin);
//        console.log("airport_to_city : ", base.raw_destination);

        if (text=="" || text.length < 1) return
        var a = JSON.parse(text);
        for (var i=0; i < a.length; i++){
            airportNameList.push(a[i].name)
        }
        var airportFrom = airportNameList[0]
        var airportTo = airportNameList[1]

        //Override airportFrom and AirportTo
        airportFrom = FUNC.change_renaming(base.raw_origin)
        airportTo = FUNC.change_renaming(base.raw_destination)
//        origin_text_depart.text = originFrom + " to " + destinationTo
        var fixTextDepart = details_depart_text.text.replace(originFrom, airportFrom)
        fixTextDepart = fixTextDepart.replace(destinationTo, airportTo)
//        var get_origin = base.raw_origin;
//        fixTextDepart = fixTextDepart.replace(destinationTo, FUNC.change_renaming(get_origin))
//        base.raw_origin = undefined

        details_depart_text.text = fixTextDepart

        var fixTextReturn = details_return_text.text.replace(originFrom, airportTo)
        fixTextReturn = fixTextReturn.replace(destinationTo, airportFrom)
//        var get_destination = base.raw_destination;
//        fixTextDepart = fixTextDepart.replace(destinationTo, FUNC.change_renaming(get_destination))
//        base.raw_destination = undefined

        details_return_text.text = fixTextReturn

//        console.log("airport_name : ", airportNameList);
        console.log("airport_from : ", airportFrom);
        console.log("airport_to : ", airportTo);
    }

    function edc_payment_result(r){
        console.log("edc_payment_result : ", r)
        if (r==undefined||r==""||r.indexOf("ERROR") > -1){
            not_ready_device();
        }
        if (r=='SALE|RECOVERY'){
            _SLOT.create_sale_edc(totalPaid);
            return;
        }
        var edcFunction = r.split('|')[0]
        var edcResult = r.split('|')[1]
        if (edcFunction=="SUCCESS") {
            _SLOT.start_create_payment(baseFare);
            success_payment();
        } else {
            if (payment_view.visible==false) payment_view.visible = true;
            payment_view.styleText = true
            switch(edcResult){
            case 'SR':
                if (base.language == 'INA'){
                    payment_view.show_text = qsTr('Mohon Tunggu, Sedang Mensinkronisasi Ulang.');
                } else {
                    payment_view.show_text = qsTr('Please Wait, It is being re-synced.');
                }
                _SLOT.start_edc_settlement();
//                _SLOT.create_sale_edc(totalPaid);
                break;
            case 'CI':
                if (base.language == 'INA'){
                    payment_view.show_text = qsTr('Silakan Masukan Kartu Anda Di Slot Tersedia.');
                } else {
                    payment_view.show_text = qsTr('Please Insert Your Card Into The Card Slot.');
                }
                payment_view.escapeFunction = 'forceClose';
                break;
            case 'PI':
                if (base.language == 'INA'){
                    payment_view.show_text = qsTr('Kartu Terdeteksi, Silakan Masukkan Kode PIN.');
                } else {
                    payment_view.show_text = qsTr('Card Inserted, Please Key In Your PIN.');
                }
                payment_view.escapeFunction = 'forceClose';
                break;
            case 'DO':
                if (base.language == 'INA'){
                    payment_view.show_text = qsTr('Kode Pin Diterima, Menunggu Balasan Sistem.');
                } else {
                    payment_view.show_text = qsTr('PIN Received, Waiting For System Response.');
                }
                payment_view.cancelButton = false;
                break;
            case 'TC':
                if (base.language == 'INA'){
                    payment_view.show_text = qsTr('Mohon Maaf, Terjadi Pembatalan Pada Proses Pembayaran.');
                } else {
                    payment_view.show_text = qsTr('Unfortunately, Payment Process is Cancelled.');
                }
                payment_view.cancelButton = true;
                payment_view.escapeFunction = 'forceClose';
                break;
            case 'CO':
                if (base.language == 'INA'){
                    payment_view.show_text = qsTr('Silakan Ambil Kembali Kartu Anda Dari Slot.');
                } else {
                    payment_view.show_text = qsTr('Please Take Back Your Card Safely From The Slot.');
                }
//                payment_view.cancelButton = true;
                break;
            case 'CR#EXCEPTION': case 'CR#UNKNOWN':
                if (base.language == 'INA'){
                    payment_view.show_text = qsTr('Terjadi Suatu Kesalahan, Transaksi Anda Dibatalkan.');
                } else {
                    payment_view.show_text = qsTr('Something Went Wrong, Your Transaction is Cancelled.');
                }
                payment_view.cancelButton = true;
                payment_view.escapeFunction = 'forceClose';
                break;
            case 'CR#CARD_ERROR':
                if (base.language == 'INA'){
                    payment_view.show_text = qsTr('Terjadi Kesalahan Pada Kartu, Transaksi Anda Dibatalkan.');
                } else {
                    payment_view.show_text = qsTr('Something Wrong With Your Card, Your Transaction is Cancelled.');
                }
                payment_view.cancelButton = true;
                payment_view.escapeFunction = 'forceClose';
                break;
            case 'CR#PIN_ERROR':
                if (base.language == 'INA'){
                    payment_view.show_text = qsTr('Terjadi Kesalahan Pada PIN, Transaksi Anda Dibatalkan.');
                } else {
                    payment_view.show_text = qsTr('Your PIN Code is Wrong, Your Transaction is Cancelled.');
                }
                payment_view.cancelButton = true;
                payment_view.escapeFunction = 'forceClose';
                break;
            case 'CR#SERVER_ERROR':
                if (base.language == 'INA'){
                    payment_view.show_text = qsTr('Terjadi Kesalahan Pada Sistem, Transaksi Anda Dibatalkan.');
                } else {
                    payment_view.show_text = qsTr('Something Wrong with The System, Your Transaction is Cancelled.');
                }
                payment_view.cancelButton = true;
                payment_view.escapeFunction = 'forceClose';
                break;
            case 'CR#NORMAL_CASE':
                if (base.language == 'INA'){
                    payment_view.show_text = qsTr('Silakan Ambil Kembali Kartu Anda untuk Melanjutkan Transaksi.');
                } else {
                    payment_view.show_text = qsTr('Please Take Back Your Card to Proceed.');
                }
                payment_view.cancelButton = true;
                break;
            default:
//                payment_view.show_text = edcResult;
//                payment_view.cancelButton = true;
                break;
            }
        }
//        _SLOT.start_disconnect_edc()
    }

    function define_device(status){
        console.log("device_status :", status);
        var s = JSON.parse(status);
        if (s.EDC=="AVAILABLE") isReadyEDC = true;
        if (s.QPROX=="AVAILABLE") isReadyQPROX = true;
        if (s.MEI=="AVAILABLE") isReadyMEI = true;
    }

    function init_data_global(p){
        console.log(p)
        if(p==undefined||p=="") return
        //TODO Parsing Product Data
        var info = JSON.parse(p)
        text_info_1.text = qsTr("Total Amount :\n") + FUNC.insert_dot(amount)
        text_info_2.text = qsTr("Payment : ") + useMode
        text_info_3.text = qsTr("Description :\n") + p.details
    }

    function init_data_ticket(dep, ret){
        console.log(dep, ret)
//        if(q==undefined||q=="") return
        //TODO Parsing Product Data
//        totalAmount = (parseInt(priceDepart) + parseInt(priceReturn)).toString()
//        var info = JSON.parse(q)
//        ticket_info_1.text = "Total Amount :\n" + FUNC.insert_dot(amount)
//        ticket_info_2.text = "Payment : " + useMode
//        ticket_info_3.text = "Description :\n" + p.details
        var fd = JSON.parse(dep)
        departDate = fd.departDate
        flightNoDepart = fd.flightNo
        fromToDepart = fd.fromTo
        flightTimeDepart = fd.flightTime
        originFrom = fd.originFrom
        destinationTo = fd.destinationTo
        _SLOT.start_get_airport_name(originFrom, destinationTo)
        bookingCodeDepart = fd.bookingCode
        priceDepart = fd.price
        bc_text.text = qsTr("Booking Code : ") + bookingCodeDepart
        img_flight_logo.source = FUNC.get_flight_logo(flightNoDepart)
        flightNo_text.text = flightNoDepart
        text_info_depart.text = qsTr("Departure Information : ") + " " + departDate
//        origin_text_depart.text = originFrom + qsTr(" to ") + destinationTo
        origin_text_depart.text = (fd.withTransit==1) ? fromToDepart + " [Transit]": fromToDepart
        var terminal_depart = "Terminal " + fd.terminal_depart
        if (terminal_depart=="") terminal_depart = qsTr("Departure Terminal")
        if (fd.withTransit != 1) {
            if (destinationTo=='CGK'){
                details_depart_text.text = qsTr("From : ") + originFrom + ", " + qsTr("Departure : ") +
                        flightTimeDepart.split(" - ")[0] + qsTr(" (Local Time)") + "\n" +
                        qsTr("To : ") + destinationTo + ", " + qsTr("Arrival : ") +
                        flightTimeDepart.split(" - ")[1] + qsTr(" (Local Time)") + ", " + terminal_depart
            } else {
                details_depart_text.text = qsTr("From : ") + originFrom + ", " + qsTr("Departure : ") +
                        flightTimeDepart.split(" - ")[0] + qsTr(" (Local Time)") + ", " + terminal_depart + "\n" +
                        qsTr("To : ") + destinationTo + ", " + qsTr("Arrival : ") +
                        flightTimeDepart.split(" - ")[1] + qsTr(" (Local Time)")
            }
        } else {
            var transitDetailsDepart = fd.transitDetails
            if (destinationTo=='CGK'){
                details_depart_text.text = qsTr("From : ") + originFrom + ", " +
                        qsTr("Departure : ") + flightTimeDepart.split(" - ")[0] + qsTr(" (Local Time)") + " " +
                        transitDetailsDepart + " \n" + qsTr("To : ") + destinationTo + ", " + qsTr("Arrival : ") +
                        transitDetailsDepart.substring(transitDetailsDepart.length-5) + qsTr(" (Local Time)") + ", " +
                        terminal_depart
            } else {
                details_depart_text.text = qsTr("From : ") + originFrom + ", " +
                        qsTr("Departure : ") + flightTimeDepart.split(" - ")[0] + qsTr(" (Local Time)") + ", " +
                        terminal_depart + " " + transitDetailsDepart + " \n" + qsTr("To : ") + destinationTo + ", " +
                        qsTr("Arrival : ") + transitDetailsDepart.substring(transitDetailsDepart.length-5) + qsTr(" (Local Time)")
            }
        }

        date_text_depart.text = qsTr("Date : ") + departDate
        time_departure_depart.text = qsTr("Departure : ") + flightTimeDepart.split(" - ")[0] + qsTr(" (Local Time)")
        time_arrival_depart.text = qsTr("Arrival : ") + flightTimeDepart.split(" - ")[1] + qsTr(" (Local Time)")

        if (ret!=undefined){
            var fr = JSON.parse(ret)
            returnDate = fr.returnDate;
            bookingCodeReturn = fr.bookingCode;
            flightNoReturn = fr.flightNo;
            flightTimeReturn = fr.flightTime;
            priceReturn = fr.price;
            groupReturnInfo.visible = true;
            bc_text_return.text = qsTr("Booking Code : ") + bookingCodeReturn;
            img_flight_logo_return.source = FUNC.get_flight_logo(flightNoReturn);
            flightNo_text_return.text = flightNoReturn;
            text_info_return.text = qsTr("Return Information : ") + " " + returnDate
//            destination_origin_text.text = destinationTo + qsTr(" to ") + originFrom
            destination_origin_text.text = (fr.withTransit==1) ? fr.fromTo + " [Transit]": fr.fromTo
            var terminal_return = fr. terminal_return
            if (terminal_return=="") terminal_return = qsTr("Arrival Terminal")
            if (fr.withTransit != 1){
                details_return_text.text = qsTr("From : ") + originFrom + ", " + qsTr("Departure : ") +
                        flightTimeReturn.split(" - ")[0] + qsTr(" (Local Time)") + "\n" +
                        qsTr("To : ") + destinationTo + ", " + qsTr("Arrival : ") +
                        flightTimeReturn.split(" - ")[1] + qsTr(" (Local Time)") + ", " + terminal_return
            } else {
                var transitDetailsReturn = fr.transitDetails
                details_return_text.text = qsTr("From : ") + originFrom + ", " + qsTr("Departure : ") +
                        flightTimeReturn.split(" - ")[0] + qsTr(" (Local Time)") + " " + transitDetailsReturn + "\n" +
                        qsTr("To : ") + destinationTo + ", " + qsTr("Arrival : ") +
                        transitDetailsReturn.substring(transitDetailsReturn.length-5) + qsTr(" (Local Time)") + ", " +
                        terminal_return

            }
            date_text_return.text = qsTr("Date : ") + returnDate
            time_departure_return.text = qsTr("Departure : ") + flightTimeReturn.split(" - ")[0] + qsTr(" (Local Time)")
            time_arrival_return.text = qsTr("Arrival : ") + flightTimeReturn.split(" - ")[1] + qsTr(" (Local Time)")
        }
        baseFare = amount
//        totalPaid = (FUNC.round_fare(baseFare) + parseInt(adminFee)).toString()
//        _SLOT.set_rounded_fare(totalPaid)
//        console.log("baseFare : ", baseFare, " totalAmount : ", totalPaid,
//                    " margin : ", (parseInt(totalPaid) - parseInt(baseFare)).toString())
        loading_view.close()
    }

    function not_ready_device(){
        payment_view.visible = false;
        notif_view.show_detail = qsTr("This payment is not available this time.");
        notif_view.isSuccess = false;
        notif_view.escapeFunction = 'closeWindow';
        notif_view.open();
        press = "0";
    }

    function not_open_session(){
        notif_view.show_detail = qsTr("Closing previous payment session. Please collect back the inserted cash if any.");
        notif_view.isSuccess = false
        notif_view.escapeFunction = 'closeWindow'
        notif_view.open()
        press = "0"
    }

    function mei_payment_result(r){
//        console.log("mei_payment_result : ", r)
        var meiFunction = r.split('|')[0]
        var meiResult = r.split('|')[1]
        if (r==undefined||r==""||meiResult=="ERROR"||meiResult=="TIMEOUT"){
//            _SLOT.start_disconnect_mei()
            notif_view.isSuccess = false
            if (meiResult=="TIMEOUT"){
                notif_view.show_detail = qsTr("We're apologize, Your payment session is expired. Your inserted cash will be rejected.")
//                _SLOT.start_return_es_mei()
            } else {
                notif_view.show_detail =  meiFunction + " result : " + r
            }
            notif_view.z = 100
            notif_view.escapeFunction = "closeWindow"
            notif_view.open()
        }
        switch(meiFunction){
        case "ACCEPT":
            console.log("ACCEPT FUNCTION : ", meiResult);
            if(meiResult=='ERROR'){
                not_ready_device();
                reset_button_payment();
            };
            break;
        case "DIS_ACCEPT":
            console.log("DIS_ACCEPT FUNCTION : ", meiResult);
            if (meiResult=='SUCCESS'){
//                if(payment_view.totalGetCount != '0'){
//                } else if (parseInt(payment_view.totalGetCount)>=parseInt(totalPaid)){
//                    isAborted = true;
//                    _SLOT.start_store_es_mei();
//                }
            }
            break;
        case "STACK": console.log("STACK FUNCTION : ", meiResult); update_cash(meiFunction, meiResult);
            break;
        case "RETURN": console.log("RETURN FUNCTION: ", meiResult); update_cash(meiFunction, meiResult);
            break;
        case "STORE_ES":
            if(meiResult=='SUCCESS') {
                if (isAborted==true) abort_store_mei_transaction();
                if (isPaid==true) success_payment();
            }
            if(meiResult=='SUCCESS_55'){
                abc.counter = timer_value * 2
                my_timer.restart()
                _SLOT.start_accept_mei();
                payment_view.meiTextMode = "normal";
                payment_view.cancelAble = false;
                payment_view.secondTry = true;
                payment_view.modeLoading = false;
            };
            break;
        case "RETURN_ES": console.log("RETURN_ES FUNCTION : ", meiResult); update_cash(meiFunction, meiResult);
            break;
        case "DISPENSE_VAL": console.log("DISPENSE_VAL FUNCTION : ", meiResult);
            break;
        case "RETURN_STAT": console.log("RETURN_STAT FUNCTION : ", meiResult);
            break;
        case "STOP": console.log("STOP FUNCTION : ", meiResult);
            break;
        default: console.log("DEFAULT FUNCTION : ", meiFunction, meiResult);
            break;
        }
    }

    function success_payment(){
        if (selectedPayment=='EDC'){
            _SLOT.start_generate('TICKET_EDC');
            _SLOT.start_disconnect_edc();
        } else if (selectedPayment=='MEI'){
            _SLOT.start_generate('TICKET_MEI');
            _SLOT.start_disconnect_mei();
        } else if (selectedPayment=='QPROX'){
            _SLOT.start_generate('TICKET_QPROX');
            _SLOT.start_disconnect_qprox();
        }
        notif_view.show_detail = qsTr("Congratulations, Your Payment is successfull. Please get the printed receipt below.")
        notif_view.isSuccess = true
        notif_view.escapeFunction = 'backToMain'
        payment_view.totalGetCount = "0";
        payment_view.mode55 = false;
        payment_view.visible = false;        
        notif_view.open()
        abc.counter = 5
    }

    function update_cash(f, r){
        abc.counter = timer_value;
        my_timer.restart();
        if(f=="STACK"){
           if (r=="ERROR"||r=="REJECTED"){
               payment_view.visible = false;
               notif_view.isSuccess = false;
               notif_view.show_detail =  qsTr("Oops, Something went wrong with the cash");
               notif_view.z = 100;
               notif_view.escapeFunction = "closeWindow";
               notif_view.open();
           } else if (r=="OSERROR"){
               payment_view.meiTextMode = "oserror"
           } else if (r=="CONTINUE"){
               _SLOT.start_dis_accept_mei()
               payment_view.meiTextMode = "continue"
           } else if (r=="LIMIT_55"){
               _SLOT.start_dis_accept_mei()
               payment_view.mode55 = true
                if (confirmAble==true) {
                    payment_view.meiTextMode = "exceeded"
                } else {
//                    payment_view.modeLoading = true;
                    payment_view.meiTextMode = 'process55';
                    _SLOT.start_store_es_mei();
                }
           } else if (r=="COMPLETE"){
               if (confirmAble==true){
                   if (payment_view.mode55==true){
                       payment_view.modeConfirm = true;
                        _SLOT.start_mei_create_payment(baseFare);
                   } else {
                       _SLOT.start_dis_accept_mei();
                       payment_view.meiTextMode = "continue";
                   }
               } else {
                   _SLOT.start_dis_accept_mei();
                   payment_view.modeLoading = true;
                   _SLOT.start_mei_create_payment(baseFare);
                   isPaid = true;
                   _SLOT.start_store_es_mei();
               }
           } else {
//             Eliminate Calsulation from View
               payment_view.totalGetCount = r;
//               var tempAmount = (parseInt(payment_view.totalGetCount) + parseInt(r)).toString();
//               payment_view.totalGetCount = tempAmount;
//               if(parseInt(tempAmount)>=parseInt(totalPaid)){
//                   if (confirmAble==true){
//                       if (payment_view.mode55==true){
//                           payment_view.modeConfirm = true;
//                            _SLOT.start_mei_create_payment(baseFare);
//                       } else {
//                           _SLOT.start_dis_accept_mei();
//                           payment_view.meiTextMode = "continue";
//                       }
//                   } else {
//                       _SLOT.start_dis_accept_mei();
//                       payment_view.modeLoading = true;
//                       _SLOT.start_mei_create_payment(baseFare);
//                       isPaid = true;
//                       _SLOT.start_store_es_mei();
//                   }
//               }
           }
       }
       if(f=="RETURN_ES"){
           payment_view.totalGetCount = '0';
           payment_view.mode55 = false;
       }
       if(f=="RETURN"){
           var tempAmount_ = (parseInt(payment_view.totalGetCount) - parseInt(r)).toString();
           payment_view.totalGetCount = tempAmount_;

       }
    }

    function qprox_payment_result(r){
        console.log("qprox_payment_result : ", r)
        var qproxFunction = r.split('|')[0]
        var qproxResult = r.split('|')[1]
        if (r==undefined||r==""||qproxResult=="ERROR"){
            notif_view.isSuccess = false
            notif_view.show_detail =  qproxFunction + " result : " + r
            notif_view.z = 100
            notif_view.escapeFunction = "closeWindow"
            notif_view.open()
        }
        /*
            "INIT": "001",
            "AUTH": "002",
            "BALANCE": "003",
            "TOPUP": "004",
            "KA_INFO": "005",
            "CREATE_ONLINE_INFO": "006",
            "INIT_ONLINE": "007",
            "DEBIT": "008",
            "UNKNOWN": "009",
            "STOP": "010"
        */
            // TODO create multiple parse function for count
        switch(qproxFunction){
        case "INIT": console.log("INIT FUNCTION : ", qproxResult);
            break;
        case "AUTH": console.log("AUTH FUNCTION : ", qproxResult);
            break;
        case "BALANCE": console.log("BALANCE FUNCTION : ", qproxResult);
            break;
        case "TOPUP": console.log("TOPUP FUNCTION: ", qproxResult);
            break;
        case "KA_INFO": console.log("KA_INFO FUNCTION : ", qproxResult);
            break;
        case "CREATE_ONLINE_INFO": console.log("CREATE_ONLINE_INFO FUNCTION : ", qproxResult);
            break;
        case "INIT_ONLINE": console.log("INIT_ONLINE FUNCTION : ", qproxResult);
            break;
        case "DEBIT": console.log("DEBIT FUNCTION : ", qproxResult);
            break;
        case "STOP": console.log("STOP FUNCTION : ", qproxResult);
            break;
        default: console.log("DEFAULT FUNCTION : ", qproxFunction, qproxResult);
            break;
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
                timer_text.text = abc.counter
                abc.counter -= 1
                if(abc.counter == 60){
                    payment_view.visible = false;
                    abort_timeout(selectedPayment);
                    notif_view.show_detail = qsTr("We're apologize, Your payment session is expired. Your transaction will be aborted.");
                    notif_view.z = 100;
                    notif_view.escapeFunction = "backToMain";
                    notif_view.open();
                }
                if(abc.counter < 0){
                    my_timer.stop()
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
                }
            }
        }
    }

    Row{
        x: 1100
        y: 40
        z: 100
        spacing: 5
        Text{
            text: qsTr("Time Left : ")
            font.pixelSize: 20
            font.bold: true
            color: "yellow"
            font.family: "Microsoft YaHei"
        }
        Text{
            id: timer_text
            font.pixelSize: 20
            font.bold: true
            text: "500"
            color: "yellow"
            font.family: "Microsoft YaHei"
        }
    }

    CancelButton{
        id:cancel_button1
        x: 100 ;y: 40;
        MouseArea{
            anchors.fill: parent
            onClicked: {
//                notif_view.show_detail = qsTr("We're sorry, You can only continue the process.");
//                notif_view.open()
                confirm_view.escapeFunction = 'closeWindow'
                confirm_view.show_text = qsTr("Dear Customer")
                confirm_view.show_detail = qsTr("Are you sure to cancel this transaction ?")
                confirm_view.open()
            }
        }
    }

    //==============================================================
    //PUT MAIN COMPONENT HERE

    function define_payment_process(p){
        if (p==undefined) return
        else if (p=="EDC"){
            _SLOT.start_set_payment(selectedPayment);
            adminFee = defaultAdminFee
            surchargeFee = (FUNC.round_fare(baseFare, defaultMargin) * 0.03).toString()
            var adminCost = (parseInt(adminFee) + parseInt(surchargeFee)).toString()
            totalPaid = (FUNC.round_fare(baseFare, defaultMargin) + parseInt(adminCost)).toString()
            _SLOT.set_rounded_fare(totalPaid)
            console.log("[EDC] baseFare : ", baseFare, " totalAmount : ", totalPaid,
                        " margin : ", (parseInt(totalPaid) - parseInt(baseFare)).toString())
            surcharge_text.text = FUNC.insert_dot(surchargeFee)
            admin_fee_text.text = FUNC.insert_dot(adminCost)
            total_payment_text.text = FUNC.insert_dot(totalPaid)
            if (press != "0") return;
            press = "1";
            abc.counter = timer_value
            my_timer.restart()
            if (isReadyEDC==true){
                _SLOT.create_sale_edc(totalPaid);
                payment_view.styleText = true
                payment_view.show_text = FUNC.get_payment_text("EDC", languange_);
                payment_view.useMode = "EDC";
                payment_view.open();
            }else{
                not_ready_device();
            }

        } else if (p=="QPROX"){
            _SLOT.start_set_payment(selectedPayment);
            surchargeFee = "0"
            adminFee = defaultAdminFee
            totalPaid = (FUNC.round_fare(baseFare, defaultMargin) + parseInt(adminFee)).toString()
            _SLOT.set_rounded_fare(totalPaid)
            console.log("[QPROX] baseFare : ", baseFare, " totalAmount : ", totalPaid,
                        " margin : ", (parseInt(totalPaid) - parseInt(baseFare)).toString())
            surcharge_text.text = FUNC.insert_dot(surchargeFee)
            admin_fee_text.text = FUNC.insert_dot(adminFee)
            total_payment_text.text = FUNC.insert_dot(totalPaid)
            if (press != "0") return;
            press = "1";
            abc.counter = timer_value
            my_timer.restart()
            if (isReadyQPROX==true){
                if(parseInt(baseFare) > 1000000){
                    notif_view.show_detail = qsTr("Please choose another, Maximum amount with prepaid is under IDR 1.000.000,-");
                    notif_view.open();
                    press = "0";
                } else {
                    payment_view.show_text = FUNC.get_payment_text("QPROX", languange_);
                    payment_view.useMode = "QPROX";
                    payment_view.open();
                }
            }else{
                not_ready_device();
            }
        } else if (p=="MEI"){
            _SLOT.start_set_payment(selectedPayment);
            surchargeFee = "0"
            adminFee = defaultAdminFee
            totalPaid = (FUNC.round_fare(baseFare, defaultMargin) + parseInt(adminFee)).toString()
            _SLOT.set_rounded_fare(totalPaid)
            console.log("[MEI] baseFare : ", baseFare, " totalAmount : ", totalPaid,
                        " margin : ", (parseInt(totalPaid) - parseInt(baseFare)).toString())
            surcharge_text.text = FUNC.insert_dot(surchargeFee)
            admin_fee_text.text = FUNC.insert_dot(adminFee)
            total_payment_text.text = FUNC.insert_dot(totalPaid)
            if (press != "0") return;
            press = "1";
            abc.counter = timer_value * 2
            my_timer.restart()
            if (isReadyMEI==true){
                payment_view.show_text = FUNC.get_payment_text("MEI", languange_);
                payment_view.useMode = "MEI";
                payment_view.cancelAble = cancelAble;
                payment_view.open();
                _SLOT.start_accept_mei();
            }else{
                not_ready_device();
            }
        }
    }

    GroupBox{
        id: groupInfoGeneral
        x: 927
        width: 982
        height: 100
        anchors.top: parent.top
        anchors.topMargin: 100
        anchors.right: parent.right
        anchors.rightMargin: 0
        flat: true
        visible: (useMode!="TICKET_FLIGHT") ? true : false
        Text{
            id: text_info_1
            x: 662
            y: 26
            color: "darkred"
//            text: "Total Amount :\n 1.500.000"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 0
            font.bold: true
            font.pixelSize: 25
            font.family: "Microsoft YaHei"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
        }
        Text{
            id: text_info_2
            color: "darkred"
//            text: "Payment : Flight Ticket"
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            font.bold: false
            font.pixelSize: 25
            font.family: "Microsoft YaHei"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        Text{
            id: text_info_3
            width: 800
            height: 60
//            text: "Description :\n JT-123 CGK - DPS 10:00 - 12:00"
            wrapMode: Text.WordWrap
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: text_info_2.bottom
            anchors.topMargin: 0
            color: "darkred"
            font.bold: false
            font.pixelSize: 15
            font.family: "Microsoft YaHei"
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignLeft
        }
    }

    GroupBox{
        id: groupInfoTicket
        x: 927
        width: 982
        height: 440
        anchors.top: parent.top
        anchors.topMargin: 100
        anchors.right: parent.right
        anchors.rightMargin: 0
        flat: true
//        visible: (useMode=="TICKET_FLIGHT") ? true : false
        MainTitle{
            x: 17
            y: 10
            show_text: qsTr("Flight Purchase Summary")
            size_: 15
        }

        GroupBox{
            id: groupDepartureInfo
            x: 0
            flat: true
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: 100
            Rectangle{
                id: rec_title_depart
                height: 40; width: parent.width
                color: "darkred"
                Image{
                    id: img_info_depart
                    width: 50
                    height: parent.height
                    source: "aAsset/takeoff.png"
                    fillMode: Image.PreserveAspectFit

                }
                Text{
                    id: text_info_depart
                    height: parent.height
                    width: 500
                    text: qsTr("Departure Information : ")
                    anchors.left: img_info_depart.right
                    anchors.leftMargin: 10
                    verticalAlignment: Text.AlignVCenter
                    color: "white"
                    font.pixelSize: 20
                    font.bold: false
                    font.family: "Microsoft YaHei"
                }
            }
            Text{
                id: bc_text
                visible: false
                width: 350
                height: 35
                anchors.top: parent.top
                anchors.topMargin: 2
                anchors.right: parent.right
                anchors.rightMargin: 5
                wrapMode: Text.WordWrap
                color: "#ffffff"
                font.bold: false
                font.pixelSize: 25
                font.family: "Microsoft YaHei"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
//                text: bookingCodeDepart
            }
            Image{
                id: img_flight_logo
                width: 265
                height: 95
                anchors.top: parent.top
                anchors.topMargin: 30
                anchors.left: parent.left
                anchors.leftMargin: -30
                scale: 0.7
                opacity: 1
                fillMode: Image.PreserveAspectFit
//                source: "aAsset/lion_air_logo.jpg"
            }
            Text{
                id: flightNo_text
                width: 200
                height: 35
                anchors.left: img_flight_logo.right
                anchors.leftMargin: -30
                anchors.top: parent.top
                anchors.topMargin: 60
                font.italic: false
                wrapMode: Text.WordWrap
                color: "darkred"
                font.bold: true
                font.pixelSize: 25
                font.family: "Microsoft YaHei"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
//                text: flightNoDepart
            }
            Text{
                id: origin_text_depart
                width: 400
                height: 35
                anchors.verticalCenter: img_origin_depart.verticalCenter
                font.italic: true
                anchors.top: parent.top
                anchors.topMargin: 100
                wrapMode: Text.WordWrap
                color: "darkred"
                font.bold: false
                font.pixelSize: 15
                font.family: "Microsoft YaHei"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
//                text: originFrom
                anchors.right: img_origin_depart.left
                anchors.rightMargin: 10
            }
            Image{
                id: img_origin_depart
                width: 40
                height: 40
                anchors.right: parent.right
                anchors.rightMargin: 10
                source: "aAsset/terminal.png"
                fillMode: Image.PreserveAspectFit
                anchors.top: parent.top
                anchors.topMargin: 60
            }
            Text{
                id: details_depart_text
                anchors.top: parent.top
                anchors.topMargin: 110
                width: parent.width
                height: 35
                font.italic: true
                wrapMode: Text.WordWrap
                color: "darkred"
//                font.bold: true
                font.pixelSize: 17
                font.family: "Microsoft YaHei"
                verticalAlignment: Text.AlignTop
                horizontalAlignment: Text.AlignLeft
//                text: departDate
            }
            Row{
                anchors.top: parent.top
                anchors.topMargin: 110
                width: parent.width
                visible: false
                Text{
                    id: date_text_depart
                    width: parent.width/3
                    height: 35
                    font.italic: true
                    wrapMode: Text.WordWrap
                    color: "darkred"
                    font.bold: true
                    font.pixelSize: 20
                    font.family: "Microsoft YaHei"
                    verticalAlignment: Text.AlignTop
                    horizontalAlignment: Text.AlignHCenter
//                    text: departDate
                }
                Text{
                    id: time_departure_depart
                    width: parent.width/3
                    height: 35
                    font.italic: true
                    wrapMode: Text.WordWrap
                    color: "darkred"
                    font.bold: true
                    font.pixelSize: 20
                    font.family: "Microsoft YaHei"
                    verticalAlignment: Text.AlignTop
                    horizontalAlignment: Text.AlignHCenter
//                    text: flightTimeDepart.substring(0, 5)
                }
                Text{
                    id: time_arrival_depart
                    width: parent.width/3
                    height: 35
                    font.italic: true
                    wrapMode: Text.WordWrap
                    color: "darkred"
                    font.bold: true
                    font.pixelSize: 20
                    font.family: "Microsoft YaHei"
                    verticalAlignment: Text.AlignTop
                    horizontalAlignment: Text.AlignHCenter
//                    text: flightTimeDepart.substring(flightTimeDepart.length-5)
                }
            }

        }

        GroupBox{
            id: groupReturnInfo
            x: 0
            flat: true
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: 290
            visible: false
            Rectangle{
                id: rec_title_return
                height: 40; width: parent.width
                color: "darkred"
                Image{
                    id: img_info_return
                    width: 50
                    height: parent.height
                    source: "aAsset/returning.png"
                    fillMode: Image.PreserveAspectFit

                }
                Text{
                    id: text_info_return
                    height: parent.height
                    width: 500
                    text: qsTr("Return Information : ")
                    anchors.left: img_info_return.right
                    anchors.leftMargin: 10
                    verticalAlignment: Text.AlignVCenter
                    color: "white"
                    font.pixelSize: 20
                    font.bold: false
                    font.family: "Microsoft YaHei"
                }
            }
            Text{
                id: bc_text_return
                visible: false
                width: 350
                height: 35
                anchors.top: parent.top
                anchors.topMargin: 2
                anchors.right: parent.right
                anchors.rightMargin: 5
                wrapMode: Text.WordWrap
                color: "#ffffff"
                font.bold: false
                font.pixelSize: 25
                font.family: "Microsoft YaHei"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
//                text: bookingCodeReturn
            }
            Image{
                id: img_flight_logo_return
                width: 265
                height: 95
                anchors.top: parent.top
                anchors.topMargin: 30
                anchors.left: parent.left
                anchors.leftMargin: -30
                scale: 0.7
                opacity: 1
                fillMode: Image.PreserveAspectFit
//                source: "aAsset/lion_air_logo.jpg"

            }
            Text{
                id: flightNo_text_return
                width: 200
                height: 35
                anchors.left: img_flight_logo_return.right
                anchors.leftMargin: -30
                anchors.top: parent.top
                anchors.topMargin: 60
                font.italic: false
                wrapMode: Text.WordWrap
                color: "darkred"
                font.bold: true
                font.pixelSize: 25
                font.family: "Microsoft YaHei"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
//                text: flightNoReturn
            }
            Text{
                id: destination_origin_text
                width: 400
                height: 35
                //                text: FUNC.insert_dot(priceDepart)
                font.italic: true
                anchors.top: parent.top
                anchors.topMargin: 100
                wrapMode: Text.WordWrap
                color: "darkred"
                font.bold: false
                font.pixelSize: 15
                font.family: "Microsoft YaHei"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: img_origin_return.verticalCenter
//                text: destinationTo
                anchors.right: img_origin_return.left
                anchors.rightMargin: 10
            }
            Image{
                id: img_origin_return
                width: 40
                height: 40
                anchors.right: parent.right
                anchors.rightMargin: 10
                source: "aAsset/terminal.png"
                fillMode: Image.PreserveAspectFit
                anchors.top: parent.top
                anchors.topMargin: 60
            }
            Text{
                id: details_return_text
                anchors.top: parent.top
                anchors.topMargin: 110
                width: parent.width
                height: 35
                font.italic: true
                wrapMode: Text.WordWrap
                color: "darkred"
//                font.bold: true
                font.pixelSize: 17
                font.family: "Microsoft YaHei"
                verticalAlignment: Text.AlignTop
                horizontalAlignment: Text.AlignLeft
//                text: returnDate
            }
            Row{
                anchors.top: parent.top
                anchors.topMargin: 110
                width: parent.width
                visible: false
                Text{
                    id: date_text_return
                    width: parent.width/3
                    height: 35
                    font.italic: true
                    wrapMode: Text.WordWrap
                    color: "darkred"
                    font.bold: true
                    font.pixelSize: 20
                    font.family: "Microsoft YaHei"
                    verticalAlignment: Text.AlignTop
                    horizontalAlignment: Text.AlignHCenter
                }
                Text{
                    id: time_departure_return
                    width: parent.width/3
                    height: 35
                    font.italic: true
                    wrapMode: Text.WordWrap
                    color: "darkred"
                    font.bold: true
                    font.pixelSize: 20
                    font.family: "Microsoft YaHei"
                    verticalAlignment: Text.AlignTop
                    horizontalAlignment: Text.AlignHCenter
                }
                Text{
                    id: time_arrival_return
                    width: parent.width/3
                    height: 35
                    font.italic: true
                    wrapMode: Text.WordWrap
                    color: "darkred"
                    font.bold: true
                    font.pixelSize: 20
                    font.family: "Microsoft YaHei"
                    verticalAlignment: Text.AlignTop
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Rectangle{
            id: rec_passenger_text_title
            x: 17
            y: 480
            width: 600
            height: 30
            color: 'darkred'
            visible: false
            Text{
                id: passenger_text_view
                width: 600
                text: qsTr("Passenger Info")
                anchors.fill: parent
                color: 'white'
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: 'Microsoft YaHei'
                font.pixelSize: 20
            }
        }

        Text{
            id: passenger_text_content
            x: 17
            y: 515
            width: 600
            height: 122
            visible: rec_passenger_text_title.visible
//            text: '1. Adult - Wahyudi Imam - 085710157057 - yhoed.cbr@gmail.com\n'
            color: 'darkred'
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignTop
            font.italic: true
            font.family: 'Microsoft YaHei'
            font.pixelSize: 15
            wrapMode: Text.WordWrap
        }

        Column{
            id: price_col
            x: 649
            y: 480
            spacing: 0
            Row{
                id: base_fare_row
                x: 652; y: 534;
                width: 300; height: 40;
                anchors.right: parent.right
                anchors.rightMargin: 8
                spacing: 0
                Rectangle{
                    width: parent.width/2; height: parent.height;
                    color: "darkred"; border.width: 2; border.color: "darkred";
                    Text{
                        anchors.fill: parent;
                        font.family: "Microsoft YaHei"
                        font.bold: false
                        font.pixelSize: 20
                        text: qsTr("Base Fare")
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                    }
                }
                Rectangle{
                    width: parent.width/2; height: parent.height;
                    color: "white"; border.width: 2; border.color: "darkred";
                    Text{
                        anchors.fill: parent;
                        font.family: "Microsoft YaHei"
                        font.bold: true
                        font.pixelSize: 20
//                        text: FUNC.insert_dot(FUNC.get_diff(totalPaid, adminFee))
                        text: FUNC.insert_dot(FUNC.round_fare(baseFare, defaultMargin).toString())
                        anchors.rightMargin: 5
    //                    text: "2.999.000"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        color: "darkred"
                    }
                }
            }
            Row{
                id: admin_fee_row
                x: 652; y: 534;
                width: 300; height: 40;
                anchors.right: parent.right
                anchors.rightMargin: 8
                spacing: 0
                Rectangle{
                    width: parent.width/2; height: parent.height;
                    color: "darkred"; border.width: 2; border.color: "darkred";
                    Text{
                        anchors.fill: parent;
                        font.family: "Microsoft YaHei"
                        font.bold: false
                        font.pixelSize: 20
                        text: qsTr("Admin Fee")
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                    }
                }
                Rectangle{
                    width: parent.width/2; height: parent.height;
                    color: "white"; border.width: 2; border.color: "darkred";
                    Text{
                        id: admin_fee_text
                        anchors.fill: parent;
                        font.family: "Microsoft YaHei"
                        font.bold: true
                        font.pixelSize: 20
//                        text: FUNC.insert_dot(adminFee)
                        anchors.rightMargin: 5
    //                    text: "2.999.000"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        color: "darkred"
                    }
                }
            }
            Row{
                id: surcharge_row
                x: 652; y: 534;
                width: 300; height: 40;
                anchors.right: parent.right
                anchors.rightMargin: 8
                spacing: 0
                visible: false
                Rectangle{
                    width: parent.width/2; height: parent.height;
                    color: "darkred"; border.width: 2; border.color: "darkred";
                    Text{
                        anchors.fill: parent;
                        font.family: "Microsoft YaHei"
                        font.bold: false
                        font.pixelSize: 20
                        text: qsTr("Surcharge")
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                    }
                }
                Rectangle{
                    width: parent.width/2; height: parent.height;
                    color: "white"; border.width: 2; border.color: "darkred";
                    Text{
                        id: surcharge_text
                        anchors.fill: parent;
                        font.family: "Microsoft YaHei"
                        font.bold: true
                        font.pixelSize: 20
                        text: "0"
                        anchors.rightMargin: 5
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        color: "darkred"
                    }
                }
            }
            Row{
                id: total_pay_row
                x: 652; y: 534;
                width: 300; height: 40;
                anchors.right: parent.right
                anchors.rightMargin: 8
                spacing: 0
                Rectangle{
                    width: parent.width/2; height: parent.height;
                    color: "darkred"; border.width: 2; border.color: "darkred";
                    Text{
                        anchors.fill: parent;
                        font.family: "Microsoft YaHei"
                        font.bold: false
                        font.pixelSize: 20
                        text: qsTr("Total Paid")
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                    }
                }
                Rectangle{
                    width: parent.width/2; height: parent.height;
                    color: "white"; border.width: 2; border.color: "darkred";
                    Text{
                        id: total_payment_text
                        anchors.fill: parent;
                        font.family: "Microsoft YaHei"
                        font.bold: true
                        font.pixelSize: 20
//                        text: FUNC.insert_dot((FUNC.round_fare(baseFare)+parseInt(adminFee)).toString())
                        anchors.rightMargin: 5
    //                    text: "2.999.000"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        color: "darkred"
                    }
                }
            }
        }
    }

    Row{
        x: 477
        y: 725
        spacing: 50
        enabled: (payment_view.visible==false && popup_login.visible==false) ? true : false
        MouseArea{
            id: button_edc
            width: 175
            height: 175
            enabled: parent.enabled
            Rectangle{
                id: button_rec_edc
                anchors.fill: parent
                border.color: "gray"
                border.width: 1.5
                color: "white"
            }
            Image{
                id: img_edc
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "aAsset/credit card black.png"
                fillMode: Image.Stretch

            }
            Text{
                id: button_edc_label
                text: qsTr("EDC")
                font.pixelSize: 20
                font.bold: true
                verticalAlignment: Text.AlignBottom
                horizontalAlignment: Text.AlignHCenter
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 0
            }
            onClicked: {
                if (clear_payment_session()===true){
                    console.log("EDC check_price is pressed");
                    selectedPayment = "EDC";
                    adminFee = defaultAdminFee
                    surchargeFee = (FUNC.round_fare(baseFare, defaultMargin) * 0.03).toString()
                    var admincost = (parseInt(adminFee) + parseInt(surchargeFee)).toString()
                    totalPaid = (FUNC.round_fare(baseFare, defaultMargin) + parseInt(admincost)).toString()
                    surcharge_text.text = FUNC.insert_dot(surchargeFee)
                    admin_fee_text.text = FUNC.insert_dot(admincost)
                    total_payment_text.text = FUNC.insert_dot(totalPaid)
                } else {
                    not_open_session();
                }
            }
            onExited: {
                reset_button_payment(selectedPayment);
            }
//            onDoubleClicked: {
//                console.log("EDC button is pressed");
//                if (payment_session()===true){
//                    selectedPayment = "EDC";
//                    _SLOT.start_set_payment(selectedPayment);
//                    adminFee = "25000"
//                    surchargeFee = (FUNC.round_fare(baseFare) * 0.03).toString()
//                    var adminCost = (parseInt(adminFee) + parseInt(surchargeFee)).toString()
//                    totalPaid = (FUNC.round_fare(baseFare) + parseInt(adminCost)).toString()
//                    _SLOT.set_rounded_fare(totalPaid)
//                    console.log("[EDC] baseFare : ", baseFare, " totalAmount : ", totalPaid,
//                                " margin : ", (parseInt(totalPaid) - parseInt(baseFare)).toString())
//                    surcharge_text.text = FUNC.insert_dot(surchargeFee)
//                    admin_fee_text.text = FUNC.insert_dot(adminCost)
//                    total_payment_text.text = FUNC.insert_dot(totalPaid)
//                    if (press != "0") return;
//                    press = "1";
//                    abc.counter = timer_value
//                    my_timer.restart()
//                    if (isReadyEDC==true){
//                        _SLOT.create_sale_edc(totalPaid);
//                        payment_view.show_text = FUNC.get_payment_text("EDC", languange_);
//                        payment_view.useMode = "EDC";
//                        payment_view.open();
//                    }else{
//                        not_ready_device();
//                    }
//                } else {
//                    not_open_session();
//                }
//            }
        }
        MouseArea{
            id: button_prepaid
            width: 175
            height: 175
            enabled: parent.enabled
            Rectangle{
                id: button_rec_qprox
                anchors.fill: parent
                border.color: "gray"
                border.width: 1.5
                color: "white"
            }
            Image{
                id: img_prepaid
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "aAsset/prepaid black.png"
                fillMode: Image.Stretch
            }
            Text{
                id: button_prepaid_label
                text: qsTr("Prepaid")
                font.pixelSize: 20
                font.bold: true
                verticalAlignment: Text.AlignBottom
                horizontalAlignment: Text.AlignHCenter
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 0
            }
            onClicked: {
                if (clear_payment_session()===true){
                    console.log("QPROX check_price iss pressed");
                    selectedPayment = "QPROX";
                    surchargeFee = "0"
                    adminFee = defaultAdminFee
                    totalPaid = (FUNC.round_fare(baseFare, defaultMargin) + parseInt(adminFee)).toString()
                    surcharge_text.text = FUNC.insert_dot(surchargeFee)
                    admin_fee_text.text = FUNC.insert_dot(adminFee)
                    total_payment_text.text = FUNC.insert_dot(totalPaid)
                } else {                    
                    not_open_session();
                }
            }
            onExited: {
                reset_button_payment(selectedPayment);
            }
//            onDoubleClicked: {
//                console.log("Prepaid button is pressed");
//                if (payment_session()===true){
//                    selectedPayment = "QPROX";
//                    _SLOT.start_set_payment(selectedPayment);
//                    surchargeFee = "0"
//                    adminFee = "25000"
//                    totalPaid = (FUNC.round_fare(baseFare) + parseInt(adminFee)).toString()
//                    _SLOT.set_rounded_fare(totalPaid)
//                    console.log("[QPROX] baseFare : ", baseFare, " totalAmount : ", totalPaid,
//                                " margin : ", (parseInt(totalPaid) - parseInt(baseFare)).toString())
//                    surcharge_text.text = FUNC.insert_dot(surchargeFee)
//                    admin_fee_text.text = FUNC.insert_dot(adminFee)
//                    total_payment_text.text = FUNC.insert_dot(totalPaid)
//                    if (press != "0") return;
//                    press = "1";
//                    abc.counter = timer_value
//                    my_timer.restart()
//                    if (isReadyQPROX==true){
//                        if(parseInt(baseFare) > 1000000){
//                            notif_view.show_detail = qsTr("Please choose another, Maximum amount with prepaid is under IDR 1.000.000,-");
//                            notif_view.open();
//                            press = "0";
//                        } else {
//                            payment_view.show_text = FUNC.get_payment_text("QPROX", languange_);
//                            payment_view.useMode = "QPROX"
//                            payment_view.open();
//                        }
//                    }else{
//                        not_ready_device();
//                    }
//                } else {
//                    not_open_session();
//                }
//            }
        }
        MouseArea{
            id: button_cash
            width: 175
            height: 175
            enabled: parent.enabled
            Rectangle{
                id: button_rec_mei
                anchors.fill: parent
                border.color: "gray"
                border.width: 1.5
                color: "white"
            }
            Image{
                id: img_cash
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "aAsset/cash black.png"
                fillMode: Image.Stretch
            }
            Text{
                id: button_cash_label
                text: qsTr("Cash")
                font.pixelSize: 20
                font.bold: true
                verticalAlignment: Text.AlignBottom
                horizontalAlignment: Text.AlignHCenter
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 0
            }
            onClicked: {
                if (clear_payment_session()===true){
                    console.log("MEI check_price is pressed");
                    selectedPayment = "MEI";
                    surchargeFee = "0"
                    adminFee = defaultAdminFee
                    totalPaid = (FUNC.round_fare(baseFare, defaultMargin) + parseInt(adminFee)).toString()
                    surcharge_text.text = FUNC.insert_dot(surchargeFee)
                    admin_fee_text.text = FUNC.insert_dot(adminFee)
                    total_payment_text.text = FUNC.insert_dot(totalPaid)
                } else {
                    not_open_session();
                }
            }
            onExited: {
                reset_button_payment(selectedPayment);
            }
//            onDoubleClicked: {
//                console.log("Cash button is pressed");
//                if (payment_session()===true){
//                    selectedPayment = "MEI";
//                    _SLOT.start_set_payment(selectedPayment);
//                    surchargeFee = "0"
//                    adminFee = "25000"
//                    totalPaid = (FUNC.round_fare(baseFare) + parseInt(adminFee)).toString()
//                    _SLOT.set_rounded_fare(totalPaid)
//                    console.log("[MEI] baseFare : ", baseFare, " totalAmount : ", totalPaid,
//                                " margin : ", (parseInt(totalPaid) - parseInt(baseFare)).toString())
//                    surcharge_text.text = FUNC.insert_dot(surchargeFee)
//                    admin_fee_text.text = FUNC.insert_dot(adminFee)
//                    total_payment_text.text = FUNC.insert_dot(totalPaid)
//                    if (press != "0") return;
//                    press = "1";
//                    abc.counter = timer_value * 2
//                    my_timer.restart()
//                    if (isReadyMEI==true){
//                        payment_view.show_text = FUNC.get_payment_text("MEI", languange_);
//                        payment_view.useMode = "MEI";
//                        payment_view.open();
//                        _SLOT.start_accept_mei();
//                    }else{
//                        not_ready_device();
//                    }
//                } else {
//                    not_open_session();
//                }
//            }
        }
    }

    Button{
        id: button_next_payment
        x: 948
        y: 954
        width: 300
        height: 50
        visible: (selectedPayment!=undefined && selectedPayment!='WALLET') ? true : false
        enabled: visible
        tooltip: qsTr("Press To Continue Payment")
        onClicked: {
            if (press!='0') return;
            press == '1';
            define_payment_process(selectedPayment);
        }
        Text{
            text: qsTr("Proceed Payment")
            color: "darkred"
            font.pixelSize: 20
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0
        }
    }

    Text{
        id: inform_text
        y: 0
        width: 950
        height: 50
        visible: false
        text: qsTr("Please touch payment method to calculate total payment or double touch to do payment.")
        font.italic: true
        font.pointSize: 15
        anchors.left: parent.left
        anchors.leftMargin: 310
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.family: "Microsoft YaHei"
        color: "darkred"

    }

    Rectangle{
        id: wallet_button
        width: 200
        height: 60
        color: 'orange'
        radius: 10
        border.width: 0
        anchors.left: parent.left
        anchors.leftMargin: 50
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        opacity: .75

        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5
            Image{
                width: 40
                height: 40
                source: 'aAsset/icon/wallet_black.png'
                opacity: .75
            }
            Text {
                id: wallet_button_text
                text: ' WALLET'
                color: 'white'
                font.family:"Microsoft YaHei"
                font.pixelSize: 25
//                font.bold: true

            }
        }
        MouseArea{
            anchors.fill: parent
            enabled: (popup_login.visible==false) ? true : false
            onClicked: {
                _SLOT.start_set_payment('WALLET');
                selectedPayment = 'WALLET';
                surchargeFee = "0";
                adminFee = defaultAdminFee;
                totalPaid = (FUNC.round_fare(baseFare, defaultMargin) + parseInt(adminFee)).toString();
                _SLOT.set_rounded_fare(totalPaid);
                button_rec_edc.color = "white";
                button_rec_mei.color = "white";
                button_rec_qprox.color = "white";
                popup_login.open();
            }
        }
    }

    //==============================================================

    ConfirmView{
        id: confirm_view
        show_text: qsTr("Dear Customer")
        show_detail: qsTr("Proceed This Payment?")
        z: 99
        MouseArea{
            id: ok_confirm_view
            x: 668; y:691
            width: 190; height: 50;
            onClicked: {
                abort_transaction(selectedPayment);
                my_layer.pop(my_layer.find(function(item){if(item.Stack.index===0)return true}));
            }
        }
    }

    ConfirmView{
        id: failed_payment_view
        show_text: qsTr("Dear Customer")
        show_detail: qsTr("Your payment confirmation was failed, Retry the payment ?")
        cancelAble: false
//        visible: true
        z: 99
        MouseArea{
            id: cancel_failed_payment
            x: 468; y:691
            width: 190; height: 50;
            onClicked: {
                abort_transaction(selectedPayment);
                my_layer.pop(my_layer.find(function(item){if(item.Stack.index===0)return true}));
            }
        }
        MouseArea{
            id: ok_failed_payment
            x: 668; y:691
            width: 190; height: 50;
            onClicked: {
                payment_view.visible = true;
                payment_view.modeLoading = true;
//                _SLOT.start_create_payment(baseFare);
//                abort_transaction(selectedPayment);
//                my_layer.pop(my_layer.find(function(item){if(item.Stack.index===0)return true}));
            }
        }
    }

    NotifView{
        id: notif_view
        isSuccess: false
        show_text: qsTr("Dear Customer")
        show_detail: qsTr("Please Ensure You have set Your plan correctly.")
        z: 99
    }

    LoadingView{
        id:loading_view
        z: 99
        show_text: qsTr("Processing...")
    }

    PaymentView{
        id: payment_view
        z: 99
        useMode: "MEI"
        show_text: ""
        totalCost: totalPaid
        totalGetCount: "0"
    }

    PopupLogin{
        id: popup_login
        exitKey: adminKey
//        visible: true
        MouseArea{
            id: cancel_popup_login
            x: 405; y:839
            width: 190; height: 50
            onClicked: {
                popup_login.visible = false;
                selectedPayment = undefined;
                parent.textInput = '';
                parent.clickAble = false;
            }
        }
        MouseArea{
            id: ok_popup_login
            x: 684; y:839
            width: 190; height: 50;
            enabled: parent.clickAble
            onClicked: {
                _SLOT.start_check_wallet(totalPaid);
                loading_view.show_text = (language=='INA') ? 'Memeriksa Saldo Terminal...' : 'Checking Terminal Wallet...';
                loading_view.open();
                popup_login.close();

            }
        }
    }

}

