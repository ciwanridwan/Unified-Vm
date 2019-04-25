import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.3
//import QtQml.Models 2.1
import "base_function.js" as FUNC

Base{
    id: base_select_seat
    mode_ : "reverse"
    isPanelActive: true
    textPanel: (language=='INA') ?  qsTr('Pilih Kursi Anda') : qsTr("Choose Your Seat")
    imgPanel: "aAsset/icon/seat-white.png"
    imgPanelScale: 0.8
    property int timer_value: 300

    property variant seatData: []
    property var flightData: undefined

    property var bookingNo: 'ABC123'
    property var customerName: 'MR Wahyudi Imam'
    property var flightNo: 'JT 123'
    property var originCity: 'CGK'
    property var originTime: '18:00'
    property var destinationCity: 'DPS'
    property var destinationTime: '20:00'
    property var flightDataRaw: undefined
    property var statusCustomer: 'OPEN FOR CHECK-IN'
    property var departDate: 'FRI, 7 Dec 2018'
    property var selectedSeat: 'undefined'

    signal connectSeatSignal(string str)

    property var idSeat: undefined


    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            abc.counter = timer_value;
            my_timer.restart();
            loading_view.open();
            parse_flight_data(flightData);
            parse_seat_option(seatData);
        }
        if(Stack.status==Stack.Deactivating){
            loading_view.close();
            notif_view.close();
            confirm_view.close();
            my_timer.stop();
        }
    }

    Component.onCompleted: {
        base.result_general.connect(handle_general);
        base.result_get_boarding_pass.connect(handle_boarding_pass);
        connectSeatSignal.connect(handle_seat);

    }

    Component.onDestruction: {
        base.result_general.disconnect(handle_general);
        base.result_get_boarding_pass.disconnect(handle_boarding_pass);
        connectSeatSignal.disconnect(handle_seat);

    }

    function handle_boarding_pass(result){
        console.log(result);
        loading_view.close();
        if (result=='ERROR'){
            notif_view.z = 100;
            notif_view.isSuccess = false;
            notif_view.escapeFunction = 'backToMain'
            notif_view.show_text = (language=="INA") ? "Mohon Maaf" : "We're Apologize";;
            notif_view.show_detail = (language=="INA") ? "Terjadi Kesalahan, Silakan Hubungi Petugas Check-In" : "Something Went Wrong, Please report to Check-In Officer";
            notif_view.open();
            return;
        }
        //TODO Handle Boarding Pass Result
        my_layer.push(checkin_success);
    }


    function parse_flight_data(f){
        if (f==undefined) return;
        bookingNo = f.booking_code;
        customerName = f.passenger_name;
        flightNo = f.flight_no;
        originCity = f.origin;
        originTime = f.depart_time;
        destinationCity = f.destination;
        destinationTime = f.arrival_time;
        flightDataRaw = f.raw;
        statusCustomer = f.status;
        departDate = f.depart_date;
    }

    function parse_seat_option(s){
        if (s.length < 1) return;
        console.log('[START] preparing_seat_data : ', Qt.formatDate(new Date(), "yyyy-MM-dd"), Qt.formatTime(new Date(),"hh:mm:ss"))
        seat_model.clear();
        for (var i = 0; i < s.length; i++){
            seat_model.append({
                                  '_seat_no': s[i].seat_no,
                                  '_seat_pos': s[i].seat_pos,
                                  '_seat_type': s[i].seat_type,
                                  '_seat_a': s[i].seat_a,
                                  '_seat_b': s[i].seat_b,
                                  '_seat_c': s[i].seat_c,
                                  '_seat_d': s[i].seat_d,
                                  '_seat_e': s[i].seat_e,
                                  '_seat_f': s[i].seat_f,
                                  '_delimit': s[i].delimit
                              });

        }

        listViewSeat.model = seat_model;
        console.log('[FINISH] preparing_seat_data : ', Qt.formatDate(new Date(), "yyyy-MM-dd"), Qt.formatTime(new Date(),"hh:mm:ss"));
        loading_view.close();

    }

    function handle_seat(seat){
//        if (itemRowSeat==undefined) return;
        console.log('GET selected_seat : ', seat);
        selectedSeat = seat;
        itemRowSeat.externalResetKey(seat);
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
                timer_text.text = abc.counter
                abc.counter -= 1
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
        spacing: 5
        z: 100
        Text{
            text: (language=='INA') ? qsTr("Sisa Waktu : ") : qsTr("Time Left : ")
            font.pixelSize: 20
            color: "yellow"
            font.family: "Ubuntu"
        }
        Text{
            id: timer_text
            font.pixelSize: 20
            text: "500"
            color: "yellow"
            font.family: "Ubuntu"
        }
    }


    BackButton{
        id:back_button
        x: 100 ;y: 40;
        visible: true
        MouseArea{
            anchors.fill: parent
            onClicked: {
                my_layer.pop()
            }
        }
    }

    CancelButton{
        id:cancel_button1
        x: 100 ;y: 40;
        visible: !back_button.visible
        MouseArea{
            anchors.fill: parent
            onClicked: {
                my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
            }
        }
    }

    GroupBox{
        id: table_group
        x: 0
        flat: true
        width: 950
        height: 105
        anchors.top: parent.top
        anchors.topMargin: 100
        anchors.left: parent.left
        anchors.leftMargin: 310


        Text{
            id: flight_data_title
            width: parent.width
            height: 25
            color: 'darkred'
            font.pixelSize: 20
            font.bold: true
            horizontalAlignment: Text.AlignLeft
            text: (language=='INA') ? 'Rincian Penerbangan' : 'Flight Details'
        }

        Row{
            id: row_table_label
            width: parent.width
            height: parent.height - flight_data_title.height
            anchors.top: flight_data_title.bottom
            anchors.topMargin: 10
            spacing: 0

            property var headColor: 'darkred'

            Column{
                id: col_booking_code
                spacing: 0
                width: (parent.width/10) * 1
                height: parent.height
                Rectangle{
                    color: row_table_label.headColor
                    height: parent.height/2.5
                    width: parent.width
                    Text{
                        width: parent.width
                        height: parent.height
                        text: 'PNR'
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: 'white'
                    }
                }
                Rectangle{
                    color: 'white'
                    height: parent.height/2
                    width: parent.width
                    border.color: 'darkred'
                    Text{
                        width: parent.width
                        height: parent.height
                        text: bookingNo
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: 'darkred'
                    }
                }
            }

            Column{
                id: col_flight_no
                spacing: 0
                width: (parent.width/10) * 1
                height: parent.height
                Rectangle{
                    color: row_table_label.headColor
                    height: parent.height/2.5
                    width: parent.width
                    Text{
                        width: parent.width
                        height: parent.height
                        text: (language=='INA') ? 'Pesawat' : 'Flight';
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: 'white'
                    }
                }
                Rectangle{
                    color: 'white'
                    height: parent.height/2
                    width: parent.width
                    border.color: 'darkred'
                    Text{
                        width: parent.width
                        height: parent.height
                        text: flightNo
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: 'darkred'
                    }
                }
            }

            Column{
                id: col_passenger_name
                spacing: 0
                width: (parent.width/10) * 2
                height: parent.height
                Rectangle{
                    color: row_table_label.headColor
                    height: parent.height/2.5
                    width: parent.width
                    Text{
                        width: parent.width
                        height: parent.height
                        text: (language=='INA') ? 'Penumpang' : 'Passenger';
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: 'white'
                    }
                }
                Rectangle{
                    color: 'white'
                    height: parent.height/2
                    width: parent.width
                    border.color: 'darkred'
                    Text{
                        width: parent.width
                        height: parent.height
                        text: customerName
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: 'darkred'
                    }
                }
            }

            Column{
                id: col_depart_date
                spacing: 0
                width: (parent.width/10) * 2
                height: parent.height
                Rectangle{
                    color: row_table_label.headColor
                    height: parent.height/2.5
                    width: parent.width
                    Text{
                        width: parent.width
                        height: parent.height
                        text: (language=='INA') ? 'Berangkat' : 'Departure';
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: 'white'
                    }
                }
                Rectangle{
                    color: 'white'
                    height: parent.height/2
                    width: parent.width
                    border.color: 'darkred'
                    Text{
                        width: parent.width
                        height: parent.height
                        text: departDate
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: 'darkred'
                    }
                }
            }

            Column{
                id: col_origin
                spacing: 0
                width: (parent.width/10) * 2
                height: parent.height
                Rectangle{
                    color: row_table_label.headColor
                    height: parent.height/2.5
                    width: parent.width
                    Text{
                        width: parent.width
                        height: parent.height
                        text: (language=='INA') ? 'Asal' : 'Origin';
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: 'white'
                    }
                }
                Rectangle{
                    color: 'white'
                    height: parent.height/2
                    width: parent.width
                    border.color: 'darkred'
                    Text{
                        width: parent.width
                        height: parent.height
                        text: originCity + ' - ' + originTime
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: 'darkred'
                    }
                }
            }

            Column{
                id: col_destination
                spacing: 0
                width: (parent.width/10) * 2
                height: parent.height
                Rectangle{
                    color: row_table_label.headColor
                    height: parent.height/2.5
                    width: parent.width
                    Text{
                        width: parent.width
                        height: parent.height
                        text: (language=='INA') ?  'Tujuan' : 'Destination';
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: 'white'
                    }
                }
                Rectangle{
                    color: 'white'
                    height: parent.height/2
                    width: parent.width
                    border.color: 'darkred'
                    Text{
                        width: parent.width
                        height: parent.height
                        text: destinationCity + ' - ' + destinationTime
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: 'darkred'
                    }
                }
            }

        }

    }


    Item  {
        id: flickable_items
        enabled: (confirm_view.visible==false) ? true : false
        width:520
        height:800
        anchors.horizontalCenterOffset: 50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        //        ScrollBarVertical{
//            id: vertical_sbar
//            flickable: listViewSeat
//            height: flickable_items.height
//            color: "gray"
//            expandedWidth: 15
//        }

        ListView{
            id: listViewSeat
            anchors.fill: parent
            contentWidth: parent.width
            spacing: 0
            flickDeceleration: 750
            maximumFlickVelocity: 1500
            layoutDirection: Qt.LeftToRight
            boundsBehavior: Flickable.StopAtBounds
            cacheBuffer: 500
            keyNavigationWraps: true
            snapMode: GridView.SnapToRow
            clip: true
            focus: true
            delegate: component_seat
        }

        ListModel {
            id: seat_model
        }

        Component{
            id: component_seat
            RowSeat{
                id: itemRowSeat
                idParent: base_select_seat
                canSelect: true
                textBack: (language=='INA') ? 'BELAKANG' : 'BACK'
                textFront: (language=='INA') ? 'DEPAN' : 'FRONT'
                seat_no: _seat_no
                seat_pos: _seat_pos
                seat_type: _seat_type
                seat_a: _seat_a
                seat_b: _seat_b
                seat_c: _seat_c
                seat_d: _seat_d
                seat_e: _seat_e
                seat_f: _seat_f
                delimit: _delimit

            }
        }
    }


    GroupBox{
        id: box_legend
        flat: true
        height: flickable_items.height
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: flickable_items.right
        anchors.leftMargin: 0
        width: 300

        Text{
            id: label_selected_seat
            text: (language=='INA') ? 'PILIHAN KURSI' : 'SELECTED SEAT';
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: 'darkred'
            font.bold: true
            font.family: 'Microsoft YaHei'
            font.pixelSize: 20
        }

        Rectangle{
            id: selected_number
            radius: 30
            anchors.top: parent.top
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            color: 'orange'
            width: 150
            height: 150
            Text{
                anchors.fill: parent
                text: selectedSeat
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                visible: (selectedSeat!='undefined') ? true : false
                color: 'white'
                font.bold: true
                font.family: 'Microsoft YaHei'
                font.pixelSize: 50
            }
        }


        Rectangle{
            id: legend_available
            radius: 15
            anchors.top: parent.top
            anchors.topMargin: 240
            anchors.horizontalCenter: parent.horizontalCenter
            color: 'green'
            width: 80
            height: 80
            Text{
                anchors.fill: parent
                text: (language=='INA') ?  'TERSEDIA' : 'AVAILABLE SEAT';
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: 'white'
                font.bold: true
                font.family: 'Microsoft YaHei'
                font.pixelSize: 10
            }
        }

        Rectangle{
            id: legend_emergency
            radius: 15
            anchors.top: parent.top
            anchors.topMargin: 340
            anchors.horizontalCenter: parent.horizontalCenter
            color: 'silver'
            width: 80
            height: 80
            Text{
                anchors.fill: parent
                text: (language=='INA') ? 'TIDAK TERSEDIA' : 'NOT AVAILABLE';
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: 'white'
                font.bold: true
                font.family: 'Microsoft YaHei'
                font.pixelSize: 10
            }
        }

        Rectangle{
            id: legend_not_available
            radius: 15
            anchors.top: parent.top
            anchors.topMargin: 440
            anchors.horizontalCenter: parent.horizontalCenter
            color: 'red'
            width: 80
            height: 80
            Text{
                anchors.fill: parent
                text: (language=='INA') ? 'TERISI' : 'OCCUPIED';
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: 'white'
                font.bold: true
                font.family: 'Microsoft YaHei'
                font.pixelSize: 10
            }
        }


    }

    Button{
        id: confirm_button
        width: 275
        height: 70
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80
        anchors.horizontalCenter: box_legend.horizontalCenter
        visible: (selectedSeat!='undefined') ? true : false
        Text{
            id: next_button_label
            text: (language=='INA') ? 'LANJUTKAN' : 'PROCEED';
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
//            console.log('Confirm Button is Pressed!');
//            var len = 35;
//            if (language=='INA'){
//                var text_notif = FUNC.serialize_text('Kode Booking', bookingNo, len);
//                text_notif += FUNC.serialize_text('No Penerbangan', flightNo, len);
//                text_notif += FUNC.serialize_text('Nama Penumpang', customerName, len);
//                text_notif += FUNC.serialize_text('Keberangkatan', departDate, len);
//                text_notif += FUNC.serialize_text('Asal', originCity + ' - ' + originTime, len);
//                text_notif += FUNC.serialize_text('Tujuan', destinationCity + ' - ' + destinationTime, len);
//                text_notif += FUNC.serialize_text('Pilihan Kursi', selectedSeat + '\n', len);
//                confirm_view.show_detail = text_notif + "Lanjutkan Proses ?";
//                confirm_view.show_text = qsTr('Penumpang YTH');
//            } else {
//                var _text_notif = FUNC.serialize_text('Booking Code', bookingNo, len);
//                _text_notif += FUNC.serialize_text('Flight No', flightNo, len);
//                _text_notif += FUNC.serialize_text('Passenger Name', customerName, len);
//                _text_notif += FUNC.serialize_text('Departure', departDate, len);
//                _text_notif += FUNC.serialize_text('Origin', originCity + ' - ' + originTime, len);
//                _text_notif += FUNC.serialize_text('Destination', destinationCity + ' - ' + destinationTime, len);
//                _text_notif += FUNC.serialize_text('Selected Seat', selectedSeat + '\n', len);
//                confirm_view.show_detail = _text_notif + "Proceed this flight ?";
//                confirm_view.show_text = qsTr('Dear Customer');
//            }
            confirm_view.open();
        }
    }

    ConfirmCheckInView{
        id: confirm_view;
        modeLanguage: language
//        visible: true
        MouseArea{
            id: ok_confirm_view
            x: 734; y:871
            width: 190; height: 50;
            onClicked: {
                confirm_view.close();
                loading_view.show_text = (language=='INA') ? 'Memesan Kursi Anda...' : 'Reserving Your Seat...';
                loading_view.open();
                var param = JSON.stringify({'seat_no': selectedSeat});
                console.log('Selected Seat : ', param);
                _SLOT.start_get_boarding_pass(param);
            }
        }
    }

    NotifView{
        id: notif_view
        isSuccess: false
        show_text: qsTr("We're Apologize")
        show_detail: qsTr("Something went wrong.")
        z: 99
    }

    LoadingView{
        id:loading_view
        z: 99
        show_text: qsTr("Preparing...")
    }


}

