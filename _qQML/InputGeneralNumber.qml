import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import "base_function.js" as FUNC

Base{
    id: base_page
    mode_: "reverse"
    isPanelActive: true
    textPanel: "Scan/Input The Numbers"
    imgPanel: "source/input.png"
    colorPanel: "#4286f4"
    imgPanelScale: 0.8
    property int timer_value: 150
    property int max_count: 50
    property var press: "0"
    property var textInput: ""

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            abc.counter = timer_value
            my_timer.start()

        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
            loading_view.close()
        }
    }

    Component.onCompleted:{
        base.result_general.connect(handle_general)

    }

    Component.onDestruction:{
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
            notif_view.show_text = "Dear User"
            notif_view.show_detail = "This Kiosk Machine will be rebooted in 30 seconds."
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


//    IComboBox {
//        id: comboRoot
//        width: 200
//        height: 50
//        z: 2

//        property int m_userLevel: 1
//        comboBoxModel: ListModel {
//            id: cbItems
//            ListElement { text: "1" }
//            ListElement { text: "2" }
//            ListElement { text: "3" }
//            ListElement { text: "4" }
//        }


//        Component {
//            id: comboBoxStyleBackground
//    //        IUserLevelImage {
//    //            anchors.fill: parent
//    //            userLevel: m_userLevel
//    //        }
//            Rectangle{
//                anchors.fill: comboRoot;
//                color: "orange";
//            }
//        }


//        Component {
//            id: dropDownMenuStyleFrame
//            Rectangle{
//                anchors.fill: comboRoot;
//                color: "yellow";
//            }
//    //        IUserLevelImage1 {
//    //        }
//        }
//        onIndexChanged: {
//            m_userLevel = currentIndex + 1
//        }
//        Component.onCompleted: {
//            setComboBoxStyleBackground(comboBoxStyleBackground)
//            setDropDownMenuStyleFrame(dropDownMenuStyleFrame)
//        }
//    }


    TextRectangle{
        id: textRectangle
        x:432; y:304
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
        font.family: "Ubuntu"
        font.pixelSize: 40
        color: "darkred"
        clip: true
        visible: true
        focus: true
    }


    FullKeyboard{
        id:virtual_keyboard
        x:332; y:645
        width: 930; height: 371;
        isShifted: false
        isHighlighted: false
        property int count:0

        Component.onCompleted: {
            virtual_keyboard.strButtonClick.connect(typeIn)
            virtual_keyboard.funcButtonClicked.connect(functionIn)
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
                count--
                textInput=textInput.substring(0,textInput.length-1);
            }
        }

        function typeIn(str){
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



    //==============================================================

    ConfirmView{
        id: confirm_view
        show_text: "Dear Customer"
        show_detail: "Proceed This ?."
        z: 99
        MouseArea{
            id: ok_confirm_view
            x: 708; y:690
            width: 150; height: 50;
            onClicked: {
                console.log("Yes Confirm Button is pressed...")
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

