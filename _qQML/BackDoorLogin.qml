import QtQuick 2.4
import QtQuick.Controls 1.3
import "base_function.js" as FUNC

Base{
    id: test_payment
    mode_: "reverse"
    isPanelActive: true
    textPanel: qsTr("Input Secret Code")
    imgPanel: "source/input_secret_code.png"
    imgPanelScale: 0.8
    property int timer_value: 750
    property int max_count: 50
    property var press: "0"
    property var textInput: ""
    property var loginCode: "333123123"
    property var safeExit: "000000"
    property var exitCode: "333111555"
    property var collectCash: "88888888"
    property var voidEDC: "~!@#$%^&*()_+"
    property var totalCash: "0"
    property var totaltrx: "0"
    property var totalEDC: "0"
    property var totaltrxedc: "0"
    property var dummyEDCReceipt: "09876123450"
    property bool isVoid: false

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            _SLOT.start_get_cash_data();
            _SLOT.start_get_settlement();
            abc.counter = timer_value;
            my_timer.start();
            textInput = "";
            virtual_numpad.count = 0;
            backdoor_page.visible = false
            isVoid = false;
//            exitCode = Qt.formatDate(new Date(), "ddMMyy").replace('0', '9')
//            console.log(exitCode)

        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop();
            loading_view.close();
        }
    }

    Component.onCompleted:{
        base.result_general.connect(handle_general);
        base.result_list_cash.connect(handle_cash);
        base.result_collect_cash.connect(handle_collection);
        base.result_get_settlement.connect(handle_get_settlement);
        base.result_process_settlement.connect(handle_process_settlement);
        base.result_void_settlement.connect(handle_void_settlement);
    }

    Component.onDestruction:{
        base.result_general.disconnect(handle_general)
        base.result_list_cash.disconnect(handle_cash);
        base.result_collect_cash.disconnect(handle_collection);
        base.result_get_settlement.disconnect(handle_get_settlement);
        base.result_process_settlement.disconnect(handle_process_settlement);
        base.result_void_settlement.disconnect(handle_void_settlement);
    }

    function handle_void_settlement(result){
        console.log('handle_void_settlement : ', result);
        _SLOT.start_get_settlement();
        standard_loading.close();
    }

    function handle_get_settlement(result){
        console.log('handle_get_settlement : ', result);
        if (result==''||result==undefined||result=='NOT_FOUND'||result=='ERROR'){
            totalEDC = '0'
            totaltrxedc = '0'
            return
        }
        var e = JSON.parse(result);
        totalEDC = e.summary;
        totaltrxedc = e.total;
    }

    function handle_process_settlement(result){
        console.log('handle_process_settlement : ', result);
        if (result=='PLEASE_RETRY'){
            standard_loading.show_text = 'Syncing Settlement Data...';
            _SLOT.start_edc_settlement();
            return
        }
        if (result==''||result==undefined||result=='ERROR'||result=='FINISH'){
            standard_loading.close();
            return
        }
        if (result=="NOT_FOUND"){
            standard_loading.show_text = 'Settlement Result... NOT FOUND!!!';
            standard_loading.close();
            return
        }
        if (result=="TIMEOUT"){
            press = '0'
            standard_loading.show_text = 'Settlement Result... TIMEOUT!!!';
            standard_loading.close();
            return
        }
        if (result=='SUCCESS'){
            standard_loading.show_text = 'Clearing Settlement Data...';
            totalEDC = '0';
            totaltrxedc = '0';
            return
        }
    }

    function handle_collection(result){
        console.log('handle_collection : ', result);
        totalCash = '0';
        totaltrx = '0';
        standard_loading.close();
    }


    function handle_cash(result){
        console.log('handle_cash : ', result)
        if (result==''||result==undefined||result=='ZERO'){
            totalCash = '0';
            totaltrx = '0';
            return
        }
        var c = JSON.parse(result)
        totaltrx = c.total
        var cash = c.data
        var get_total = 0
        for (var i in cash){
            get_total += parseInt(cash[i].amount)
        }
        totalCash = get_total.toString()
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
        font.family: "GothamRounded"
        font.pixelSize: 40
        color: "darkred"
        clip: true
        visible: true
        focus: true
    }

    NumKeyboard{
        id:virtual_numpad
        x:648; y:371
        property int count:0

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
                if(textInput==loginCode){
                    my_layer.push(test_payment_page);
                } else if(textInput==safeExit){
                    confirm_view.show_text = qsTr("Hi User,");
                    confirm_view.show_detail = qsTr("Safely quit from Kiosk App?");
                    confirm_view.escapeFunction = 'backToMain';
                    confirm_view.open();
                } else if(textInput==exitCode){
                    confirm_view.show_text = qsTr("Hi User,")
                    confirm_view.show_detail = qsTr("Quit from Kiosk App?");
                    confirm_view.escapeFunction = 'backToMain';
                    confirm_view.open();
                } else if(textInput==collectCash){
                    test_payment.textPanel = qsTr("Operator Menu")
                    backdoor_page.open_()
                } else if(textInput==voidEDC){
                    test_payment.textPanel = qsTr("SuperAdmin Menu")
                    isVoid = true
                    backdoor_page.open_()
                } else if(textInput==dummyEDCReceipt){
                    _SLOT.start_dummy_edc_receipt()
                    my_timer.stop()
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
                } else {
                    notif_view.show_text = qsTr("Hi User,")
                    notif_view.show_detail = qsTr("Please use the correct code to enter..!")
                    notif_view.open()
                }
            }
            if(str=="Back"){
                count--
                textInput=textInput.substring(0,textInput.length-1);
            }
            if(str=="Clear"){
                count = 0;
                textInput = "";
            }
        }

        function typeIn(str){
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

    Button{
        id: login_button
        x: 1032
        y: 529
        width: 100
        height: 200
        enabled: (backdoor_page.visible==false || confirm_view.visible==false) ? true : false
//        text: "Login"
        Text{
            text: "Login"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.fill: parent
            font.bold: true
            font.family: "GothamRounded"
            font.pixelSize: 20
        }
        onClicked: {
            if(textInput==loginCode){
                my_layer.push(test_payment_page)
            } else if(textInput==safeExit){
                confirm_view.show_text = qsTr("Hi User,");
                confirm_view.show_detail = qsTr("Safely quit from Kiosk App?");
                confirm_view.escapeFunction = 'backToMain';
                confirm_view.open();
            } else if(textInput==exitCode){
                confirm_view.show_text = qsTr("Hi User,")
                confirm_view.show_detail = qsTr("Quit from Kiosk App?")
                confirm_view.escapeFunction = 'backToMain'
                confirm_view.open()
            } else if(textInput==collectCash){
                test_payment.textPanel = qsTr("Operator Menu")
                backdoor_page.open_()
            } else if(textInput==voidEDC){
                test_payment.textPanel = qsTr("SuperAdmin Menu")
                isVoid = true
                backdoor_page.open_()
            } else if(textInput==dummyEDCReceipt){
                _SLOT.start_dummy_edc_receipt()
                my_timer.stop()
                my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
            } else {
                notif_view.show_text = qsTr("Hi User,")
                notif_view.show_detail = qsTr("Please use the correct code to enter..!")
                notif_view.open()
            }
        }
    }
    //==============================================================

    Rectangle{
        id: backdoor_page
        x: 300
        y: 100
        width: parent.width - 300
        height: parent.height - 100
        visible: false

        function open_(){
            backdoor_page.visible = true;
        }

        function close_(){
            backdoor_page.visible = false;
        }

        GroupBox{
            id: text_group
            x: 115
            y: 23
            width: 750
            height: 375
            title: "CASH COLLECTION"
            flat: true

            Rectangle{
                id: border_rec
                height: 350
                color: 'transparent'
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.top: parent.top
                border.width: 2
                border.color: 'gray'
            }

            Label {
                id: label_cash
                x: 0
                text: qsTr("Uncollected Cash")
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                font.bold: true
                font.pixelSize: 25
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                id: total_cash_text
                x: 316
                text: FUNC.insert_dot(totalCash)
                anchors.top: parent.top
                anchors.topMargin: 50
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 80
            }

            Label {
                id: label_trx
                x: 0
                text: qsTr("Total Transaction")
                anchors.top: parent.top
                anchors.topMargin: 175
                anchors.horizontalCenter: parent.horizontalCenter
                font.bold: true
                font.pixelSize: 20
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                id: total_trx_text
                x: 316
                y: 133
                text: totaltrx
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 110
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 30
            }

        }

        GroupBox{
            id: text_group_edc
            x: 115
            y: 411
            width: 750
            height: 375
            title: "EDC SETTLEMENT"
            flat: true

            Rectangle{
                id: border_rec_edc
                height: 350
                color: 'transparent'
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.top: parent.top
                border.width: 2
                border.color: 'gray'
            }

            Label {
                id: label_edc
                x: 0
                text: qsTr("Total Settlement")
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                font.bold: true
                font.pixelSize: 25
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                id: total_edc_text
                x: 316
                text: FUNC.insert_dot(totalEDC)
                anchors.top: parent.top
                anchors.topMargin: 50
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 80
            }

            Label {
                id: label_trxedc
                x: 0
                text: qsTr("Total Transaction")
                anchors.top: parent.top
                anchors.topMargin: 175
                anchors.horizontalCenter: parent.horizontalCenter
                font.bold: true
                font.pixelSize: 20
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                id: total_trx_text_edc
                x: 316
                y: 133
                text: totaltrxedc
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 110
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 30
            }

        }

        ConfirmButton{
            id: settlement_button
            x: 614;
            width: 190; height: 50;
            anchors.top: text_group_edc.bottom
            anchors.topMargin: -100
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            text_: (isVoid==false) ? qsTr("Send Settlement") : qsTr("Clear Batch")
            color_: (totaltrxedc!='0') ? 'darkred' : 'gray'
            MouseArea{
                visible: parent.visible
                enabled: (totaltrxedc!='0') ? true : false
                width: 190; height: 50;
                onClicked: {
                    if (press!='0') return
                    press = '1'
                    if (isVoid==false){
                        _SLOT.start_edc_settlement();
                        standard_loading.show_text = 'Please Wait, Sending Settlement Data...';
                    } else {
                        _SLOT.start_void_data();
                        standard_loading.show_text = 'Please Wait, Clearing Settlement Data...';
                    }
                    standard_loading.open();
                }
            }
        }

        ConfirmButton{
            id: collection
            x: 614;
            width: 190; height: 50;
            anchors.top: text_group.bottom
            anchors.topMargin: -100
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            text_: qsTr("Collect Cash")
            color_: (totaltrx!='0') ? 'darkred' : 'gray'
            MouseArea{
                visible: parent.visible
                enabled: (totaltrx!='0') ? true : false
                width: 190; height: 50;
                onClicked: {
                    if (press!='0') return
                    press = '1'
                    _SLOT.start_begin_collect_cash();
                    standard_loading.show_text = 'Please Wait, Syncing Cash Data...';
                    standard_loading.open();
                }
            }
        }

        ConfirmButton{
            id: shutdown
            x: 598; y:774
            width: 190; height: 50;
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            anchors.right: parent.right
            anchors.rightMargin: 192
            text_: qsTr("Shutdown")
            MouseArea{
                visible: parent.visible
                width: 190; height: 50;
                onClicked: {
                    if (press!='0') return
                    press = '1'
                    _SLOT.start_safely_shutdown('SHUTDOWN');
                    standard_loading.show_text = 'Please Wait, Powering Off Machine...'
                    standard_loading.open()
    //                Qt.quit();
                }
            }
        }

        ConfirmButton{
            id: restart
            x: 198; y:774
            width: 190
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            anchors.right: parent.right
            anchors.rightMargin: 592
            text_: qsTr("Just Restart")
            MouseArea{
                visible: parent.visible
                width: 190; height: 50;
                onClicked: {
                    if (press!='0') return
                    press = '1'
                    _SLOT.start_safely_shutdown('RESTART');
                    standard_loading.show_text = 'Please Wait, Restarting Machine...'
                    standard_loading.open()
    //                Qt.quit();
                }
            }
        }
        Image{
            x: -201
            y: -31
            source: "source/close.png"
            width: 80
            height: 80
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    my_timer.stop()
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
                }
            }
        }

    }

    ConfirmView{
        id: confirm_view
//        visible: true
        show_text: qsTr("Dear Customer")
        show_detail: qsTr("Proceed This ?")
        cancelAble: false
        z: 99
        MouseArea{
            id: ok_confirm_view
            x: 668; y:691
            width: 190; height: 50;
            onClicked: {
                console.log("Confirmation OK button is pressed");
                _SLOT.start_safely_shutdown('SHUTDOWN');
                standard_loading.open()
//                Qt.quit();
            }
        }
        ConfirmButton{
            id: ok_button2
            x: 407; y:691
            visible: (confirm_view.visible==true && textInput==safeExit) ? true : false
            width: 190
            anchors.right: parent.right
            anchors.rightMargin: 683
            text_: qsTr("Just Restart")
            MouseArea{
                visible: parent.visible
                width: 190; height: 50;
                onClicked: {
                    console.log("Confirmation OK button is pressed");
                    _SLOT.start_safely_shutdown('RESTART');
                    standard_loading.open()
    //                Qt.quit();
                }
            }
        }
        Image{
            x: 972
            source: "source/close.png"
            width: 80
            height: 80
            anchors.top: parent.top
            anchors.topMargin: 182
            anchors.right: parent.right
            anchors.rightMargin: 228
            MouseArea{
                anchors.fill: parent
                onClicked: {
                        parent.close()
                }
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
        show_text: qsTr("Searching...")
    }

    StandartLoadingView{
        id: standard_loading
        x: 0
        y: 0
        z: 99

    }




}

