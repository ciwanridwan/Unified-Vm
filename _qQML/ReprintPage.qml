import QtQuick 2.4
import QtQuick.Controls 1.3
import "base_function.js" as FUNC

Base{
    id: reprint_page
    mode_: "reverse"
    isPanelActive: true
    textPanel: qsTr("Enter Your Booking Code")
    imgPanel: "source/form_filling.png"
    property int timer_value: 60
    property var textInput: ""
    property int max_count: 6
    property var baseFare: ""
    property var press: "0"

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            abc.counter = timer_value
            my_timer.start()
            press = "0"
            max_count = 6
            textInput = ""
        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
            loading_view.close()
        }
    }

    Component.onCompleted:{
        base.result_booking_search.connect(define_booking);
    }

    Component.onDestruction:{
        base.result_booking_search.disconnect(define_booking);
    }

    function define_booking(result){
        console.log('define_booking', result);
        loading_view.close();
        press = '0';
        if (result=='ERROR'||result=='NO_DATA'){
            virtual_keyboard.count = 0;
            textInput = "";
            notif_view.z = 100;
            notif_view.isSuccess = false;
            notif_view.show_text = qsTr("We're Apologize");
            notif_view.show_detail = qsTr("The booking code cannot be found.");
            notif_view.open();
            return
        } else {
            my_layer.push(reprint_detail_view, {detail_info:result})

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
    TextRectangle{
        id: textRectangle
        x:447; y:252
        width: 630
        height: 100
        radius: 0
    }

    Image{
        id: image_receipt
        x: 1093
        y: 252
        width: 100
        height: 100
        source: "source/cekkodebooking_black.png"
        fillMode: Image.PreserveAspectFit

    }

    TextInput {
        id: inputText
        anchors.centerIn: textRectangle;
        text: textInput
        cursorVisible: true
        horizontalAlignment: Text.AlignLeft
        font.family: "GothamRounded"
        font.pixelSize: 50
        color: "darkred"
        clip: true
        visible: true
        focus: true
    }


    Column{
        id: text_cols
        x: 340
        y: 500
        width: 900
        height: 100
        spacing: 20
        Text{
            id: notif_text1
            width: parent.width
            height: 30
            font.family: "GothamRounded"
            font.pixelSize: 30
            color: "darkred"
            text: qsTr('Note :')
            verticalAlignment: Text.AlignVCenter
            font.bold: true
            wrapMode: Text.WordWrap

        }
        Text{
            id: notif_text2
            y: 0
            width: parent.width
            height: 20
            font.family: "GothamRounded"
            font.pixelSize: 25
            color: "darkred"
            text: qsTr("Available only for booking code which generated from this machine.")
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap

        }
    }


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
                console.log('OK_button_is_pressed', textInput)
                if (press != '0') return
                if (textInput.length==6){
                    press = '1';
                    loading_view.show_text = qsTr('Checking Your Booking Code');
                    loading_view.open();
                    _SLOT.start_search_booking(textInput);
                } else {
                    press = '0';
                    count = 0;
                    textInput = "";
                    notif_view.z = 100;
                    notif_view.isSuccess = false;
                    notif_view.show_text = qsTr("We're Apologize");
                    notif_view.show_detail = qsTr("Please Recheck Your Booking Code.");
                    notif_view.open();
                    return
                }
            }
            if(str=="Back"){
                if (count <= 0) {
                    count = 0;
                    reprint_page.textInput  = ""
                    return
                }
                press = "0";
                count--;
                reprint_page.textInput = reprint_page.textInput.substring(0, reprint_page.textInput.length-1);
            }
        }

        function typeIn(str){
//            console.log("input :", str)
            if (count >= max_count) {
                count = max_count
                return
            }
            count++
            reprint_page.textInput += str
            abc.counter = timer_value
            my_timer.restart()
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

