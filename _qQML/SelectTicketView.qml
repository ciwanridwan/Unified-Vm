import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.3
import QtQml.Models 2.1
import "base_function.js" as FUNC

Base{
    id: base_select_ticket
    mode_ : "reverse"
    isPanelActive: true
    textPanel: qsTr("Choose Your Departure")
    imgPanel: "source/take_off_panel.png"
    imgPanelScale: 0.8
    property int timer_value: 150
    property var list_flight: undefined
    property var departDate
    property var returnDate
    property var originFrom: "Tangerang - CGK"
    property var destinationTo: "Denpasar - DPS"
    property var selectedPrice: []
    property string typeTemp:""
    property string valueTemp:""
    property var press: "0"
    property var orderList
    signal get_selected_price(string str)
    property bool getReturnActivated: false
    property var selectedChart: []
    property int time_sort: 0
    property int price_sort: 0
    property var press_sort: '0'
    property bool sendChart: true
    property bool sendConfirm: true
    property int totalDeparture: 0
    property int totalReturn: 0
    property int defaultMargin: 3


    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            abc.counter = timer_value
            my_timer.restart()
            loading_view.open()
            getReturnActivated = false
            sendChart = true
            sendConfirm = true
            press = '0'
            press_sort = "0"
            time_sort = 0
            price_sort = 0
            typeTemp = ''
            valueTemp = ''
            _SLOT.get_kiosk_price_setting()
            if(depart_model.count>0){
                textPanel = qsTr("Choose Your Departure")
                listViewTicket.model = depart_model
                loading_view.close()
                orderList = []
                selectedPrice = []
                selectedChart = []
                departDate = undefined
                returnDate = undefined
            }
            if(list_flight==="NO DATA"||list_flight.length<10){
                loading_view.close()
                notif_view.isSuccess = false
                notif_view.show_text = qsTr("Dear Customer")
                notif_view.show_detail = qsTr("Your plan is not available, Please set another schedule plan.")
                notif_view.escapeFunction = 'backToPrevious'
                notif_view.open()
            } else{
                parse_flight_data(list_flight)
            }
        }
        if(Stack.status==Stack.Deactivating){
//            depart_model.clear()
//            return_model.clear()
            loading_view.close()
            notif_view.close()
            confirm_view.close()
            my_timer.stop()
        }
    }

    Component.onCompleted: {
        get_selected_price.connect(selected_price);
        base.result_create_chart.connect(get_chart_result);
        base.result_confirm_schedule.connect(define_next_process);
        base.result_general.connect(handle_general);
        base.result_flight_data_sorted.connect(get_schedule_sorted);
        base.result_price_setting.connect(price_setting);
    }

    Component.onDestruction: {
        get_selected_price.disconnect(selected_price);
        base.result_create_chart.disconnect(get_chart_result);
        base.result_confirm_schedule.disconnect(define_next_process)
        base.result_general.disconnect(handle_general);
        base.result_flight_data_sorted.disconnect(get_schedule_sorted);
        base.result_price_setting.disconnect(price_setting);
    }

    function price_setting(s){
        // TODO check below function
        console.log("price_setting : ", JSON.stringify(s))
        var _s = JSON.parse(s)
        defaultMargin = parseInt(_s.margin)
    }

    function get_schedule_sorted(text){
        console.log('[START] sorting_flight_data : ', Qt.formatDate(new Date(), "yyyy-MM-dd"), Qt.formatTime(new Date(),"hh:mm:ss"))
        depart_model.clear()
        return_model.clear()
        var originFrom_temp = originFrom.substring(originFrom.length-3)
        var destinationTo_temp = destinationTo.substring(destinationTo.length-3)
        var f = JSON.parse(text)
        for (var i = 0; i < f.length; i++){
            var fromTo_temp = (f[i].flight_status=="DEPARTURE") ? originFrom_temp + ' - ' + destinationTo_temp : destinationTo_temp + ' - ' + originFrom_temp
            var color_temp = (f[i].flight_no.substring(0,2)=="ID") ?  "purple" : "red"
            if(f[i].flight_status=="DEPARTURE"){
                depart_model.append({"price1_" : f[i].promo_price.toString(),
                                        "price2_" : f[i].eco_price.toString(),
                                        "price3_" : f[i].bus_price.toString(),
                                        "f_no_": f[i].flight_no,
                                        "f_time_": f[i].flight_time,
                                        "qty1_": parseInt(f[i].promo_qty),
                                        "qty2_": parseInt(f[i].eco_qty),
                                        "qty3_" : parseInt(f[i].bus_qty),
                                        "fromTo_" : fromTo_temp,
                                        "color_": color_temp,
                                        "raw1_": f[i].raw_data_promo,
                                        "raw2_": f[i].raw_data_eco,
                                        "raw3_": f[i].raw_data_bus,
//                                            "raw0_": f[i].raw_data_parent,
                                        "f_status_": f[i].flight_status,
                                        "f_type_": f[i].flight_type,
                                        "f_origin_": f[i].origin,
                                        "f_route_trip_": f[i].route_trip,
                                        "f_is_transit_": f[i].is_transit,
                                        "f_is_same_origin_": f[i].is_same_origin,
                                        "f_trans_flight_time_": f[i].trans_flight_time,
                                        "f_trans_flight_no_" : f[i].trans_flight_no,
                                        "f_trans_flight_point_": f[i].trans_flight_point
                                    })
            } else {
                return_model.append({"price1_" : f[i].promo_price.toString(),
                                        "price2_" : f[i].eco_price.toString(),
                                        "price3_" : f[i].bus_price.toString(),
                                        "f_no_": f[i].flight_no,
                                        "f_time_": f[i].flight_time,
                                        "qty1_": parseInt(f[i].promo_qty),
                                        "qty2_": parseInt(f[i].eco_qty),
                                        "qty3_" : parseInt(f[i].bus_qty),
                                        "fromTo_" : fromTo_temp,
                                        "color_": color_temp,
                                        "raw1_": f[i].raw_data_promo,
                                        "raw2_": f[i].raw_data_eco,
                                        "raw3_": f[i].raw_data_bus,
//                                            "raw0_": f[i].raw_data_parent,
                                        "f_status_": f[i].flight_status,
                                        "f_type_": f[i].flight_type,
                                        "f_origin_": f[i].origin,
                                        "f_route_trip_": f[i].route_trip,
                                        "f_is_transit_": f[i].is_transit,
                                        "f_is_same_origin_": f[i].is_same_origin,
                                        "f_trans_flight_time_": f[i].trans_flight_time,
                                        "f_trans_flight_no_" : f[i].trans_flight_no,
                                        "f_trans_flight_point_": f[i].trans_flight_point
                                    })
            }
        }
        if (getReturnActivated===true) {
            listViewTicket.model = return_model
        } else {
            listViewTicket.model = depart_model
        }
        press_sort = "0"
        console.log('[FINISH] sorting_flight_data : ', Qt.formatDate(new Date(), "yyyy-MM-dd"), Qt.formatTime(new Date(),"hh:mm:ss"))
//        loading_view.close()
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

    function define_next_process(result){
//        console.log("confirm_schedule result : ", result)
        if (result==""||result==undefined||result=="ERROR") {
            loading_view.close()
            notif_view.show_text = qsTr("We're Apologize")
            notif_view.show_detail = qsTr("Your Flight Plan is no longer Available, Please set another.")
            notif_view.escapeFunction = 'backToPrevious'
            notif_view.open()
        }
        if (result=='SUCCESS' && selectedPrice.length > 0){
            my_layer.push(input_details,{
                              selectedPrice: selectedPrice,
                              orderList: orderList,
                              originFrom: originFrom,
                              destinationTo: destinationTo,
                              departDate: departDate,
                              returnDate: returnDate,
                              selectedChart: selectedChart
                          });

        } else {
            loading_view.close()
            notif_view.show_text = qsTr("We're Apologize")
            notif_view.show_detail = qsTr("Something went wrong when confirming Your Flight Plan, Please set another.")
            notif_view.escapeFunction = 'backToMain'
            notif_view.open()
        }
    }

    function get_chart_result(c){
//        console.log("get_chart_result : ", c);
        typeTemp = "";
        valueTemp = "";
        if(c=="ERROR"||c=="MISSING DATA"){
            notif_view.open()
            selectedPrice = []
            selectedChart = []
            return
        }
        if (selectedChart.indexOf(c) == -1){
            selectedChart.push(c);
            if(returnDate===undefined || getReturnActivated == true && selectedPrice.length==2){
                loading_view.show_text = qsTr("Checking Schedule...");
                loading_view.open();
                if (sendConfirm==true){
                    _SLOT.start_confirm_schedule();
                    sendConfirm = false;
                }
            } else {
                if (totalReturn==0){
                    loading_view.close()
                    notif_view.isSuccess = false
                    notif_view.show_text = qsTr("Dear Customer")
                    notif_view.show_detail = qsTr("Return schedule is not available, Please set another schedule plan.")
                    notif_view.escapeFunction = 'backToPrevious'
                    notif_view.open()
                }
                textPanel = qsTr("Choose Your Return");
                imgPanel = "source/landing_panel.png";
                listViewTicket.model = return_model;
                getReturnActivated = true;
                press = "0";
                sendChart = true;
            }
        }
    }

    function selected_price(param){
        console.log("selected_price : ", sendChart, param)
        press = "0"
        if (param==undefined || param=="") return
//        while(selectedPrice.length > 0) {
//            selectedPrice.pop();
//        }
//        if (selectedPrice.indexOf(param) == -1){
//        }
        selectedPrice.push(param)
        img_f_status.source = (returnDate==undefined) ? "source/one_way.png" : "source/two_way.png"
        var p = JSON.parse(param)
        text_info_f_no.text = p.f_no
        text_info_f_time.text = (getReturnActivated==true) ? returnDate + " " +  p.f_time : departDate + " " +  p.f_time
        text_info_fromTo.text = p.fromTo
        img_info.source = p.f_logo
        typeTemp = (p.f_status=="DEPARTURE") ? "OB" : "IB";
        valueTemp = p.raw
        var sendparam = {
            "stype": typeTemp,
            "sval": valueTemp,
            "route_trip": p.fromTo
        };
        if (sendChart==true){
            _SLOT.start_create_chart(JSON.stringify(sendparam));
            sendChart = false;
        }
//        if(returnDate===undefined || returnDate!==undefined &&
//                selectedPrice.length == 1 || getReturnActivated == true){
//        }
//        console.log('selected_price result : ', selectedPrice)
    }

    function validate_order(){
        if(selectedPrice.length==0) return false;
        if(returnDate===undefined && selectedPrice.length>0) return true;
        if(returnDate!==undefined){
            if(selectedPrice.toString().indexOf("RETURNING")!==false &&
                    selectedPrice.toString().indexOf("DEPARTURE")!==false){
                return true;
            } else {
                return false;
            }
        }
    }

    /*
        {'bus_price': 0,
        'promo_qty': '143',
        'flight_date': '2018-07-01',
        'flight_time': '23:50 - 00:40',
        'eco_qty': '143',
        'bus_qty': 0,
        'promo_price': 905000,
        'flight_no': 'JT-39',
        'eco_price': 905000,
        'flight_status': 'ARRIVAL',
        'raw_data': 'JT-39|23:50 - 00:40|�143|905000.0000|0|0|L|JT|39|2018-07-01T23:50:00|2018-07-02T00:40:00|1|D�143|905000.0000|0|0|L|JT|39|2018-07-01T23:50:00|2018-07-02T00:40:00|1|D�|JT|39|2018-07-01T23:50:00|2018-07-02T00:40:00|1|D',
        'flight_type': ''}
    */

    function parse_flight_data(l){
        console.log("#6-modelling_flight_data started : ", Qt.formatDate(new Date(), "yyyy-MM-dd"), Qt.formatTime(new Date(),"hh:mm:ss"))
//        console.log("flight_data : ", l)
        if (l=="ERROR"){
            loading_view.close()
            notif_view.isSuccess = false
            notif_view.escapeFunction = 'backToMain'
            notif_view.show_text = qsTr("We're Apologize")
            notif_view.show_detail = qsTr("Machine is trying to reconnect to System.")
            notif_view.open()
        } else {
            depart_model.clear()
            return_model.clear()
            var originFrom_temp = originFrom.substring(originFrom.length-3)
            var destinationTo_temp = destinationTo.substring(destinationTo.length-3)
            if (l.length < 1) return
            var f = JSON.parse(l)
            for (var i = 0; i < f.length; i++){
                var fromTo_temp = (f[i].flight_status=="DEPARTURE") ? originFrom_temp + ' - ' + destinationTo_temp : destinationTo_temp + ' - ' + originFrom_temp
                var color_temp = (f[i].flight_no.substring(0,2)=="ID") ?  "purple" : "red"

                if(f[i].flight_status=="DEPARTURE"){
                    depart_model.append({"price1_" : f[i].promo_price.toString(),
                                            "price2_" : f[i].eco_price.toString(),
                                            "price3_" : f[i].bus_price.toString(),
                                            "f_no_": f[i].flight_no,
                                            "f_time_": f[i].flight_time,
                                            "qty1_": parseInt(f[i].promo_qty),
                                            "qty2_": parseInt(f[i].eco_qty),
                                            "qty3_" : parseInt(f[i].bus_qty),
                                            "fromTo_" : fromTo_temp,
                                            "color_": color_temp,
                                            "raw1_": f[i].raw_data_promo,
                                            "raw2_": f[i].raw_data_eco,
                                            "raw3_": f[i].raw_data_bus,
//                                            "raw0_": f[i].raw_data_parent,
                                            "f_status_": f[i].flight_status,
                                            "f_type_": f[i].flight_type,
                                            "f_origin_": f[i].origin,
                                            "f_route_trip_": f[i].route_trip,
                                            "f_is_transit_": f[i].is_transit,
                                            "f_is_same_origin_": f[i].is_same_origin,
                                            "f_trans_flight_time_": f[i].trans_flight_time,
                                            "f_trans_flight_no_" : f[i].trans_flight_no,
                                            "f_trans_flight_point_": f[i].trans_flight_point
                                        })
                    totalDeparture = depart_model.count;
                } else {
                    return_model.append({"price1_" : f[i].promo_price.toString(),
                                            "price2_" : f[i].eco_price.toString(),
                                            "price3_" : f[i].bus_price.toString(),
                                            "f_no_": f[i].flight_no,
                                            "f_time_": f[i].flight_time,
                                            "qty1_": parseInt(f[i].promo_qty),
                                            "qty2_": parseInt(f[i].eco_qty),
                                            "qty3_" : parseInt(f[i].bus_qty),
                                            "fromTo_" : fromTo_temp,
                                            "color_": color_temp,
                                            "raw1_": f[i].raw_data_promo,
                                            "raw2_": f[i].raw_data_eco,
                                            "raw3_": f[i].raw_data_bus,
//                                            "raw0_": f[i].raw_data_parent,
                                            "f_status_": f[i].flight_status,
                                            "f_type_": f[i].flight_type,
                                            "f_origin_": f[i].origin,
                                            "f_route_trip_": f[i].route_trip,
                                            "f_is_transit_": f[i].is_transit,
                                            "f_is_same_origin_": f[i].is_same_origin,
                                            "f_trans_flight_time_": f[i].trans_flight_time,
                                            "f_trans_flight_no_" : f[i].trans_flight_no,
                                            "f_trans_flight_point_": f[i].trans_flight_point
                                        })
                    totalReturn = return_model.count;
                }
            }
            if (totalDeparture>0){
                listViewTicket.model = depart_model
                loading_view.close()
            } else {
                loading_view.close()
                notif_view.isSuccess = false
                notif_view.show_text = qsTr("Dear Customer")
                notif_view.show_detail = qsTr("Your plan is not available, Please set another schedule plan.")
                notif_view.escapeFunction = 'backToPrevious'
                notif_view.open()
            }

            console.log("#7-modelling_flight_data finished : ", Qt.formatDate(new Date(), "yyyy-MM-dd"), Qt.formatTime(new Date(),"hh:mm:ss"))
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
        visible: (getReturnActivated==false) ? true : false
        MouseArea{
            anchors.fill: parent
            onClicked: {
                my_layer.push(select_plan)
//                my_layer.pop()
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
                my_timer.stop()
                my_layer.push(select_plan)
//                my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
            }
        }
    }

    Text{
        id: total_flight_depart
        text: "Total : " + totalDeparture
        anchors.top: parent.top
        anchors.topMargin: 120
        anchors.left: parent.left
        anchors.leftMargin: 325
        visible: (getReturnActivated==false && totalDeparture!=undefined) ? true : false
        color: "darkred"
        font.bold: true
        font.family: "GothamRounded"
        font.pixelSize: 20
    }

    Text{
        id: total_flight_return
        text: "Total : " + totalReturn
        anchors.top: parent.top
        anchors.topMargin: 120
        anchors.left: parent.left
        anchors.leftMargin: 325
        visible: (getReturnActivated==true && totalReturn!=undefined) ? true : false
        color: "darkred"
        font.bold: true
        font.family: "GothamRounded"
        font.pixelSize: 20
    }

    GroupBox{
        id: gbox_1
        x: 927
        width: 982
        height: 70
        anchors.top: parent.top
        anchors.topMargin: 100
        anchors.right: parent.right
        anchors.rightMargin: 0
        flat: true
//        visible: false
        visible: (selectedPrice.length>0) ? true : false;
        Text{
            id: text_info_f_no
            x: 840
            y: 10
            width: 120
            height: 40
            color: "darkred"
//            text: "ID-7843"
            font.bold: true
            font.pixelSize: 20
            font.family: "GothamRounded"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
        }
        Text{
            id: text_info_f_time
            x: 19
            y: 10
            color: "darkred"
//            text: "2018-01-07 12:00-14:00"
            font.italic: true
            font.bold: false
            anchors.horizontalCenterOffset: 1
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 25
            font.family: "GothamRounded"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        Text{
            id: text_info_fromTo
            x: 79
            y: 5
            width: 192
            height: 47
//            text: "CGK - DPS"
            color: "darkred"
            font.bold: false
            font.pixelSize: 30
            font.family: "GothamRounded"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
        }
        Image{
            id: img_f_status
            x: 7
            y: 3
            width: 66
            height: 50
//            source: "source/two_way.png"
            fillMode: Image.PreserveAspectFit
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignRight
        }
        Image{
            id: img_info
            y: -6
            fillMode: Image.PreserveAspectFit
//            source: 'source/batik_air_logo.jpg'
            height: 79
            anchors.left: parent.left
            anchors.leftMargin: 700
            width: 140
        }
    }

    GroupBox{
        id: gbox_2
        width: 510
        height: 70
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 100
        flat: true
        visible: !gbox_1.visible
        Row{
            id: filter_button
            anchors.fill: parent
            spacing: 10

            function reset(except, typeSort){
//                loading_view.open();
                rec_earliest.color = 'green';
                rec_latest.color = 'green';
                rec_lowest.color = 'green';
                rec_highest.color = 'green';
                except.color = 'darkred'
                switch (typeSort){
                case 'earliest':
                    _SLOT.start_sort_flight_data('time', 'a-z');
                    break;
                case 'latest':
                    _SLOT.start_sort_flight_data('time', 'z-a');
                    break;
                case 'lowest':
                    _SLOT.start_sort_flight_data('price', 'a-z');
                    break;
                case 'highest':
                    _SLOT.start_sort_flight_data('price', 'z-a')
                    break;
                default:
                    break;
                }
            }

            Rectangle{
                id: rec_earliest
                height: parent.height
                width: (parent.width-30)/4
//                color: (time_sort % 2 == 0) ? 'darkred' : 'green'
                color: 'green'
                Text{
                    anchors.fill: parent
                    text: qsTr('Earliest Time')
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: 'white'
                    font.pixelSize: 15
                    font.family: 'Microsoft YaHei'
                    font.bold: true
                    wrapMode: Text.WordWrap
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        if (press_sort!="0") return
                        press_sort = "1"
                        filter_button.reset(rec_earliest, 'earliest')
                    }
                }
            }
            Rectangle{
                id: rec_latest
                height: parent.height
                width: (parent.width-30)/4
//                color: (time_sort % 2 == 0) ? 'darkred' : 'green'
                color: 'green'
                Text{
                    anchors.fill: parent
                    text: qsTr('Latest Time')
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: 'white'
                    font.pixelSize: 15
                    font.family: 'Microsoft YaHei'
                    font.bold: true
                    wrapMode: Text.WordWrap
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        if (press_sort!="0") return
                        press_sort = "1"
                        filter_button.reset(rec_latest, 'latest')
                    }
                }
            }
            Rectangle{
                id: rec_lowest
                height: parent.height
                width: (parent.width-30)/4
//                color: (time_sort % 2 == 0) ? 'darkred' : 'green'
                color: 'green'
                Text{
                    anchors.fill: parent
                    text: qsTr('Lowest Price')
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: 'white'
                    font.pixelSize: 15
                    font.family: 'Microsoft YaHei'
                    font.bold: true
                    wrapMode: Text.WordWrap
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        if (press_sort!="0") return
                        press_sort = "1"
                        filter_button.reset(rec_lowest, 'lowest')
                    }
                }
            }
            Rectangle{
                id: rec_highest
                height: parent.height
                width: (parent.width-30)/4
//                color: (time_sort % 2 == 0) ? 'darkred' : 'green'
                color: 'green'
                Text{
                    anchors.fill: parent
                    text: qsTr('Highest Price')
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: 'white'
                    font.pixelSize: 15
                    font.family: 'Microsoft YaHei'
                    font.bold: true
                    wrapMode: Text.WordWrap
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        if (press_sort!="0") return
                        press_sort = "1"
                        filter_button.reset(rec_highest, 'highest')
                    }
                }
            }
        }
    }

    Item  {
        id: flickable_items
        x: 298
        y:170
        width:982
        height:846

        ScrollBarVertical{
            id: vertical_sbar
            flickable: listViewTicket
            height: flickable_items.height
            color: "gray"
            expandedWidth: 15
        }

        ListView{
            id: listViewTicket
            x: 0
            anchors.rightMargin: 30
            anchors.leftMargin: 20
            anchors.bottomMargin: 10
            anchors.topMargin: 10
            anchors.fill: parent
            contentWidth: 0
            spacing: 10
            flickDeceleration: 750
            maximumFlickVelocity: 1500
            layoutDirection: Qt.LeftToRight
            boundsBehavior: Flickable.StopAtBounds
            cacheBuffer: 500
            keyNavigationWraps: true
            snapMode: GridView.SnapToRow
            clip: true
            focus: true
            delegate: component_ticket
        }

        ListModel {
            id: depart_model
        }

        ListModel {
            id: return_model
        }

        Component{
            id: component_ticket
//            TicketButton{
//                id: item_ticket;
//                price1 : price1_;
//                price2 : price2_;
//                price3 : price3_;
//                f_no: f_no_;
//                f_time: f_time_;
//                qty1 : qty1_;
//                qty2 : qty2_;
//                qty3 : qty3_;
//                fromTo : fromTo_;
//                color__: color_;
//                raw1: raw1_;
//                raw2: raw2_;
//                raw3: raw3_;
////                raw0: raw0_;
//                f_status: f_status_;
//                f_type: f_type_;
//            }
            TicketButtonNew{
                id: item_ticket;
                price1 : price1_;
                price2 : price2_;
                price3 : price3_;
                f_no: f_no_;
                f_time: f_time_;
                qty1 : qty1_;
                qty2 : qty2_;
                qty3 : qty3_;
                fromTo : f_route_trip_;
                color__: color_;
                raw1: raw1_;
                raw2: raw2_;
                raw3: raw3_;
//                raw0: raw0_;
                f_status: f_status_;
                f_type: f_type_;
                is_transit: f_is_transit_;
                is_same_origin: f_is_same_origin_;
                trans_flight_time: f_trans_flight_time_;
                trans_flight_no: f_trans_flight_no_;
                trans_flight_point: f_trans_flight_point_;
//                __color__: FUNC.get_ticket_color(f_is_transit_, f_is_same_origin_)
                __height__: FUNC.get_ticket_height(f_is_transit_);
                new_origin: f_origin_;
                priceMargin: defaultMargin;
            }
        }
    }

    ConfirmView{
        id: confirm_view;
        show_text: qsTr("Dear Customer");
        MouseArea{
            id: ok_confirm_view
            x: 668; y:691
            width: 190; height: 50;
            onClicked: {
                //TODO Check whether multiple hit or not
//                if(returnDate==undefined){
//                    var param = {"stype": typeTemp, "sval": valueTemp};
//                    _SLOT.start_create_chart(JSON.stringify(param));
//                }
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

