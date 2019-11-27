import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import QtQuick.Controls.Private 1.0
//import QtQml.Models 2.1
import "airport.js" as AIRPORTS
import "base_function.js" as FUNC

Base{
    id: base_select_plan
    mode_ : "reverse"
    isPanelActive: true
    textPanel: qsTr("Set Flight Plan")
    property var language_: base.language
    property int timer_value: 150
    property var originFrom: undefined
    property var destinationTo: undefined
    property bool isWithReturn: false
    property string departDate: Qt.formatDate(new Date(), "yyyy-MM-dd");
    property var returnDate: undefined
    property int numberADT: 1
    property int numberCNN: 0
    property int numberINF: 0
    property var orderList: []
    property bool isModelLoaded: false
    property bool keyboardVisual: false
    property int step
    property int max_count: 50
    property var textInput: ""
    property bool isNotifActive: false
    property bool sendSchedule: true
    property bool globalFocusOrigin: false
    property bool globalFocusDestination: false
    property var optionMode: 'suggestBox' // 'suggestBox'||'comboBox'
//    property var nativeDateDepart: 'undefined_date'
    property var nativeDateDepart: Qt.formatDate(new Date(), "yyyy-MM-dd")
    signal fromSuggest(string str)
    property int maxInfant: 3
    property var press: "0"

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            //clean up base raw data
            base.raw_destination = undefined
            base.raw_origin = undefined
            base.raw_transit = undefined
            abc.counter = timer_value;
            my_timer.start();
            orderList = [];
            textNumberADT.text = numberADT = 1;
            textNumberCNN.text = numberCNN = 0;
            textNumberINF.text = numberINF = 0;
            keyboardVisual = false;
            returnDate = undefined;
            isWithReturn = false;
            isNotifActive = false;
            sendSchedule = true;
            press = "0"
            if(isModelLoaded==false){
                get_airport_list(AIRPORTS.get_list('upper'), optionMode);
            }
        }
        if(Stack.status==Stack.Deactivating){
            loading_view.close()
            my_timer.stop()
        }
    }

    Component.onCompleted:{
        fromSuggest.connect(signal_receiver)
        base.result_create_schedule.connect(get_schedule)
        base.result_set_plan.connect(get_plan)
        base.result_general.connect(handle_general)
    }

    Component.onDestruction:{
        fromSuggest.disconnect(signal_receiver)
        base.result_create_schedule.disconnect(get_schedule)
        base.result_set_plan.disconnect(get_plan)
        base.result_general.disconnect(handle_general)
    }

    function signal_receiver(s){
        console.log('[info] signal received : ', s);
        var moduleBox = s.split('||')[0]
        var commandBox = s.split('||')[1]
        if (moduleBox=='origin'){
            if (commandBox=='clear') originFrom = ''
            if (commandBox=='focus') {globalFocusOrigin = true; globalFocusDestination = false;}
            if (commandBox=='activate') {step = 0; keyboardVisual = true;
            globalFocusOrigin = true; globalFocusDestination = false;}
        } else if (moduleBox=='destination') {
            if (commandBox=='clear') destinationTo = ''
            if (commandBox=='focus') {globalFocusDestination = true; globalFocusOrigin = false;}
            if (commandBox=='activate') {step = 1; keyboardVisual = true;
            globalFocusDestination = true; globalFocusOrigin = false;}
        }
    }

    function handle_general(result){
        console.log("handle_general : ", result)
        if (result=='') return
        if (result=='REBOOT'){
            sendSchedule = false;
            loading_view.close()
            notif_view.z = 99
            notif_view.isSuccess = false
            notif_view.closeButton = false
            notif_view.show_text = qsTr("Dear User")
            notif_view.show_detail = qsTr("This Kiosk Machine will be rebooted in 30 seconds.")
            notif_view.open()
            get_status_modal()
        }
    }

    function get_status_modal(){
        if (loading_view.visible==true||notif_view.visible==true) {
            isNotifActive = true;
        } else {
            isNotifActive = false;
        }
    }

    function get_airport_list(l, o){
//        console.log(l, o)
        if (l.length == 0) return
        if (o=='comboBox'){
            for (var a in l){
                __model.append({text: l[a]});
            }
        } else if (o=='suggestBox') {
            for (var b = 1; b < l.length; b++) {
                __model.append({'name': l[b]});
            }
        }
        isModelLoaded = true;

    }

    function set_order(a, b, c){
        orderList = [];
        for (var i = 0; i < a; i++) {
            orderList.push("adt");
        }
        for (var j = 0; j < b; j++) {
            orderList.push("cnn");
        }
        for (var k = 0; k < c; k++) {
            orderList.push("inf");
        }
        console.log("orderList :", orderList)
    }

    function compare_date(date1, date2){
        console.log("compare_date : ", date1, date2)
        if (isWithReturn==false) return true
        var intDate1 = parseInt(Qt.formatDate(date1,"yyyyMMdd"))
        var intDate2 = parseInt(Qt.formatDate(date2,"yyyyMMdd"))
        if (intDate2>=intDate1){
            return true
        } else {
            return false
        }

    }

    function get_plan(text){
//        console.log("get_plan : " + text)
        if(text==="SUCCESS"){
            _SLOT.start_create_schedule();
        }else{
            loading_view.close();
            notif_view.isSuccess = false;
            notif_view.show_text = qsTr("Dear Customer");
            notif_view.show_detail = qsTr("Your plan is not available, Please set another schedule plan.");
            notif_view.open();
            press = '0';
            sendSchedule = true;
//            get_status_modal()
        }
    }

    function get_schedule(text){
//        console.log("get_schedule : " + text)
        if(text!="ERROR" || text!="TIMEOUT" || text.length > 10){
            my_layer.push(select_ticket, {
                              list_flight: text,
                              departDate: departDate,
                              returnDate: returnDate,
                              originFrom: originFrom,
                              destinationTo: destinationTo,
                              orderList: orderList
                          })
        }else{
            loading_view.close();
            notif_view.isSuccess = false;
            notif_view.show_text = qsTr("Dear Customer");
            notif_view.show_detail = qsTr("Your plan is not available, Please set another schedule plan.");
            notif_view.open();
            press = '0';
//            get_status_modal()
            sendSchedule = true;
        }
    }

    function adjust_number(mode, number, type){
//        console.log("adjust_number :", mode, number, type)
        if(mode==="minus"){
            if(type==="adt"){
                if(number===1){
                    return number;
                } else {
                    return number -= 1;
                }
            }else{
                if(number===0){
                    return number;
                }else{
                    return number -= 1;
                }
            }
        } else if(mode==='plus'){
            if (number===maxInfant && type==="inf") return number;
            return number += 1
        }
    }

    function continue_process(){
        set_order(numberADT, numberCNN, numberINF)
        var adult = numberADT.toString()
        var origin = originFrom.substring(originFrom.length-3)
        var destination = destinationTo.substring(destinationTo.length-3)
        var depart = departDate
        var return_ = (isWithReturn==true) ? returnDate : ""
        var child = numberCNN.toString()
        var infant = numberINF.toString()
        var param = { "adult": adult, "origin": origin, "destination": destination,
            "depart": depart, "return_": return_, "child": child, "infant": infant
        }
        console.log("#0-find_flight_button_click : ", Qt.formatDate(new Date(), "yyyy-MM-dd"), Qt.formatTime(new Date(),"hh:mm:ss"))
        if (sendSchedule==true){
            _SLOT.start_set_plan(JSON.stringify(param));
            sendSchedule = false;
        }
//        console.log(adult, origin, destination, depart, return_, child, infant)
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
                my_layer.push(home_page)
//                check_range_time(nativeDateDepart);
            }
        }
    }

    ListModel {id: __model}

    Row{
        x: 579
        y: 119
        spacing:0
        Rectangle{
            id: oneWay
            color: (isWithReturn==false) ? "darkred" : "white"
            x: 0; y:0;
            width: 200
            height: 50
            radius: 1
            border.color: 'darkred'
            border.width: 2
            Text{
                anchors.fill: oneWay
                text: qsTr("ONE TRIP")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                font.bold: true
                font.family: "Ubuntu"
                color: (isWithReturn==false)  ? "white" : "darkred"
//                color: 'white'
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    press = "0";
                    isWithReturn = false;
                }
            }
        }
        Rectangle{
            id: twoWay
            color: (isWithReturn==false) ? "white" : "darkred"
            x: 0; y:0;
            width: 200
            height: 50
            radius: 1
            border.color: 'darkred'
            border.width: 2
            Text{
                anchors.fill: twoWay
                text: qsTr("ROUND TRIP")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                font.bold: true
                font.family: "Ubuntu"
                color: (isWithReturn==false) ? "darkred" : "white"
//                color: 'white'
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    press = "0";
                    isWithReturn = true;
                }
            }
        }
    }

    GroupBox{
        id: groupComboOrigin
        x: 321
        y: 224
        width: 430
        flat: true
        z: 5
        enabled: !isNotifActive

        Text{
            id: titleOrigin
            text: qsTr("From")
            anchors.top: parent.top
            anchors.topMargin: -45
            font.family: "Ubuntu"
            font.pixelSize: 20
            color: "darkred"
            font.bold: false
        }

        Image{
            id: imgComboOrigin
            y: 0
            width: 75
            height: 50
            scale: 0.8
            anchors.left: parent.left
            anchors.leftMargin: 0
            fillMode: Image.PreserveAspectFit
            source: "source/departure.png"
        }

        ComboBox {
            id: comboOrigin
            y: 0
            width: 350
            height: 50
            anchors.left: imgComboOrigin.right
            anchors.leftMargin: 0
            visible: (optionMode=='comboBox') ? true : false

//            editable: true
            model: __model
//            currentIndex: 0
            style: ComboBoxStyle {
//                background: Rectangle{visible: false}
                label: Text {
                    color: "black"
                    width: comboOrigin.width
                    height: comboOrigin.height
                    text: control.currentText
                    font.pixelSize: 20
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Ubuntu"
                }
                __popupStyle: __dropDownStyle
                __dropDownStyle: MenuStyle {
//                    frame: Rectangle{visible: false}
                    itemDelegate.label: Text {
                        width:comboOrigin.width - 50
                        height: comboOrigin.height
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
                    __scrollerStyle: ScrollViewStyle{
                    }
                }

                property Component __scrollerStyle: Style {
                    padding { left: 0; right: 0; top: 0; bottom: 0 }
                    property bool scrollToClickedPosition: false
                    property Component frame: Item { visible: false }
                    property Component corner: Item { visible: false }
                    property Component __scrollbar: Item { visible: false }
                }
            }

//            onPressedChanged: { step = 0; keyboardVisual = true; comboDestination.focus = false}

//            onFocusChanged: {
//                if(step==1){
//                    step = 0; keyboardVisual = true; comboDestination.focus = false;
//                }
//            }

            onCurrentIndexChanged: {
                originFrom = currentText;
                base.raw_origin = originFrom;
                keyboardVisual = false;
                console.log("originFrom :", originFrom)
//                if (find(currentText) === -1) {
//                    modelOrigin.append({text: editText})
//                    currentIndex = find(editText)
//                }
            }
//            onEditTextChanged: onCurrentIndexChanged
        }

        Item {
            id: suggestBoxOrigin
            y: 0
            width: 350
            anchors.left: imgComboOrigin.right
            anchors.leftMargin: 0
            visible: (optionMode=='suggestBox') ? true : false

            LineEditSuggest {
                id: inputFieldOrigin
                focus: globalFocusOrigin
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 50
                hint.text: (language_=='INA') ? "Kota Keberangkatan..." : "Enter Origin..."
                borderColor: "white"

                function activateSuggestionAt(offset) {
                    var max = suggestionsBoxOrigin.count
                    if(max == 0)
                        return
                    var newIndex = ((suggestionsBoxOrigin.currentIndex + 1 + offset) % (max + 1)) - 1
                    suggestionsBoxOrigin.currentIndex = newIndex
                }
                onUpPressed: activateSuggestionAt(-1)
                onDownPressed: activateSuggestionAt(+1)
                onEnterPressed: processEnter()
                onAccepted: processEnter()

                Component.onCompleted: {
//                    inputFieldOrigin.forceActiveFocus()
                }

                function processEnter() {
                    if (suggestionsBoxOrigin.currentIndex === -1) {
                        console.log("Enter pressed in input field")
                    } else {
                        suggestionsBoxOrigin.complete(suggestionsBoxOrigin.currentItem)
                    }
                }
            }

            SuggestionBox {
                id: suggestionsBoxOrigin
                model: __model
                width: parent.width
                anchors.top: inputFieldOrigin.bottom
                anchors.left: inputFieldOrigin.left
                filter: inputFieldOrigin.textInput.text
                property: "name"
                onItemSelected: complete(item)

                function complete(item) {
                    suggestionsBoxOrigin.currentIndex = -1;
                    if (item !== undefined){
                        inputFieldOrigin.textInput.text = originFrom = base.raw_origin = item.name;
                        keyboardVisual = false;
                        console.log(inputFieldOrigin.useMode,' => ', originFrom, ' == ', base.raw_origin);
                        press = "0";
                    }
                }
            }

        }

    }

    GroupBox{
        id: groupComboDestination
        x: 821
        y: 224
        width: 430
        flat: true
        z: 5
        enabled: !isNotifActive

        Text{
            id: titleDestination
            text: qsTr("To")
            anchors.top: parent.top
            anchors.topMargin: -45
            font.family: "Ubuntu"
            font.pixelSize: 20
            color: "darkred"
            font.bold: false
        }

        Image{
            id: imgComboDestination
            y: 0
            width: 75
            height: 50
            scale: 0.8
            anchors.left: parent.left
            anchors.leftMargin: 0
            fillMode: Image.PreserveAspectFit
            source: "source/landing.png"
        }

        ComboBox {
            id: comboDestination
            y: 0
            width: 350
            height: 50
            anchors.left: imgComboDestination.right
            anchors.leftMargin: 0
            visible: (optionMode=='comboBox') ? true : false
//            editable: true
            model: __model
//            currentIndex: 0
            style: ComboBoxStyle {
//                background: Rectangle{visible: false}
                label: Text {
                    color: "black"
                    width: comboDestination.width
                    height: comboDestination.height
                    text: control.currentText
                    font.pixelSize: 20
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Ubuntu"
                }
                __popupStyle: __dropDownStyle
                __dropDownStyle: MenuStyle {
//                    frame: Rectangle{visible: false}
                    itemDelegate.label: Text {
                        width:comboDestination.width - 50
                        height: comboDestination.height
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
                    __scrollerStyle: ScrollViewStyle {
                    }

                }

                property Component __scrollerStyle: Style {
                    padding { left: 0; right: 0; top: 0; bottom: 0 }
                    property bool scrollToClickedPosition: false
                    property Component frame: Item { visible: false }
                    property Component corner: Item { visible: false }
                    property Component __scrollbar: Item { visible: false }
                }

            }

//            onPressedChanged: { step = 1; keyboardVisual = true; comboOrigin.focus = false }

//            onFocusChanged: {
//                if (step==0) {
//                    step = 1; keyboardVisual = true; comboOrigin.focus = false
//                }
//            }

            onCurrentIndexChanged: {
                destinationTo = currentText;
                base.raw_destination = destinationTo;
                keyboardVisual = false;
                console.log("arriveIn :", destinationTo)
//                if (find(currentText) === -1) {
//                    modelDestination.append({text: editText})
//                    currentIndex = find(editText)
//                }
            }
//            onEditTextChanged: onCurrentIndexChanged
        }

        Item {
            id: suggestBoxDestination
            width: 350
            height: 50
            anchors.left: imgComboDestination.right
            anchors.leftMargin: 0
            visible: (optionMode=='suggestBox') ? true : false

            LineEditSuggest {
                id: inputFieldDestination
                focus: globalFocusDestination
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 50
                hint.text: (language_=='INA') ? "Kota Tujuan..." : "Enter Destination..."
                borderColor: "white"
                useMode: 'destination'

                function activateSuggestionAt(offset) {
                    var max = suggestionsBoxDestination.count
                    if(max == 0)
                        return
                    var newIndex = ((suggestionsBoxDestination.currentIndex + 1 + offset) % (max + 1)) - 1
                    suggestionsBoxDestination.currentIndex = newIndex
                }
                onUpPressed: activateSuggestionAt(-1)
                onDownPressed: activateSuggestionAt(+1)
                onEnterPressed: processEnter()
                onAccepted: processEnter()

                Component.onCompleted: {
//                    inputFieldDestination.forceActiveFocus()
                }

                function processEnter() {
                    if (suggestionsBoxDestination.currentIndex === -1) {
                        console.log("Enter pressed in input field")
                    } else {
                        suggestionsBoxDestination.complete(suggestionsBoxDestination.currentItem)
                    }
                }
            }

            SuggestionBox {
                id: suggestionsBoxDestination
                model: __model
                width: parent.width
                anchors.top: inputFieldDestination.bottom
                anchors.left: inputFieldDestination.left
                filter: inputFieldDestination.textInput.text
                property: "name"
                onItemSelected: complete(item)

                function complete(item) {
                    suggestionsBoxDestination.currentIndex = -1;
                    if (item !== undefined){
                        inputFieldDestination.textInput.text = destinationTo = base.raw_destination = item.name;
                        keyboardVisual = false;
                        console.log(inputFieldDestination.useMode, ' => ' , destinationTo, ' == ', base.raw_destination);
                        press = "0";
                    }
                }
            }

        }

    }

    GroupBox{
        id: departCalendar
        x: 321
        y: 345
        width: 450
        height: 450
        flat: true
        z: 3
        enabled: !isNotifActive
        Text{
            id: titleDepart
            text: qsTr("Departure Date")
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
                id: imgDepart
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                    source: "source/calender.png"
            }
            onClicked:{
                calDepart.visible=true;
                press = "0";
            }
        }
        TextField {
            id: textDateDepart
            x: 0
            y: 43
            width: 379
            height: 33
            placeholderText: qsTr("Select Date")
            text:Qt.formatDate(calDepart.selectedDate, "dddd, dd MMM yyyy")
            font.italic: true
            font.bold: false
            font.family:"Ubuntu"
            font.pixelSize: 15
        }
        Calendar{
                   id:calDepart
                   x: 0
                   y: 82
                   width: 420
                   height: 300
                   visible: false
                   selectedDate: new Date()
                   onClicked:  {
                       nativeDateDepart = calDepart.selectedDate;
                       textDateDepart.text=Qt.formatDate(calDepart.selectedDate, "dddd, dd MMM yyyy");
                       departDate=Qt.formatDate(calDepart.selectedDate, "yyyy-MM-dd");
//                       console.log("departDate : ", departDate)
                       calDepart.visible=false;
                       press = "0";
                   }
        }
    }

    GroupBox{
        id: returnCalendar
        x: 821
        y: 345
        width: 450
        height: 450
        flat: true
        visible: isWithReturn
        z: 3
        enabled: !isNotifActive
        Text{
            id: titleReturn
            text: qsTr("Return Date")
            font.family: "Ubuntu"
            font.pixelSize: 20
            color: "darkred"
            font.bold: false
        }
        Button {
            id: buttonReturn
            x: 380
            y: 40
            width: 40
            height: 40
            Image {
                id: imgReturn
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                    source: "source/calender.png"
            }
            onClicked:{
                calReturn.visible=true;
                press = "0";
            }
        }
        TextField {
            id: textDateReturn
            x: 0
            y: 43
            width: 379
            height: 33
            placeholderText: qsTr("Select Date")
//            text:Qt.formatDate(calReturn.selectedDate, "dddd, dd MMM yyyy")
            font.italic: true
            font.bold: false
            font.family:"Ubuntu"
            font.pixelSize: 15
        }
        Calendar{
                   id:calReturn
                   x: 0
                   y: 82
                   width: 420
                   height: 300
                   visible: false
                   selectedDate: new Date()
                   onClicked:  {
                       textDateReturn.text=Qt.formatDate(calReturn.selectedDate, "dddd, dd MMM yyyy");
                       returnDate=Qt.formatDate(calReturn.selectedDate, "yyyy-MM-dd");
//                       console.log("returnDate : ", returnDate)
                       calReturn.visible=false;
                       press = "0";
                   }
        }
    }

    GroupBox{
        id: groupPassenger
        x: 321
        y: 519
        width: 915
        height: 50
        flat: true
        enabled: !isNotifActive
        Text{
            id: titlePassenger
            text: qsTr("Passenger")
            anchors.top: parent.top
            anchors.topMargin: -45
            font.family: "Ubuntu"
            font.pixelSize: 20
            color: "darkred"
            font.bold: false
        }
        Row{
            spacing: 35
            PassengerButton{
                mode_: 'adt'
                Text{
                    id: textNumberADT
                    x: 144
                    y: 8
                    width: 80
                    height: 66
                    text:numberADT
                    font.bold: false
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family:"Ubuntu"
                    font.pixelSize: 30
                }
                MouseArea{
                    x: 97
                    y: 20
                    width: 45
                    height: 45
                    onClicked: {
                        numberADT = adjust_number("minus", numberADT, "adt");
                        textNumberADT.text = numberADT;
                        press = "0";
                    }
                }

                MouseArea {
                    x: 223
                    y: 20
                    width: 45
                    height: 45
                    onClicked: {
                        numberADT = adjust_number("plus", numberADT, "adt");
                        textNumberADT.text = numberADT;
                        press = "0";
                    }

                }
            }
            PassengerButton{
                mode_: 'cnn'
                Text{
                    id: textNumberCNN
                    x: 144
                    y: 8
                    width: 80
                    height: 66
                    text:numberCNN
                    font.bold: false
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family:"Ubuntu"
                    font.pixelSize: 30
                }
                MouseArea{
                    x: 97
                    y: 20
                    width: 45
                    height: 45
                    onClicked: {
                        numberCNN = adjust_number("minus", numberCNN, "cnn");
                        textNumberCNN.text = numberCNN;
                        press = "0";
                    }
                }

                MouseArea {
                    x: 223
                    y: 20
                    width: 45
                    height: 45
                    onClicked: {
                        numberCNN = adjust_number("plus", numberCNN, "cnn")
                        textNumberCNN.text = numberCNN;
                        press = "0";
                    }
                }
            }
            PassengerButton{
                mode_: 'inf'
                Text{
                    id: textNumberINF
                    x: 144
                    y: 8
                    width: 80
                    height: 66
                    text:numberINF
                    font.bold: false
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family:"Ubuntu"
                    font.pixelSize: 30
                }
                MouseArea{
                    x: 97
                    y: 20
                    width: 45
                    height: 45
                    onClicked: {
                        numberINF = adjust_number("minus", numberINF, "inf");
                        textNumberINF.text = numberINF;
                        press = "0";
                    }
                }

                MouseArea {
                    x: 223
                    y: 20
                    width: 45
                    height: 45
                    onClicked: {
                        numberINF = adjust_number("plus", numberINF, "inf")
                        textNumberINF.text = numberINF;
                        press = "0";
                    }
                }
            }
        }

    }

    Button{
        id: main_button
        x: 657
        y: 725
        width: 275
        height: 70
        enabled: button_status()
        Image{
            x: -2
            y: 0
            width: 70
            height: 70
            scale: 0.5
            fillMode: Image.PreserveAspectFit
            source: "source/find.png"
        }
        Text{
            text: qsTr("Find My Flight")
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

        function button_status(){
            if(isNotifActive==true || keyboardVisual==true){
                return false
            }else {
                return true
            }
        }

        onClicked: {
            console.log("button is pressed");
            if (press != "0") return;
            press = "1";
            var checkDate = compare_date(departDate, returnDate);
            var checkRange = check_range_time(nativeDateDepart);
            var checkPassenger = check_passenger();
            var checkOriginDestination = check_origin_destination(originFrom, destinationTo);
            if(checkOriginDestination===true && checkDate===true && checkRange===true && checkPassenger===true){
                loading_view.open();
                continue_process();
            } else {
                if (checkOriginDestination===false){
                    notif_view.show_detail = qsTr("Please ensure your origin or destination is valid.");
                } else if (checkDate===false) {
                    notif_view.show_detail = qsTr("Please ensure the departure date is proper.");
                } else if (checkRange===false){
                    notif_view.show_detail = qsTr("Please ensure the departure date is below one year and or not less than one day.");
                } else if (checkPassenger===false){
                    notif_view.show_detail = qsTr("Please ensure the infant passenger not greater than adult passenger number.");
                } else {
                    notif_view.show_detail = qsTr("Please ensure the schedule flight is set properly.");
                }
                notif_view.open();
            }
//            get_status_modal();
//            press = "0";
        }

    }

    function check_origin_destination(o, d){
        if (o==undefined || o=='' || o.length < 3) return false;
        if (d==undefined || d=='' || d.length < 3) return false;
        if (o==d) return false;
        return true;
    }

    function check_range_time(date){
        if (date===Qt.formatDate(new Date(), "yyyy-MM-dd")){
            console.log("[info] date departure range day : ", 'same day')
            return true;
        }
        var one_day = 1000*60*60*24;
        var date1_ms = new Date().getTime();
//        console.log('date1 :', new Date())
//        console.log('date1 :', date1_ms)
        var date2_ms = date.getTime();
//        console.log('date2 :', date)
//        console.log('date2 :', date2_ms)
        var difference_ms = date2_ms - date1_ms;
        var range = Math.round(difference_ms/one_day);
        console.log("[info] date departure range day : ", range)
        if (range >= 365) return false;
        return true;
    }

    function check_passenger(){
        if (numberINF > numberADT) return false;
        return true;
    }

    function update_combo_text(id, string){
        if (string != 'del'){
            id.editText += string
            if (id.find(id.editText) !== -1){
                id.currentIndex = id.find(id.editText);
//                id.accepted();
                id.onCurrentIndexChanged()
            }
        }else{
            if (id.editText.length > 0) {
                id.editText = id.editText.substring(0, id.editText.length-1)
            }
        }
    }

    function update_suggest_box(id, string){
//        console.log('[debug] step, id, str', step, id, string )
        if (string != 'del'){
            id.textInput.text += string
        }else{
            if (id.textInput.text.length > 0) {
                id.textInput.text = id.textInput.text.substring(0, id.textInput.text.length-1)
            }
        }

    }

    QwertyKeyboard{
        id:virtual_keyboard
        x:332; y:645; z:1
        width: 930; height: 371;
        visible: keyboardVisual
        isHighlighted: false
        isShifted: true
        property int count:0

        Component.onCompleted: {
            virtual_keyboard.strButtonClick.connect(typeIn)
            virtual_keyboard.funcButtonClicked.connect(functionIn)
        }

        function functionIn(str){
            if(str == "OK"){
                var checkDate = compare_date(departDate, returnDate)
                if(originFrom!=destinationTo && checkDate===true){
                    loading_view.open();
                    continue_process();
                } else {
                    notif_view.open();
                }
//                get_status_modal();
//                if(press != "0"){
//                    return
//                }
//                press = "1"
                step++
//                textInput = ""
//                if(step>1) step=0
            }
            if(str=="Back"){
                count--
                textInput = textInput.substring(0, textInput.length-1);
                if(step==0){
                    if (optionMode=='comboBox') {
                        update_combo_text(comboOrigin, 'del')
                    } else if (optionMode=='suggestBox'){
                        update_suggest_box(inputFieldOrigin, 'del')
                    }
                } else if (step==1){
                    if (optionMode=='comboBox'){
                        update_combo_text(comboDestination, 'del')
                    } else if (optionMode=='suggestBox'){
                        update_suggest_box(inputFieldDestination, 'del')
                    }
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
                textInput = textInput.substring(0,count);
            }
            if (str!=""&&count<max_count){
                count++
            }
            if (count>=max_count){
                str=""
            }
            else{
                textInput += str
//                if (count==0) str = str.toUpperCase()
                if(step==0){
                    if (optionMode=='comboBox'){
                        update_combo_text(comboOrigin, str);
                    } else if (optionMode=='suggestBox'){
                        update_suggest_box(inputFieldOrigin, str);
                    }
                } else if(step==1){
                    if (optionMode=='comboBox'){
                        update_combo_text(comboDestination, str);
                    } else if (optionMode=='suggestBox') {
                        update_suggest_box(inputFieldDestination, str);
                    }
                }
            }
            abc.counter = timer_value
            my_timer.restart()
        }
    }

    Image{
        id: keyboard_close_button
        z: virtual_keyboard.z + 1
        source: "source/close.png"
        width: 50; height: 50
        visible: keyboardVisual
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 350
        anchors.right: parent.right
        anchors.rightMargin: 0
        fillMode: Image.Stretch
        MouseArea{
            anchors.fill: parent;
            onClicked: keyboardVisual = false;
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

}

