import QtQuick 2.4
import QtQuick.Controls 1.3
import "base_function.js" as FUNC

Base{
    id: reprint_page
    mode_: "reverse"
    isPanelActive: true
    textPanel: (language=="INA") ?  qsTr("Input Data Flight Anda") : qsTr("Enter Your Flight Details")
    imgPanel: "source/form_filling.png"
    property int timer_value: 120
    property var textCodeInput: ""
    property var textNameInput: ""
    property var textCardInput: ""
    property var passCategory: undefined
    property var baseFare: ""
    property var press: "0"
    property int stepInput: 0
    property real defaultOpacity: 0.5


    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            abc.counter = timer_value
            my_timer.start()
            open_preload_notif()
            rec_parent.reset_opacity(passCategory)
            press = "0"
            textCodeInput = ""
            textNameInput = ""
            textCardInput = ""
            passCategory = undefined
            stepInput = 0

        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
            loading_view.close()
        }
    }

    Component.onCompleted:{
        base.result_general.connect(handle_general);
        base.result_check_booking_code.connect(define_booking);
    }

    Component.onDestruction:{
        base.result_general.disconnect(handle_general);
        base.result_check_booking_code.disconnect(define_booking);
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

    function define_booking(result){
        console.log('define_booking', result);
        loading_view.close();
        press = '0';
        if (result=='ERROR'||result==undefined){
            virtual_keyboard.count = 0;
            textCodeInput = "";
            textNameInput = "";
            textCardInput = "";
            rec_parent.reset_opacity('');
            stepInput = 0;
            notif_view.z = 100;
            notif_view.isSuccess = false;
            notif_view.show_text = (language=='INA') ? 'Mohon Maaf' : 'We Are Apologize';
            notif_view.show_detail = (language=='INA') ? 'Kode Penerbangan Anda Tidak Ditemukan, Mohon Melapor Ke Petugas Check-In' : 'Your Flight Data Cannot Be Found, Please Report to Check-in Officer.';
            notif_view.open();
            return;
        }

        var r = JSON.parse(result);
        my_layer.push(select_seat, {flightData: r.flight, seatData: r.seats});

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

    //==============================================================
    //PUT MAIN COMPONENT HERE
    property int globalFontSize: 40
    property int globalLabelSize: 20
    property int textRecWidth: 600
    property int textRecHeigth: 80

    Rectangle{
        id: rec_parent
        color: 'transparent'
        anchors.fill: parent
        enabled: (standard_notif_view.visible==false) ? true : false

        Label{
            id: code_label
            width: 135
            height: textRecHeigth
            text: (language=='INA') ? 'Kode Pesan*' : 'Booking Code*'
            textFormat: Text.PlainText
            font.pixelSize: globalLabelSize
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            color: 'darkred'
            font.family: "Ubuntu"
            anchors.right: textCodeRectangle.left
            anchors.rightMargin: 50
            anchors.verticalCenter: textCodeRectangle.verticalCenter

        }


        TextRectangle{
            id: textCodeRectangle
            usedBy: inputCodeText
            x:550; y:150
            width: textRecWidth
            height: textRecHeigth
            radius: 0
            placeHolder: (textCodeInput.length==0) ? "eg. MNTEBA" : ""
            MouseArea{
                anchors.fill: parent;
                onClicked: {
                    stepInput = 0;
                    textCodeInput = "";
                }
            }
        }


        TextInput {
            id: inputCodeText
            anchors.centerIn: textCodeRectangle;
            text: textCodeInput
            cursorVisible: (stepInput==0) ? true : false
            horizontalAlignment: Text.AlignLeft
            font.family: "Ubuntu"
            font.pixelSize: globalFontSize
            color: "darkred"
            clip: true
            visible: true
            focus: (stepInput==0 && standard_notif_view.visible==false) ? true : false
        }


        Label{
            id: name_label
            width: 135
            height: textRecHeigth
            text: (language=='INA') ? 'Nama Depan*' : 'First Name*'
            textFormat: Text.PlainText
            font.pixelSize: globalLabelSize
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            color: 'darkred'
            font.family: "Ubuntu"
            anchors.right: textNameRectangle.left
            anchors.rightMargin: 50
            anchors.verticalCenter: textNameRectangle.verticalCenter

        }

        TextRectangle{
            id: textNameRectangle
            usedBy: inputNameText
            x:550; y:textCodeRectangle.y + 125
            width: textRecWidth
            height: textRecHeigth
            radius: 0
            placeHolder: (textNameInput.length==0) ? "eg. WAHYUDI" : ""
            MouseArea{
                anchors.fill: parent;
                onClicked: {
                    stepInput = 1;
                }
            }
        }

        TextInput {
            id: inputNameText
            anchors.centerIn: textNameRectangle;
            text: textNameInput
            cursorVisible: (stepInput==1) ? true : false
            horizontalAlignment: Text.AlignLeft
            font.family: "Ubuntu"
            font.pixelSize: globalFontSize
            color: "darkred"
            clip: true
            visible: true
            focus: (stepInput==1 && standard_notif_view.visible==false) ? true : false
        }

        Label{
            id: card_label
            width: 135
            height: 60
            text: (language=='INA') ? 'No Kartu Pelanggan' : 'Royalty Card No.'
            textFormat: Text.PlainText
            font.pixelSize: globalLabelSize
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            color: 'darkred'
            font.family: "Ubuntu"
            anchors.right: textCardRectangle.left
            anchors.rightMargin: 50
            anchors.verticalCenter: textCardRectangle.verticalCenter

        }

        TextRectangle{
            id: textCardRectangle
            usedBy: inputCardText
            x:550; y:textNameRectangle.y + 125
            width: 500
            height: 60
            radius: 0
            placeHolder: (textCardInput.length==0) ? "eg. 0123456789" : ""
            MouseArea{
                anchors.fill: parent;
                onClicked: {
                    stepInput = 2;
                }
            }
        }

        TextInput {
            id: inputCardText
            anchors.centerIn: textNameRectangle;
            text: textCardInput
            cursorVisible: (stepInput==2) ? true : false
            horizontalAlignment: Text.AlignLeft
            font.family: "Ubuntu"
            font.pixelSize: globalFontSize - 10
            color: "darkred"
            clip: true
            visible: true
            focus: (stepInput==2 && standard_notif_view.visible==false) ? true : false
        }

        Label{
            id: category_label
            width: 135
            height: 60
            text: (language=='INA') ? 'Kategori Penumpang*' : 'Passenger Category*'
            textFormat: Text.PlainText
            font.pixelSize: globalLabelSize
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            color: 'darkred'
            font.family: "Ubuntu"
            anchors.right: row_category.left
            anchors.rightMargin: 50
            anchors.verticalCenter: row_category.verticalCenter
        }


        function reset_opacity(c){
            console.log('Selected Category : ', c);
            adult_male.opacity = defaultOpacity;
            adult_female.opacity = defaultOpacity;
            child_category.opacity = defaultOpacity;
        }

        Row{
            id: row_category
            spacing: 100
            x:550; y:textCardRectangle.y + 125
            width: 500
            height: 80

            Button{
                id: adult_male
                width: parent.height
                height: parent.height
                opacity: defaultOpacity
                onClicked: {
                    passCategory = 'M';
                    rec_parent.reset_opacity(passCategory);
                    adult_male.opacity = 1;
                }
                Image{
                    scale: 0.8
                    anchors.fill: parent
                    source: 'source/adult-male.png'
                    fillMode: Image.PreserveAspectFit
                }
                Text{
                    width: 60
                    height: 60
                    text: (language=='INA') ? "Dewasa (Pria)" : 'Adult (Male)'
                    wrapMode: Text.WordWrap
                    font.family:"Ubuntu"
                    font.bold: true
                    font.pixelSize: 15
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    anchors.right: parent.right
                    anchors.rightMargin: -65
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Button{
                id: adult_female
                width: parent.height
                height: parent.height
                opacity: defaultOpacity
                onClicked: {
                    passCategory = 'F';
                    rec_parent.reset_opacity(passCategory);
                    adult_female.opacity = 1;
                }
                Image{
                    scale: 0.8
                    anchors.fill: parent
                    source: 'source/adult-female.png'
                    fillMode: Image.PreserveAspectFit
                }
                Text{
                    width: 60
                    height: 60
                    text: (language=='INA') ? "Dewasa (Wanita)" : 'Adult (Female)'
                    wrapMode: Text.WordWrap
                    font.family:"Ubuntu"
                    font.bold: true
                    font.pixelSize: 15
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    anchors.right: parent.right
                    anchors.rightMargin: -65
                    anchors.verticalCenter: parent.verticalCenter
                }
            }


            Button{
                id: child_category
                width: parent.height
                height: parent.height
                opacity: defaultOpacity
                onClicked: {
                    passCategory = 'C';
                    rec_parent.reset_opacity(passCategory);
                    child_category.opacity = 1;
                }
                Image{
                    scale: 0.8
                    anchors.fill: parent
                    source: 'source/child-icon.png'
                    fillMode: Image.PreserveAspectFit
                }
                Text{
                    width: 60
                    height: 60
                    text: (language=='INA') ? "Anak Kecil" : 'Child'
                    wrapMode: Text.WordWrap
                    font.family:"Ubuntu"
                    font.bold: true
                    font.pixelSize: 15
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    anchors.right: parent.right
                    anchors.rightMargin: -65
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

    }




//    Column{
//        id: text_cols
//        visible: false
//        x: 350
//        y: 550
//        width: 900
//        height: 100
//        spacing: 25

//        Text{
//            id: notif_text1
//            width: parent.width
//            height: 30
//            font.family: "Ubuntu"
//            font.pixelSize: 25
//            color: "darkred"
//            text: (language=="INA") ? "Penting :" : "Important :"
//            verticalAlignment: Text.AlignVCenter
//            font.bold: true
//            font.underline: true
//            wrapMode: Text.WordWrap

//        }
//        Text{
//            id: notif_text2
//            y: 0
//            width: parent.width
//            height: 20
//            font.family: "Ubuntu"
//            font.pixelSize: 20
//            color: "darkred"
//            text: (language=="INA") ? text_cols.noteIna : text_cols.noteEng
//            verticalAlignment: Text.AlignVCenter
//            wrapMode: Text.WordWrap

//        }
//    }


    FullKeyboard{
        id:virtual_keyboard
        x:332; y:645; z:1
        width: 930; height: 371;
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
                if (press != '0') return
                press = '1'
                if (textCodeInput=="" || textCodeInput.length!=6){
                    press = '0';
                    notif_view.z = 100;
                    notif_view.isSuccess = false;
                    notif_view.show_text = (language=="INA") ? "Mohon Maaf" : "We're Apologize";;
                    notif_view.show_detail = (language=="INA") ? "Periksa Kode Booking Anda" : "Check Your Booking Code";
                    notif_view.open();
                    return
                } else if (textNameInput=="" || textNameInput.length<3){
                    press = '0';
                    notif_view.z = 100;
                    notif_view.isSuccess = false;
                    notif_view.show_text = (language=="INA") ? "Mohon Maaf" : "We're Apologize";;
                    notif_view.show_detail = (language=="INA") ? "Periksa Kembali Input Nama Anda" : "Check Your Input of First/Last Name";
                    notif_view.open();
                    return
                } else if (passCategory==undefined){
                    press = '0';
                    notif_view.z = 100;
                    notif_view.isSuccess = false;
                    notif_view.show_text = (language=="INA") ? "Mohon Maaf" : "We're Apologize";;
                    notif_view.show_detail = (language=="INA") ? "Tentukan Kategori Penumpang" : "Please Define Passenger Category";
                    notif_view.open();
                    return
                } else {
                    count = 0;
                    console.log('Finding FLight Details for : ', textCodeInput, textNameInput, textCardInput, passCategory);
                    loading_view.show_text = (language=='INA') ? qsTr("Mencari Data Penerbangan Anda...") : qsTr("Finding Your Flight Data...");
                    loading_view.open();
                    var param = {
                        'booking_code': textCodeInput,
                        'lf_name': textNameInput,
                        'card_royalty': textCardInput,
                        'gender': passCategory
                    }

                    _SLOT.start_check_booking_code(JSON.stringify(param))
                }
            }
            if(str=="Back"){
                if (count <= 0) {
                    count = 0;
                    if (stepInput==0) textCodeInput = "";
                    if (stepInput==1) textNameInput = "";
                    if (stepInput==2) textCardInput = "";
                    return
                }
                press = "0";
                count--;
                if (stepInput==0) textCodeInput = textCodeInput.substring(0, textCodeInput.length-1);
                if (stepInput==1) textNameInput = textNameInput.substring(0, textNameInput.length-1);
                if (stepInput==2) textCardInput = textCardInput.substring(0, textCardInput.length-1);
            }
        }

        function typeIn(str){
//            console.log("input :", str)
            var max_count = 6;
            if (stepInput==0) max_count = 6;
            if (stepInput!=0) max_count = 25;
            if (count >= max_count) {
                count = max_count
                return
            }
            count++
            if (stepInput==0) textCodeInput += str;
            if (stepInput==1) textNameInput += str;
            if (stepInput==2) textCardInput += str;
            abc.counter = timer_value;
            my_timer.restart();
        }
    }


    property var noteEng : "- Currenly Only Available For JT Flight (Lion Air),\n- Minimum 2 Hours or maximum 24 Hours before Departure,\n- 1 Booking Code For 1 Passenger.";
    property var noteIna : "- Saat Ini Hanya Tersedia untuk Penerbangan JT (Lion Air),\n- Minimum 2 Jam atau maksimum 24 Jam Sebelum Keberangkatan,\n- 1 Kode Pesan Untuk 1 Penumpang.";



    function open_preload_notif(){
        press = '0';
        standard_notif_view.z = 100;
        standard_notif_view.show_text = (language=="INA") ? "Penumpang YTH" : "Dear Customer";;
        standard_notif_view.show_detail = (language=="INA") ? noteIna : noteEng;
        standard_notif_view.open();
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
        show_text: "Dear Customer"
        show_detail: "Please Ensure You have set Your plan correctly."
        z: 99
    }

    StandardNotifView{
        id: standard_notif_view
        show_text: "Dear Customer"
        show_detail: "Please Ensure You have set Your plan correctly."
        z: 99
    }

    LoadingView{
        id:loading_view
        z: 99
        show_text: "Finding Flight..."
    }




}

