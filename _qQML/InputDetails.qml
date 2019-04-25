import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import QtQuick.Controls.Private 1.0
import "base_function.js" as FUNC

Base{
    id: input_details_page
    mode_: "reverse"
    isPanelActive: true
    textPanel: qsTr("Please Fill In Data")
    imgPanel: "aAsset/form_filling.png"
    property int timer_value: 300
    property int max_count: 100
    property var orderList//: ["adt", "cnn", "inf"]
    property var selectedPrice //: [1]
    property var originFrom
    property var destinationTo
    property var currentIndex: 0
    property var currentType: "adt"
    property var show_f_name: ""
    property var show_l_name: ""
    property var show_t_phone: ""
    property var show_h_phone: ""
    property var show_bday: ""
    property var show_email: ""
    property var show_title: ""
    property int step
    property var departDate
    property var returnDate
    property var flightNo: "ID-6785"
    property var fromTo: ""
    property var flightTime: ""
    property var selectedChart
    property bool keyboardVisual: true
    property var inputStatus: "("+ (parseInt(currentIndex)+1) + "/" + orderList.length +")"
    property bool sendInfo: true
    property bool sendBooking: true
    property var customerInfo: []
    property var language_: base.language
    property var customerNameList: []

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            console.log("selected_chart : ", selectedChart)
            console.log("selected_price : ", selectedPrice)
       //            currentType = FUNC.get_index_value(orderList, currentIndex);
//            console.log(currentType, currentIndex)
            abc.counter = timer_value;
            my_timer.start();
            init_data();
            step = 0;
            customerInfo = [];
            customerNameList = [];
        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
            loading_view.close()
        }
    }

    Component.onCompleted:{
        base.result_post_person.connect(define_process);
        base.result_create_booking.connect(process_booking);
        base.result_general.connect(handle_general)
    }

    Component.onDestruction:{
        base.result_post_person.disconnect(define_process);
        base.result_create_booking.disconnect(process_booking);
        base.result_general.disconnect(handle_general)
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

    function define_process(result){
        console.log(result);
        loading_view.close();
        if (result==undefined||result=="ERROR"||result==""){
            notif_view.isSuccess = false;
            notif_view.show_detail = qsTr("Something Went Wrong.");
            notif_view.open();
        }
        if(result=="SUCCESS"){
            if(orderList.length-1==currentIndex||orderList.length==1){
//                confirm_view.open()
                loading_view.open()
                if (sendBooking==true){
                    _SLOT.start_create_booking();
                    sendBooking = false;
                }
            } else {
                next_passenger(currentIndex);
            }
        }
    }

    function process_booking(code){
//        console.log(code)
        /*OK => 0
        ^BOOKING_CODE:VLOQVF => 1
        ^TOTAL:708000.00 => 2
        ^PAYMENT_STATUS:WAIT => 3
        ^TID:110001 => 4
        ^FTYPE:OneWay => 5
        ^OB:4|708000.0000|0|0|Q|JT|34|2018-03-18T04:30:00|2018-03-18T07:20:00|1|I^IB:*/
        if(code==undefined||code==""||code=="ERROR"){
            loading_view.close()
            notif_view.isSuccess = false;
            notif_view.show_detail = qsTr("Something Went Wrong in Booking Process.");
            notif_view.escapeFunction = 'backToMain'
            notif_view.open();
        }
//        if(code=="SUCCESS"){
        if(code.indexOf('OK?BOOKING_CODE:?')==-1){
            /*{
                    "booking_code": data[1].split(':')[1],
                    "total_payment": data[2].split(':')[1],
                    "payment_status": data[3].split(':')[1],
                    "flight_type": data[5].split(':')[1],
                    "depart_raw": data[6],
                    "return_raw": data[7]
                }*/
            var param = JSON.parse(code);
            var product = {
                "details" : "Flight Ticket " + param.flight_type + " " + fromTo +
                " " + departDate + " - " + flightTime +
                " , Booking Code : " + param.booking_code,
                "raw" : param.depart_raw + '|' + param.return_raw,
                "status" : param.payment_status,
                "master_raw" : code
            };
            var d = JSON.parse(selectedPrice[0])
            var priceDepart = d.price
            var amount = param.total_payment;
            var flightDetailsDepart = { "departDate": departDate,
                "flightNo": d.f_no, "fromTo": d.fromTo, "flightTime": d.f_time,
                "originFrom": d.f_new_origin, "withTransit": d.f_is_transit,
                "destinationTo": d.fromTo.substring(d.fromTo.length-3),
                "transitDetails": "(Transit) " + d.f_trans_flight_point + " - " + d.f_trans_flight_no + " - " + d.f_trans_flight_time,
                "bookingCode": param.booking_code, "price": priceDepart, "terminal_depart": param.terminal_depart}
            var flightDetailsReturn = undefined;
            //TODO Finalise This Parsing
            if (returnDate!=undefined){
                var r = JSON.parse(selectedPrice[1])
                var flightNoreturn = r.f_no;
                var fromToReturn = r.fromTo;
                var flightTimeReturn = r.f_time;
                var priceReturn = r.price
                flightDetailsReturn = { "returnDate": returnDate,
                    "flightNo": flightNoreturn, "fromTo": fromToReturn, "flightTime": flightTimeReturn,
                    "originFrom": r.f_new_origin,  "withTransit": r.f_is_transit,
                    "destinationTo": r.fromTo.substring(r.fromTo.length-3),
                    "transitDetails": "(Transit) " + r.f_trans_flight_point + " - " + r.f_trans_flight_no + " - " + r.f_trans_flight_time,
                    "bookingCode": param.booking_code, "price" : priceReturn, "terminal_return": param.terminal_return}
            }
            my_layer.push(select_payment, {amount: amount, product: JSON.stringify(product),
                              useMode: "TICKET_FLIGHT",
                              flightDetailsDepart: JSON.stringify(flightDetailsDepart),
                              flightDetailsReturn: (returnDate!=undefined) ?
                                                       JSON.stringify(flightDetailsReturn) : flightDetailsReturn,
                              selectedChart: selectedChart, customerInfo: customerInfo,
                              selectedPrice: selectedPrice})
        } else {
            loading_view.close()
            notif_view.isSuccess = false;
            notif_view.show_detail = qsTr("Something Went Wrong in Parsing Booking Result.");
            notif_view.escapeFunction = 'backToMain'
            notif_view.open();
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

    CancelButton{
        id:cancel_button1
        x: 100 ;y: 40;
        exitText: (language=='INA') ? qsTr("Ganti Jadwal") : qsTr("Change Plan");
        imgSource: "aAsset/change-schedule-white.png"
        MouseArea{
            anchors.fill: parent
            onClicked: {
//                confirm_view.escapeFunction = 'closeWindow'
//                confirm_view.show_text = qsTr("Dear Customer")
//                confirm_view.show_detail = qsTr("Are you sure to cancel this transaction ?")
//                confirm_view.open()
                my_layer.pop(my_layer.find(function(item){if(item.Stack.index===0)return true}));
            }
        }
    }

    Row{
        x: 1100
        y: 40
        spacing: 5
        z: 100
        Text{
            text: qsTr("Time Left : ")
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


    //==============================================================
    //PUT MAIN COMPONENT HERE

    function init_data(){
        var p = JSON.parse(selectedPrice[0])
        if(selectedPrice.length==1){
            text_info_f_no_depart.text = flightNo = p.f_no
            text_info_f_time.text = departDate + " " + p.f_time
            flightTime = p.f_time
            text_info_fromTo.text = fromTo = p.fromTo
            img_info.source = p.f_logo
        } else {
            var q = JSON.parse(selectedPrice[1])
            text_info_f_no_depart.text = p.f_no
            text_info_f_time.text = "Dep: " + departDate + " " + p.f_time + "\n Ret: " +
                    returnDate + " " + q.f_time
            text_info_fromTo.text = p.fromTo + "\n Round Trip"
            console.log("adding_flight_image...", p.f_logo, q.f_logo)
            if (q.f_logo !== undefined) {
                text_info_f_no_return.text = q.f_no
                img_info.source = p.f_logo
                img_info.anchors.leftMargin = 700
                img_info_2.source = q.f_logo
                img_info_2.visible = true
            } else {
                img_info.source = p.f_logo
            }
        }

    }

    GroupBox{
        x: 927
        width: 982
        height: 70
        anchors.top: parent.top
        anchors.topMargin: 100
        anchors.right: parent.right
        anchors.rightMargin: 0
        flat: true
        Text{
            id: text_info_f_time
            x: 19
            y: 10
            color: "darkred"
//            text: "Dep : 2018-08-09 12:00-14:00 \n Ret: 2018-09-09 13:00-15:00"
            font.bold: false
            font.italic: true
            anchors.horizontalCenterOffset: 1
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: (selectedPrice.length==1) ? 25 : 15
            font.family: "Ubuntu"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        Text{
            id: text_info_fromTo
            x: 79
            y: 5
            width: 192
            height: 47
//            text: "CGK - DPS \n Two Ways"
            color: "darkred"
            font.bold: false
            font.pixelSize: (selectedPrice.length==1) ? 30 : 20
            font.family: "Ubuntu"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        Image{
            id: img_f_status
            x: 7
            y: 3
            width: 66
            height: 50
            source: (returnDate==undefined) ? "aAsset/one_way.png" : "aAsset/two_way.png"
//            source: "aAsset/two_way.png"
            fillMode: Image.PreserveAspectFit
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignRight
        }
        Image{
            id: img_info
            y: -12
            fillMode: Image.PreserveAspectFit
//            source: 'aAsset/lion_air_logo.jpg'
            height: 79
            sourceSize.width: 0
            anchors.left: parent.left
            anchors.leftMargin: 800
            width: 100
            Text{
                id: text_info_f_no_depart
                x: 0
                y: 0
                width: parent.width
                height: 40
                color: "darkred"
//                text: "JT 973"
                anchors.verticalCenterOffset: 15
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                font.family: "Ubuntu"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
            }
        }
        Image{
            id: img_info_2
            visible: false
            y: -12
            fillMode: Image.PreserveAspectFit
//            source: 'aAsset/batik_air_logo.jpg'
            height: 79
            anchors.left: parent.left
            anchors.leftMargin: 820
            width: 100
            Text{
                id: text_info_f_no_return
                visible: parent.visible
                x: 0
                y: 0
                width: parent.width
                height: 40
                color: "darkred"
//                text: "ID 878"
                anchors.verticalCenterOffset: 15
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                font.family: "Ubuntu"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
            }
        }
    }

    GroupBox{
        x: 1027
        y: 210
        width: 205
        height: 60
        flat: true
        Image{
            id: img_type
            y:-6
            width: 60; height: 60
            anchors.left: parent.left
            anchors.leftMargin: 10
            fillMode: Image.PreserveAspectFit
            //            source: "aAsset/adult.png"
            source: FUNC.get_source_image(currentType)

        }
        Text{
            id: text_type
            x: 19
            y: 3
            color: "#626466"
            text: FUNC.translate_index_text(currentType, language_) + " " + (parseInt(currentIndex)+1).toString()
            anchors.right: parent.right
            anchors.rightMargin: 0
            font.bold: false
            font.pixelSize: 25
            font.family: "Ubuntu"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Column{
        id: formInputColumn
        x: 320
        y: 210
        width: 950
        spacing: 50
        GroupBox{
            id: groupTitle
            x: 0; y: 0;
            width: 430; height: 50
            flat: true
            z: 1
            Text{
                id: titleName
                x: -8
                text: qsTr("Title")
                anchors.top: parent.top
                anchors.topMargin: -45
                font.family: "Ubuntu"
                font.pixelSize: 20
                color: "darkred"
                font.bold: false
            }
            ComboBox {
                id: comboTitle
                x: -7
                y: -7
                width: 350
                height: 50
                model: ["", "Mr", "Mrs"]
                currentIndex: 0
                style: ComboBoxStyle {
    //                background: Rectangle{}
                    label: Text {
                        color: "black"
                        width: comboTitle.width
                        height: comboTitle.height
                        text: control.currentText
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Ubuntu"
                    }
                    __dropDownStyle: MenuStyle {
    //                    frame: Rectangle{}
                        itemDelegate.label: Text {
                            width:comboTitle.width - 50
                            height: comboTitle.height
                            color: styleData.selected ? "darkred" : "black"
                            text: styleData.text
                            font.pixelSize: 20
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Ubuntu"
                        }
                        itemDelegate.background: Rectangle {
                            z: 2
                            opacity: 0.5
                            color: styleData.selected ? "darkGray" : "transparent"
                        }
                    }
                }
                onCurrentIndexChanged: {
                    show_title = currentText;
//                    console.log(show_title);
                }
            }
        }
        Row{
            spacing: 50
            FormTextInput{
                id: input_f_name
                show_label: qsTr("First Name *")
                width: 430; height: 50;
                set_focus: (input_details_page.step==0) ? true : false;
                MouseArea{
                    anchors.fill: parent;
                    onClicked: {
                        input_details_page.step=0;
                        virtual_keyboard.count=0;
                        virtual_keyboard.alphaOnly=true;
                        virtual_keyboard.numberOnly=false;
                    }
                }
            }
            FormTextInput{
                id: input_l_name
                show_label: qsTr("Last Name *")
                width: 430; height: 50;
                set_focus: (input_details_page.step==1) ? true : false;
                MouseArea{
                    anchors.fill: parent;
                    onClicked: {
                        input_details_page.step=1;
                        virtual_keyboard.count=0;
                        virtual_keyboard.alphaOnly=true;
                        virtual_keyboard.numberOnly=false;
                    }
                }
            }
        }
        Row{
            spacing: 50
            FormTextInput{
                id: input_t_phone
                show_label: qsTr("ID Card No *")
                width: 430; height: 50;
                visible: (currentType=="adt") ? true : false;
                set_focus: (input_details_page.step==2) ? true : false;
                MouseArea{
                    anchors.fill: parent;
                    onClicked: {
                        input_details_page.step=2;
                        virtual_keyboard.count=0;
                        virtual_keyboard.alphaOnly=false;
                        virtual_keyboard.numberOnly=false;
                    }
                }
            }
            FormTextInput{
                id: input_h_phone
                show_label: qsTr("Mobile Phone *")
                width: 430; height: 50;
                visible: (currentType=="adt") ? true : false;
                set_focus: (input_details_page.step==3) ? true : false;
                MouseArea{
                    anchors.fill: parent;
                    onClicked: {
                        input_details_page.step=3;
                        virtual_keyboard.count=0;
                        virtual_keyboard.alphaOnly=false;
                        virtual_keyboard.numberOnly=true;
                    }
                }
            }
        }
        FormTextInput{
            id: input_email
            show_label: qsTr("Email Address *")
            width: 430; height: 50;
            visible: (currentType=="adt") ? true : false;
            set_focus: (input_details_page.step==4) ? true : false;
            MouseArea{
                anchors.fill: parent;
                onClicked: {
                    input_details_page.step=4;
                    virtual_keyboard.count=0;
                    virtual_keyboard.alphaOnly=false;
                    virtual_keyboard.numberOnly=false;
                }
            }
        }
        GroupBox{
            id: groupBirtday
            width: 450; height: 450;
            z: 3
            flat: true
            visible: (currentType!="adt") ? true : false;
            Text{
                id: titleBirthday
                text: qsTr("BirthDay Date *")
                font.family: "Ubuntu"
                font.pixelSize: 20
                color: "darkred"
                font.bold: false
            }
            Button {
                id: buttonDepart
                x: 380
                y: 40
                width: 40
                height: 40
                Image {
                    id: imgCalendar
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                        source: "aAsset/calender.png"
                }
                onClicked:{
                    calBirthday.visible=true;
                    keyboardVisual=false;
                }
            }
            TextField {
                id: textBirthday
                x: 0
                y: 43
                width: 379
                height: 33
                placeholderText: qsTr("Select Date")
                text:Qt.formatDate(calBirthday.selectedDate, "dd MMM yyyy")
                font.italic: true
                font.bold: false
                font.family:"Ubuntu"
                font.pixelSize: 15
            }
            Calendar{
                id:calBirthday
                x: 0; y: 82;
                width: 420
                height: 300
                visible: false
                selectedDate: new Date()
                onClicked:  {
                    textBirthday.text=Qt.formatDate(calBirthday.selectedDate, "dd MMM yyyy");
                    show_bday=Qt.formatDate(calBirthday.selectedDate, "yyyy-MM-dd");
                    calBirthday.visible=false;
                    keyboardVisual=true;
                }
            }
        }
    }

    Button{
        id: next_button
        x: 957
        y: 549
        width: 275
        height: 70
        Text{
            id: next_button_label
            text: (orderList.length!=1) ? qsTr("Next") + inputStatus : qsTr("Book")
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
            var passed = check_validation(currentType);
            if(passed==true){
                var param = {
                    "stype": currentType.toUpperCase(),
                    "order": (currentIndex+1).toString(),
                    "title": show_title,
//                    "fname": FUNC.replace_non_char(show_f_name).toUpperCase(),
//                    "lname": FUNC.replace_non_char(show_l_name).toUpperCase(),
                    "fname": show_f_name.toUpperCase(),
                    "lname": show_l_name.toUpperCase(),
                    "thome": FUNC.replace_non_number(show_t_phone),
                    "tmobile": FUNC.replace_non_number(show_h_phone),
                    "email": show_email.toLowerCase(),
                    "bdate": show_bday
                }
                if (sendInfo==true){
                    _SLOT.start_post_person(JSON.stringify(param));
                    customerNameList.push(param.fname + '-' + param.lname);
                    if (currentType=='adt'){
                        var adult = (language_=='INA') ? 'Dewasa' : 'Adult';
                        customerInfo.push(param.order + '. ' +
                                          adult + ' - ' +
                                          param.fname + ' ' + param.lname + ' - ' +
                                          param.tmobile + ' - ' + param.email)
                    } else {
                        var kid = (language_=='INA') ? 'Anak Kecil' : 'Child';
                        if (currentType=='inf') kid = (language_=='INA') ? 'Anak Bayi' : 'Infant';
                        customerInfo.push(param.order + '. ' +
                                          kid + ' - ' +
                                          param.fname + ' ' + param.lname + ' - ' +
                                          param.bdate)
                    }
                    sendInfo = false;
                }
                loading_view.show_text = qsTr("Booking Your Seat...");
                loading_view.open();
            }
        }
    }

    function next_passenger(i){
        i += 1;
        currentIndex = i;
        currentType = FUNC.get_index_value(orderList, currentIndex);
        img_type.source = FUNC.get_source_image(currentType);
        text_type.text = FUNC.translate_index_text(currentType, language_) + " " + (parseInt(currentIndex)+1).toString();
        reset_input();
        if(currentIndex==orderList.length-1) next_button_label.text = qsTr("Book");
    }

    function reset_input(){
        input_f_name.show_text = show_f_name = "";
        input_l_name.show_text = show_l_name = "";
        input_t_phone.show_text = show_t_phone = "";
        input_h_phone.show_text = show_h_phone = "";
        textBirthday.text = show_bday = "";
        input_email.show_text = show_email = "";
        show_title = "";
        comboTitle.currentIndex = 0;
        step = 0;
        virtual_keyboard.count = 0;
        sendInfo = true;
    }

    function check_validation(type){
        if(show_title==""){
            notif_view.isSuccess = false
            notif_view.show_detail = qsTr("Please Choose Title First.")
            notif_view.open()
            return false
        }
        if (FUNC.replace_non_char(show_f_name).length < 3){
            notif_view.isSuccess = false
            notif_view.show_detail = qsTr("Please Correct the First Name.")
            notif_view.open()
            return false
        }
        if (FUNC.replace_non_char(show_l_name).length < 3){
            notif_view.isSuccess = false
            notif_view.show_detail = qsTr("Please Correct the Last Name.")
            notif_view.open()
            return false
        }
        if (customerNameList.indexOf(show_f_name.toLocaleUpperCase()+'-'+show_l_name.toLocaleUpperCase()) > -1){
            notif_view.isSuccess = false
            notif_view.show_detail = qsTr("Please Ensure You don't input duplicate name.")
            notif_view.open()
            return false
        }
        if(type=="adt"){
//            if (show_t_phone==''){
//                show_t_phone='0000000';
//            } else if (show_t_phone!='' && FUNC.replace_non_number(show_t_phone).length < 15) {
//                notif_view.isSuccess = false
//                notif_view.show_detail = qsTr("Please Correct the ID Card Number.")
//                notif_view.open()
//                return false
//            }
            if (show_t_phone=='' || FUNC.replace_non_number(show_t_phone).length < 5) {
                notif_view.isSuccess = false
                notif_view.show_detail = qsTr("Please Correct the ID Card Number.")
                notif_view.open()
                return false
            }
            if (FUNC.validate_email(show_email)!==true){
                notif_view.isSuccess = false
                notif_view.show_detail = qsTr("Please Correct the Email Address.")
                notif_view.open()
                return false
            }
            if (show_h_phone==''){
                show_h_phone='0800000000';
            } else if (show_h_phone != '' && FUNC.replace_non_number(show_h_phone).length < 8){
                notif_view.isSuccess = false
                notif_view.show_detail = qsTr("Please Correct the Mobile Phone Number.")
                notif_view.open()
                return false
            }
        } else if(type=="cnn" || type=="inf"){
            if (show_bday==""){
                notif_view.isSuccess = false
                notif_view.show_detail = qsTr("Please Correct the Birthday Date.")
                notif_view.open()
                return false
            }
        }
        return true
    }

    FullKeyboard{
        id:virtual_keyboard
        x:332; y:645; z:1
        width: 930; height: 371;
        visible: keyboardVisual
        isShifted: false
        isHighlighted: false
        alphaOnly: true
        numberOnly: false
        property int count:0

        Component.onCompleted: {
            virtual_keyboard.strButtonClick.connect(typeIn)
            virtual_keyboard.funcButtonClicked.connect(functionIn)
        }

        function functionIn(str){
            if(str == "OK"){
//                if(press != "0"){
//                    return
//                }
//                press = "1"
                step++
                if(step>4){
                    var passed = check_validation(currentType)
                    if(passed==true){
                        var param = {
                            "stype": currentType.toUpperCase(),
                            "order": (currentIndex+1).toString(),
                            "title": show_title,
//                            "fname": FUNC.replace_non_char(show_f_name).toUpperCase(),
//                            "lname": FUNC.replace_non_char(show_l_name).toUpperCase(),
                            "fname": show_f_name.toUpperCase(),
                            "lname": show_l_name.toUpperCase(),
                            "thome": FUNC.replace_non_number(show_t_phone),
                            "tmobile": FUNC.replace_non_number(show_h_phone),
                            "email": show_email.toLowerCase(),
                            "bdate": show_bday
                        }
                        if (sendInfo==true){
                            _SLOT.start_post_person(JSON.stringify(param));
                            if (currentType=='adt'){
                                var adult = (language_=='INA') ? 'Dewasa' : 'Adult';
                                customerInfo.push(param.order + '. ' +
                                                  adult + ' - ' +
                                                  param.fname + ' ' + param.lname + ' - ' +
                                                  param.tmobile + ' - ' + param.email)
                            } else {
                                var kid = (language_=='INA') ? 'Anak Kecil' : 'Child';
                                if (currentType=='inf') kid = (language_=='INA') ? 'Anak Bayi' : 'Infant';
                                customerInfo.push(param.order + '. ' +
                                                  kid + ' - ' +
                                                  param.fname + ' ' + param.lname + ' - ' +
                                                  param.bdate)
                            }
                            sendInfo = false;
                        }
                        loading_view.show_text = qsTr("Booking Your Seat...")
                        loading_view.open()
                    }
                }
            }
            if(str=="Back"){
                count--
                if(step==0){
                    input_f_name.show_text = input_f_name.show_text.substring(0, input_f_name.show_text.length-1)
                    show_f_name = input_f_name.show_text
                } else if(step==1){
                    input_l_name.show_text = input_l_name.show_text.substring(0, input_l_name.show_text.length-1)
                    show_l_name= input_l_name.show_text
                }else if(step==2){
                    input_t_phone.show_text = input_t_phone.show_text.substring(0, input_t_phone.show_text.length-1)
                    show_t_phone=input_t_phone.show_text
                }else if(step==3){
                    input_h_phone.show_text = input_h_phone.show_text.substring(0, input_h_phone.show_text.length-1)
                    show_h_phone = input_h_phone.show_text
                }else if(step==4){
                    input_email.show_text = input_email.show_text.substring(0, input_email.show_text.length-1)
                    show_email=input_email.show_text
                }
            }
        }

        function typeIn(str){
//            console.log("input :", str)
//            count++
//            if (count<max_count){
//                base_page.textInput += str
//            }
            if (str == "" && count > 0){
                if(count>=max_count){
                    count=max_count
                }
                count--
                if(step==0){
                    input_f_name.show_text = input_f_name.show_text.substring(0,count);
                    show_f_name = input_f_name.show_text
                } else if(step==1){
                    input_l_name.show_text = input_l_name.show_text.substring(0,count);
                    show_l_name= input_l_name.show_text
                }else if(step==2){
                    input_t_phone.show_text = input_t_phone.show_text.substring(0,count);
                    show_t_phone=input_t_phone.show_text
                }else if(step==3){
                    input_h_phone.show_text = input_h_phone.show_text.substring(0,count);
                    show_h_phone = input_h_phone.show_text
                }else if(step==4){
                    input_email.show_text = input_email.show_text.substring(0,count);
                    show_email=input_email.show_text
                }
            }
            if (str!=""&&count<max_count){
                count++
            }
            if (count>=max_count){
                str=""
            }
            else{
                if(step==0){
                    input_f_name.show_text += str
                    show_f_name = input_f_name.show_text
                } else if(step==1){
                    input_l_name.show_text += str
                    show_l_name= input_l_name.show_text
                }else if(step==2){
                    input_t_phone.show_text += str
                    show_t_phone=input_t_phone.show_text
                }else if(step==3){
                    input_h_phone.show_text += str
                    show_h_phone = input_h_phone.show_text
                }else if(step==4){
                    input_email.show_text += str
                    show_email=input_email.show_text
                }
            }
            abc.counter = timer_value
            my_timer.restart()
        }
    }

    //==============================================================

//    Image {
//        id: button_keyboard
//        x: 1086
//        y: 944
//        height: 60; width: 88
//        source: "aAsset/keyboard-icon-black.jpg"
//        fillMode: Image.PreserveAspectFit
//        visible: !keyboardVisual
//        MouseArea{
//            anchors.fill: parent;
//            onClicked: keyboardVisual=true;
//        }
//    }

    ConfirmView{
        id: confirm_view
        show_text: qsTr("Dear Customer")
        show_detail: qsTr("Do you want to proceed this flight arrangement? (Back button function will not work.)")
        z: 99
//        escapeFunction: 'backToMain'
        MouseArea{
            id: ok_confirm_view
            x: 668; y:691
            width: 190; height: 50;
            onClicked: {
                my_layer.pop(my_layer.find(function(item){if(item.Stack.index===0)return true}));
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
        show_text: qsTr("Finding Flight...")
    }

}
