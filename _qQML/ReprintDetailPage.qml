import QtQuick 2.4
import QtQuick.Controls 1.3
import "base_function.js" as FUNC

Base{
    id: reprint_detail
    mode_: "reverse"
    isPanelActive: true
    textPanel: qsTr("Flight Summary")
    imgPanel: "aAsset/form_filling.png"
    property int timer_value: 60
    property var detail_info: undefined
    property bool debuggingMode: false
    property var press: '0'
    property bool isRoundTrip: false
    property var baseFareTicket: ''
    property bool reconfirmAble: false

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            abc.counter = timer_value;
            my_timer.start();
            press = '0';
            baseFareTicket = '0';
            parse_detail_info(detail_info);
            reconfirmAble = false;
            isRoundTrip = false;
            notif_view.close();
        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop();
            loading_view.close();
        }
    }

    Component.onCompleted:{
        base.result_recreate_payment.connect(process_final_payment);
        base.result_reprint.connect(process_print);
    }

    Component.onDestruction:{
        base.result_recreate_payment.disconnect(process_final_payment);
        base.result_reprint.disconnect(process_print);
    }

    function process_print(p){
        console.log('process_print', p)
        var result = p.split('|')[1]

        if (result=='ERROR') {
            notif_view.isSuccess = false;
            notif_view.show_text = qsTr("We're apologize");
            notif_view.show_detail = qsTr("Something went wrong, Please retry later.");
        } else if (result=='DONE') {
            notif_view.isSuccess = true;
            notif_view.show_text = qsTr("Dear Customer");
            notif_view.show_detail = qsTr("Please get the new printed receipt below.");
        }
        notif_view.escapeFunction = 'backToMain'
        loading_view.close();
        notif_view.open();
    }

    function parse_detail_info(d){
        console.log('parse_detail_info', d);
        var i = JSON.parse(d);
        var x = JSON.parse(i.receiptData);
        payment_type_.labelContent = x.PAYMENT_METHOD;
        card_no_.labelContent = x.GET_CARD_NO;
        booking_code_.labelContent = i.bookingCode;
        trip_.labelContent = x.GET_TRIP;
        flight_.labelContent = x.GET_FLIGHT_NO_DEPART;
        from_.labelContent = x.GET_AIRPORT_DEPART.replace('\\r\\n', '').replace('\r\n', '');
        to_.labelContent = x.GET_AIRPORT_ARRIVAL;
        depart_date_.labelContent = x.GET_DATE_DEPART;
        depart_arrival_.labelContent = x.GET_TIME_DEPART_DEP + ' / ' + x.GET_TIME_ARRIVAL_DEP;
        ticket_price_.labelContent = FUNC.insert_dot(x.GET_TOTAL_COST);
        total_payment_.labelContent = FUNC.insert_dot(x.GET_TOTAL_PAID);
        transaction_date_.labelContent = x.TRANSACTION_DATE;
        if (i.t_payment_status=='PAID') {
            payment_status_.labelContent = 'CONFIRMED';
        } else {
            payment_status_.labelContent = 'WAITING';
        }
        if (x.GET_FLIGHT_NO_RETURN != ""){
            isRoundTrip = true;
            return_flight_.labelContent = x.GET_FLIGHT_NO_RETURN;
        }
        pax_list_.labelContent = x.GET_PASSENGER_LIST;
        baseFareTicket = i.t_grand_total;
        console.log('baseFareTicket is :', baseFareTicket);
        //check previous payment
        var payment_check = (parseInt(x.GET_TOTAL_PAID) >= parseInt(x.GET_TOTAL_COST)) ? true : false
        if (payment_check == true && i.t_payment_status != 'PAID') {
            reconfirmAble = true;
            reconfirm_button.enabled = true;
        }
        console.log('reconfirm status is :', reconfirmAble);
        /*
        {"GET_TIME_ARRIVAL_RET": "", "GET_TRANSIT_STATUS": false, "GET_TIME_DEPART_DEP": "19:50",
        "GET_TRIP": "Trip [ CGK -> SRG ]", "LEN_NUMBER": 7, "PAYMENT_METHOD": "CASH", "GET_BOOKING_CODE": "ODJGBO",
        "GET_TIME_ARRIVAL_DEP": "20:55", "ADMIN_FEE": "15000", "GET_AIRPORT_ARRIVAL": "Semarang (SRG)",
        "GET_FLIGHT_NO_RETURN": "", "GET_TOTAL_PAID": "645000", "GET_FLIGHT_NO_DEPART": "ID6352/BATIK AIR",
        "GET_PASSENGER_LIST": " Adult Passenger\\r\\n Name (1)   : Dedi Dores\\r\\n",
        "GET_AIRPORT_DEPART": "Jakarta (CGK) / Terminal\\r\\n 1C", "GET_INIT_FARE": "609000",
        "GET_TRANSIT_DATA": [], "GET_DATE_RETURN": "", "GET_TIME_DEPART_RET": "", "GET_TICKET_PRICE": "630000",
        "ROUNDED_TICKET_PRICE": "", "GET_PAYMENT_STATUS": "OK", "GET_TOTAL_COST": "645000", "GET_DATE_DEPART": "03-08-2018"}
        */

    }

    function process_final_payment(r){
        console.log('parse_detail_info', r);
        loading_view.close();

        if (r=='ERROR'){
            notif_view.isSuccess = false;
            notif_view.show_text = qsTr("We're Apologize");
            notif_view.show_detail = qsTr("Payment reconfirmation is failed, Please retry later.");
            notif_view.escapeFunction = 'backToMain';
            notif_view.open();
            return
        } else if (r=='SUCCESS') {
            loading_view.show_text = qsTr('Reprinting Your Receipt');
            loading_view.open();
            _SLOT.start_reprint(r);
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
        x: 100 ;y: 40;
        MouseArea{
            anchors.fill: parent
            onClicked: {
                my_layer.pop()
            }
        }
    }

    //==============================================================
    //PUT MAIN COMPONENT HERE
    Text{
        id: raw_text_view
        x: 321
        y: 248
        width: 927
        height: 600
        visible: debuggingMode
        text: detail_info
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.italic: true
        font.pixelSize: 20
        font.family: 'Microsoft YaHei'
        color: 'gray'
    }

    GroupBox{
        id: group_text_info
        x: 310
        y: 124
        visible: !debuggingMode
        width: 950
        height: 650
        flat: true

        Column{
            id: row_texts
            spacing: 10
            TextDetailRow{
                id: payment_type_
                labelName: qsTr('Payment Type')
                labelContent: 'CASH'
            }
            TextDetailRow{
                id: card_no_
                labelName: qsTr('Card No.')
                labelContent: 'TES123'
                visible: (labelContent=='') ? false : true
            }
            TextDetailRow{
                id: booking_code_
                labelName: qsTr('Booking Code')
                labelContent: 'TES123'
            }
            TextDetailRow{
                id: trip_
                labelName: qsTr('Trip')
                labelContent: 'Trip [CGK] - [DPS]'
            }
            TextDetailRow{
                id: flight_
                labelName: qsTr('Flight')
                labelContent: 'JT123/LION Air'
            }
            TextDetailRow{
                id: from_
                labelName: qsTr('From')
                labelContent: 'Jakarta (CGK)'
            }
            TextDetailRow{
                id: to_
                labelName: qsTr('To')
                labelContent: 'Bali (DPS)'
            }
            TextDetailRow{
                id: depart_date_
                labelName: qsTr('Depart Date')
                labelContent: '03-08-2018'
            }
            TextDetailRow{
                id: depart_arrival_
                labelName: qsTr('Depart/Arrival')
                labelContent: '10:00/12:00'
            }
            TextDetailRow{
                id: return_flight_
                labelName: qsTr('Return Flight')
                labelContent: '12:00'
                visible: (isRoundTrip==true) ? true : false
            }
            TextDetailRow{
                id: ticket_price_
                labelName: qsTr('Ticket Price')
                labelContent: '999.000'
            }
            TextDetailRow{
                id: total_payment_
                labelName: qsTr('Total Payment')
                labelContent: '999.000'
            }
            TextDetailRow{
                id: payment_status_
                labelName: qsTr('Payment Status')
                labelContent: 'CONFIRMED'
                withBackground: true
            }
            TextDetailRow{
                id: transaction_date_
                labelName: qsTr('Transaction Date')
                labelContent: 'CONFIRMED'
            }
            TextDetailRow{
                id: pax_list_
                labelName: qsTr('Pax List')
                labelContent: 'Name 1, Name 2, Name 3'
                heightCell: 150
            }

        }

        Button{
            id: reconfirm_button
            x: 166
            y: 765
            width: 300
            height: 70
            enabled: false
            Image{
                x: -2
                y: 0
                width: 70
                height: 70
                scale: 0.5
                fillMode: Image.PreserveAspectFit
                source: "aAsset/icon_pembelian_black.png"
            }
            Text{
                text: qsTr("Re-Confirm Payment")
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

            onClicked: {
                if (press != "0") return;
                press = "1";
                _SLOT.start_recreate_payment(baseFareTicket);
                loading_view.show_text = qsTr('Reconfirming Your Payment');
                loading_view.open();
            }
        }


        Button{
            id: reprint_button
            x: 545
            y: 765
            width: 300
            height: 70
            Image{
                x: -2
                y: 0
                width: 70
                height: 70
                scale: 0.5
                fillMode: Image.PreserveAspectFit
                source: "aAsset/print.png"
            }
            Text{
                text: qsTr("Reprint Receipt")
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

            onClicked: {
                if (press != "0") return;
                press = "1";
                if (reconfirmAble==true){
                    notif_view.isSuccess = true;
                    notif_view.show_text = qsTr("Dear Customer");
                    notif_view.show_detail = qsTr("Please Press Re-Confirm Button First.");
                    notif_view.escapeFunction = 'closeWindow'
                    notif_view.open();
                } else {
                    _SLOT.start_reprint(payment_status_.labelContent);
                    notif_view.close();
                    loading_view.show_text = qsTr('Reprinting Your Receipt')
                    loading_view.open();
                }
            }
        }
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
        show_text: ""
        show_detail: ""
        z: 99
    }

    LoadingView{
        id:loading_view
        z: 99
        show_text: "Finding Flight..."
    }

}

