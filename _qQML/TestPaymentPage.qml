import QtQuick 2.4
import QtQuick.Controls 1.3
import "base_function.js" as FUNC

Base{
    id: test_payment
    mode_: "reverse"
    isPanelActive: true
    textPanel: qsTr("Input Test Amount")
    imgPanel: "source/choose_payment.png"
    property int timer_value: 300
    property int max_count: 25
    property var press: "0"
    property var textInput: ""
    property bool isReadyEDC: false
    property bool isReadyMEI: false
    property bool isReadyQPROX: false
    property var selectedPayment: undefined
    property bool isPaid: false
    property bool isAborted: false
    signal abortPayment(string str)
    signal releaseButton(string str)


    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            _SLOT.start_get_device_status();
            abc.counter = timer_value;
            my_timer.start()
            press = "0"
            selectedPayment = undefined
            payment_view.close()
            notif_view.close()
        }
        if(Stack.status==Stack.Deactivating){
//            if (isPaid==false) {
//                abort_transaction(selectedPayment);
//            }
            my_timer.stop();
            loading_view.close();
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
        base.result_general.connect(handle_general)
        releaseButton.connect(free_button);
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
        base.result_general.disconnect(handle_general)
        releaseButton.disconnect(free_button);

    }

    function clear_payment_session(){
        if (selectedPayment===undefined) return true
        if (selectedPayment=="EDC"){
            _SLOT.start_disconnect_edc();
            selectedPayment = undefined;
            return false;
        }
        if (selectedPayment=="QPROX"){
            _SLOT.start_disconnect_qprox();
            selectedPayment = undefined;
            return false;
        }
        if (selectedPayment=="MEI"){
            if (payment_view.totalGetCount!="0"){
                if (isPaid==false) _SLOT.start_return_es_mei();
            } else {
                _SLOT.start_disconnect_mei();
            }
            selectedPayment = undefined;
            return false;
        }
    }

    function reset_session(s){
        if (s==undefined) return false
        return true
    }

    function free_button(free){
        console.log("[info] release button from : ", free);
//        loading_view.show_text = qsTr('Closing Previous Payment Session')
//        loading_view.open()
        clear_payment_session();
        payment_view.visible = false;
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

    function not_open_session(){
        notif_view.show_detail = qsTr("Closing previous payment session. Please collect back the inserted cash if any.");
        notif_view.isSuccess = false
        notif_view.escapeFunction = 'closeWindow'
        notif_view.open()
        press = "0"
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
                    _SLOT.start_return_es_mei();
                }
            } else {
                _SLOT.start_disconnect_mei();
//                console.log("disconnect_mei from abort_transaction");
            }
        }
        if (s=="EDC") _SLOT.start_disconnect_edc();
        if (s=="QPROX") _SLOT.start_disconnect_qprox();
    }

    function define_device(status){
        console.log("device_status :", status);
        var s = JSON.parse(status);
        if (s.EDC=="AVAILABLE") isReadyEDC = true;
        if (s.QPROX=="AVAILABLE") isReadyQPROX = true;
        if (s.MEI=="AVAILABLE") isReadyMEI = true;
    }

    function edc_payment_result(r){
        console.log("edc_payment_result : ", r)
        if (r==undefined||r==""||r.indexOf("ERROR") > -1){
            notif_view.show_detail = qsTr("Oops, Something went wrong. Please retry later.")
            notif_view.isSuccess = false
            notif_view.escapeFunction = 'closeWindow'
            notif_view.open()
        }
        var edcFunction = r.split('|')[0]
        var edcResult = r.split('|')[1]
        if (edcFunction=="SUCCESS") {
            success_payment()
        } else {
            payment_view.styleText = true
            switch(edcResult){
            case 'CI':
                payment_view.show_text = qsTr('Please Insert Your Card Into The Card Slot.');
                break;
            case 'PI':
                payment_view.show_text = qsTr('Card Inserted, Please Key In Your PIN.');
                break;
            case 'DO':
                payment_view.show_text = qsTr('PIN Received, Waiting For Bank Response.');
                break;
            case 'TC':
                payment_view.show_text = qsTr('Payment Process was Cancelled By User.');
                break;
            case 'CO':
                payment_view.show_text = qsTr('Process Done, Please Take Back Your Card Safely.');
                break;
            case 'CR':
                payment_view.show_text = qsTr('Card Rejected, Please Use Another Card.');
                break;
            default:
                payment_view.show_text = edcResult
                break;
            }
            if (payment_view.visible==false) payment_view.open()
        }
//        _SLOT.start_disconnect_edc()
    }

    /*
                EDC_PAYMENT_RESULT['amount'] = param[3]
                EDC_PAYMENT_RESULT['res_code'] = param[2]
                EDC_PAYMENT_RESULT['inv_no'] = param[5]
                EDC_PAYMENT_RESULT['card_no'] = param[6]
                EDC_PAYMENT_RESULT['exp_date'] = param[7]
                EDC_PAYMENT_RESULT['trans_date'] = param[8]
                EDC_PAYMENT_RESULT['app_code'] = param[9]
                EDC_PAYMENT_RESULT['tid'] = param[10]
                EDC_PAYMENT_RESULT['mid'] = param[11]
                EDC_PAYMENT_RESULT['ref_no'] = param[12]
                EDC_PAYMENT_RESULT['batch_no'] = param[13]
    */

    function not_ready_device(){
        notif_view.show_detail = qsTr("This payment is not available this time.")
        notif_view.isSuccess = false
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
                notif_view.show_detail = qsTr("We're apologize, Your payment session is expired.")
//                _SLOT.start_return_es_mei()
            } else {
                notif_view.show_detail =  meiFunction + " result : " + r
            }
            notif_view.show_detail =  meiFunction + " result : " + r
            notif_view.z = 100
            notif_view.escapeFunction = "closeWindow"
            notif_view.open()
        }
            // TODO create multiple parse function for count
        switch(meiFunction){
        case "ACCEPT": console.log("ACCEPT FUNCTION : ", meiResult);
            break;
        case "DIS_ACCEPT": console.log("DIS_ACCEPT FUNCTION : ", meiResult);
            break;
        case "STACK": console.log("STACK FUNCTION : ", meiResult); update_cash(meiFunction, meiResult);
            break;
        case "RETURN": console.log("RETURN FUNCTION: ", meiResult); update_cash(meiFunction, meiResult);
            break;
        case "STORE_ES": console.log("STORE_ES FUNCTION : ", meiResult); if(meiResult=='SUCCESS') success_payment();
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

    function update_cash(f, r){
       if(f=="STACK"){
           if (r=="CONTINUE"){
//               _SLOT.start_dis_accept_mei()
               payment_view.meiTextMode = "continue"
           } else {
               var tempAmount = (parseInt(payment_view.totalGetCount) + parseInt(r)).toString();
               payment_view.totalGetCount = tempAmount;
               if(parseInt(tempAmount)>=parseInt(textInput)){
                   _SLOT.start_dis_accept_mei()
                   payment_view.meiTextMode = "continue"
               }
           }
       }
       if(f=="RETURN_ES"){
           payment_view.totalGetCount = '0';
       }
       if(f=="RETURN"){
           var tempAmount_ = (parseInt(payment_view.totalGetCount) - parseInt(r)).toString();
           payment_view.totalGetCount = tempAmount_;
       }
    }

    function success_payment(){
        isPaid = true;
        _SLOT.start_generate('TEST');
        if (selectedPayment=='EDC'){
            _SLOT.start_disconnect_edc();
        } else if (selectedPayment=='MEI'){
            _SLOT.start_disconnect_mei();
        } else if (selectedPayment=='QPROX'){
            _SLOT.start_disconnect_qprox();
        }
        notif_view.show_detail = qsTr("Congratulations, Your Payment is successfull.\n Please get the printed receipt below.");
        notif_view.isSuccess = true;
        notif_view.escapeFunction = 'backToMain';
        notif_view.z = 100;
        payment_view.totalGetCount = "0";
        payment_view.visible = false;
        notif_view.open();
        abc.counter = 7;
    }

    function qprox_payment_result(r){
        console.log("mei_payment_result : ", r)
        var meiFunction = r.split('|')[0]
        var meiResult = r.split('|')[1]
        if (r==undefined||r==""||meiResult=="ERROR"){
            notif_view.isSuccess = false
            notif_view.show_detail =  meiFunction + " result : " + r
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
        switch(meiFunction){
        case "INIT": console.log("INIT FUNCTION : ", meiResult);
            break;
        case "AUTH": console.log("AUTH FUNCTION : ", meiResult);
            break;
        case "BALANCE": console.log("BALANCE FUNCTION : ", meiResult);
            break;
        case "TOPUP": console.log("TOPUP FUNCTION: ", meiResult);
            break;
        case "KA_INFO": console.log("KA_INFO FUNCTION : ", meiResult);
            break;
        case "CREATE_ONLINE_INFO": console.log("CREATE_ONLINE_INFO FUNCTION : ", meiResult);
            break;
        case "INIT_ONLINE": console.log("INIT_ONLINE FUNCTION : ", meiResult);
            break;
        case "DEBIT": console.log("DEBIT FUNCTION : ", meiResult);
            break;
        case "STOP": console.log("STOP FUNCTION : ", meiResult);
            break;
        default: console.log("DEFAULT FUNCTION : ", meiFunction, meiResult);
            break;
        }

    }

    function not_amount(){
        notif_view.show_detail = qsTr("Please input the amount first..!");
        notif_view.isSuccess = false;
        notif_view.open();
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
                if(abc.counter == 10){
                    payment_view.close();
                    notif_view.show_detail = qsTr("We're apologize, Your payment session is expired.\n Your transaction will be aborted.");
                    abort_transaction(selectedPayment);
                    notif_view.z = 100;
                    notif_view.escapeFunction = "backToMain";
                    notif_view.open();
                    if (isPaid==false) abort_transaction(selectedPayment);
                }
                if(abc.counter < 0){
                    my_timer.stop()
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
                }
            }
        }
    }

    BackButton{
        id:back_button
        x: 100 ;y: 40;
        MouseArea{
            anchors.fill: parent
            onClicked: {
                my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
            }
        }
    }


    //==============================================================
    //PUT MAIN COMPONENT HERE

    TextRectangle{
        id: textRectangle
        x:432; y:204
        width: 700
        height: 80
    }

    TextInput {
        id: inputText
//        x: 441
//        y: 315
//        width: 682
        anchors.centerIn: textRectangle;
        text: textInput
//        text: "INPUT NUMBER 1234567890SRDCVBUVTY"
        cursorVisible: true
        horizontalAlignment: Text.AlignLeft
        font.family: "Gotham"
        font.pixelSize: 40
        color: "darkred"
        clip: true
        visible: true
        focus: true
    }

    NumKeyboard{
        id:virtual_numpad
        x:514; y:439
        property int count:0
        enabled: !payment_view.visible

        Component.onCompleted: {
            virtual_numpad.strButtonClick.connect(typeIn)
            virtual_numpad.funcButtonClicked.connect(functionIn)
        }

        function functionIn(str){
            if(str == "OK"){
                if(press != "0"){
                    return
                }
                press = "1"
                //TODO Put another function here
            }
            if(str=="Back"){
                count--;
                textInput=textInput.substring(0,textInput.length-1);
                press = "0"
            }
            if(str=="Clear"){
                count = 0;
                textInput = "";
                press = "0";
            }
        }

        function typeIn(str){
            press = "0"
//            console.log("input :", str)
//            count++
//            if (count<max_count){
//                base_page.textInput += str
//            }
//            console.log("output :", base_page.textInput)
            if (str == "" && count > 0){
                if(count>=max_count){
                    count=max_count
                }
                count--
                textInput=textInput.substring(0,count);
            }
            if (str!=""&&count<max_count){
                count++
            }
            if (count>=max_count){
                str=""
            }
            else{
                textInput += str
            }
            abc.counter = timer_value
            my_timer.restart()
        }
    }

    Column{
        x: 891
        y: 383
        spacing: 10
        Button{
            id: button_edc
            width: 150
            height: 150
            Image{
                id: img_edc
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "source/credit card black.png"
                fillMode: Image.Stretch

            }
            Text{
                id: button_edc_label
                text: "EDC"
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
                console.log("EDC button is pressed");
                if (clear_payment_session()===true){
                    selectedPayment = "EDC"
                    _SLOT.start_set_payment(selectedPayment)
                    if(press != "0") return
                    press = "1"
                    if(textInput==""){
                        not_amount()
                        return
                    }
                    if (isReadyEDC==true){
                        abc.counter = timer_value;
                        my_timer.restart();
                        _SLOT.create_sale_edc(textInput);
                        payment_view.show_text = FUNC.get_payment_text("EDC");
                        payment_view.useMode = "EDC"
                        payment_view.open();
                    }else{
                        not_ready_device();
                    }
                } else {
                    not_open_session();
                }
            }
        }
        Button{
            id: button_prepaid
            width: 150
            height: 150
            Image{
                id: img_prepaid
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "source/prepaid black.png"
                fillMode: Image.Stretch
            }
            Text{
                id: button_prepaid_label
                text: "Prepaid"
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
                console.log("Prepaid button is pressed");
                if (clear_payment_session()===true){
                    selectedPayment = "QPROX"
                    _SLOT.start_set_payment(selectedPayment)
                    if(press != "0") return
                    press = "1"
                    if(textInput==""){
                        not_amount()
                        return
                    }
                    if (isReadyQPROX==true){
                        abc.counter = timer_value;
                        my_timer.restart();
                        if(parseInt(textInput) > 1000000){
                            notif_view.show_detail = qsTr("Please choose another,\n Total payment can be handled by this method is under Rp.1.000.000,-");
                            notif_view.open()
                        } else {
                            payment_view.show_text = FUNC.get_payment_text("QPROX");
                            payment_view.useMode = "QPROX"
                            payment_view.open();
                        }
                    }else{
                        not_ready_device()
                    }
                } else {
                    not_open_session();
                }
            }
        }
        Button{
            id: button_cash
            width: 150
            height: 150
            Image{
                id: img_cash
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "source/cash black.png"
                fillMode: Image.Stretch
            }
            Text{
                id: button_cash_label
                text: "Cash"
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
                console.log("Cash button is pressed");
                if (clear_payment_session()===true){
                    selectedPayment = "MEI"
                    _SLOT.start_set_payment(selectedPayment)
                    if(press != "0") return
                    press = "1"
                    if(textInput=="" || textInput.length < 4){
                        notif_view.show_detail = qsTr("Minimum amount 4 digit for this test..!");
                        notif_view.isSuccess = false;
                        notif_view.open();
                    }
                    if (isReadyMEI==true){
                        abc.counter = timer_value;
                        my_timer.restart();
    //                    payment_view.show_text = FUNC.get_payment_text("MEI");
                        payment_view.show_text = "";
                        payment_view.useMode = "MEI"
                        payment_view.open();
                        _SLOT.set_rounded_fare(textInput)
                        _SLOT.start_accept_mei();
                    }else{
                        not_ready_device()
                    }
                } else {
                    not_open_session();
                }
            }
        }

    }


    //==============================================================

    ConfirmView{
        id: confirm_view
        show_text: qsTr("Dear Customer")
        show_detail: qsTr("Proceed This ?")
        z: 99
        MouseArea{
            id: ok_confirm_view
            x: 668; y:691
            width: 190; height: 50;
            onClicked: {
                console.log("Confirmation OK button is pressed");
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
        show_text: qsTr("Being Processed...")
    }


//    PaymentViewAdmin{
//        id: payment_view
//        z: 99
//        useMode: "EDC"
//        show_text: ""
//        count100: "0"
//        count50: "0"
//        count20: "0"
//        count10: "0"
//        count5: "0"
//        count2: "0"
//        totalCount: "0"//"470000"
//        count5R: "0"//"2"
//        count2R: "0"//"10"
//        totalCountR: "0"//"30000"
//        totalAmount: "0"//"399000"
//    }

    PaymentView{
        id: payment_view
        z: 99
        useMode: "MEI"
        show_text: ""
        totalCost: textInput
        totalGetCount: "0"
        isTest: true
    }

}

