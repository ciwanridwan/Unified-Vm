import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0
import "screen.js" as SCREEN


Base{
    id:globalConfirmationFrame
    width: parseInt(SCREEN.size.width)
    height: parseInt(SCREEN.size.height)
    isBoxNameActive: false
    property var textMain: 'Ringkasan Transaksi'
    property bool withTimer: false
    property int textSize: 40
    property int timerDuration: 15
    property int showDuration: timerDuration
    property var closeMode: 'closeWindow' // 'closeWindow', 'backToMain', 'backToPrev'
    property var calledFrom: 'global_input_number'
    property bool modeConfirm: false
    property bool disableButton: false
    property alias label1: row1.labelName
    property alias data1: row1.labelContent
    property alias label2: row2.labelName
    property alias data2: row2.labelContent
    property alias label3: row3.labelName
    property alias data3: row3.labelContent
    property alias label4: row4.labelName
    property alias data4: row4.labelContent
    property alias label5: row5.labelName
    property alias data5: row5.labelContent
    property alias label6: row6.labelName
    property alias data6: row6.labelContent
    property alias label7: row7.labelName
    property alias data7: row7.labelContent
    visible: false
    opacity: visible ? 1.0 : 0.0
    Behavior on opacity {
        NumberAnimation  { duration: 500 ; easing.type: Easing.InOutQuad  }
    }

    MainTitle{
        id: main_title
        anchors.top: parent.top
        anchors.topMargin: 200
        anchors.horizontalCenter: parent.horizontalCenter
        show_text: textMain
        size_: 50
        color_: "white"

    }

    CircleButton{
        id: back_button
        anchors.left: parent.left
        anchors.leftMargin: 100
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        button_text: 'BATAL'
        modeReverse: true
        visible: !disableButton
        MouseArea{
            anchors.fill: parent
            onClicked: {
                _SLOT.user_action_log('Press "BATAL" In Confirmation Page');
                my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }));
            }
        }
    }

    CircleButton{
        id: next_button
        anchors.right: parent.right
        anchors.rightMargin: 100
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        button_text: (modeConfirm) ? 'LANJUT' : 'O K'
        modeReverse: true
        visible: !disableButton
        MouseArea{
            anchors.fill: parent
            onClicked: {
                _SLOT.user_action_log('Press "LANJUT" In Confirmation Page');
                if (!modeConfirm){
                    console.log('Press "OK" in Confirmation Page')
                    switch(closeMode){
                    case 'backToMain':
                        my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }));
                        break;
                    case 'backToPrev': case 'backToPrevious':
                        my_layer.pop();
                        break;
                    default: close();
                        break;
                    }
                    return;
                } else {
                    console.log('Press "LANJUT" in Confirmation Page')
                    switch(calledFrom){
                    case 'global_input_number':
                        global_input_number.set_confirmation('global_confirmation_frame');
                        return;
                    case 'mandiri_shop_card':
                        mandiri_shop_card.set_confirmation('global_confirmation_frame');
                        return;
                    case 'prepaid_topup_denom':
                        prepaid_topup_denom.set_confirmation('global_confirmation_frame');
                        return;
                    default:
                        return;
                    }
                }
            }
        }
    }

    Column{
        width: 900
        height: 500
        anchors.horizontalCenterOffset: 50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20

        TextDetailRow{
            id: row1
        }

        TextDetailRow{
            id: row2
        }

        TextDetailRow{
            id: row3
        }

        TextDetailRow{
            id: row4
        }

        TextDetailRow{
            id: row5
        }

        TextDetailRow{
            id: row6
        }

        TextDetailRow{
            id: row7
        }

    }


    Timer {
        id: show_timer
        interval: 1000
        repeat: true
        running: parent.visible && withTimer
        onTriggered: {
            showDuration -= 1;
            if (showDuration==0) {
                show_timer.stop();
                switch(closeMode){
                case 'backToMain':
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }));
                    break;
                case 'backToPrev': case 'backToPrevious':
                    my_layer.pop();
                    break;
                default: close();
                    break;
                }
            }
        }
    }


//    function destroy(){
//        switch(closeMode){
//        case 'backToMain':
//            my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }));
//            break;
//        case 'backToPrev': case 'backToPrevious':
//            my_layer.pop();
//            break;
//        default: close();
//            break;
//        }
//    }


    function open(){
        globalConfirmationFrame.visible = true;
        if (withTimer){
            showDuration = timerDuration;
            show_timer.start();
        }
    }


    function close(){
        globalConfirmationFrame.visible = false;
        if (withTimer) show_timer.stop();
    }

    function no_button(){
        disableButton = true;
    }

}
