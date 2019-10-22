import QtQuick 2.4
import QtQuick.Controls 1.3
import "base_function.js" as FUNC

Base{
    id:payment
    visible: false
    use_: 'payment'
    property var show_text//: qsTr("Please insert your cash into the cash slot below, Kindly ensure it is clean and not folded.")
//    property var show_text: "Please Insert Your Card Into The Reader, and Key In Your PIN Code to proceed payment."
    property var useMode: "MEI" //["EDC", "MEI", "QPROX"]
    property var count100: "0"
    property var count50: "0"
    property var count20: "0"
    property var count10: "0"
    property var count5: "0"
    property var count2: "0"
    property var totalGetCount: "0"//"470000"
    property var count5R: "0"//"2"
    property var count2R: "0"//"10"
    property var totalCountR: "0"//"30000"
    property var totalCost: "0"//"1399000"
    property var escapeFunction: "closeWindow"
    property var meiTextMode: "normal" //["normal", "continue", "exceeded"]
    property bool modeLoading: false
    property bool modeConfirm: false
    property bool styleText: false
    property bool isTest: false
    property var press_notif: "0"
    property bool mode55: false
    property bool cancelAble: true
    property bool secondTry: false
    property bool cancelButton: true


    Rectangle{
        id: base_overlay
        anchors.fill: parent
        color: "#472f2f"
        opacity: 0.7
    }

    Rectangle{
        id: white_base_rec
        visible: (useMode!="MEI" && modeLoading==false) ? true : false
        color: "silver"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: 750; height: 525
        Image{
            source: "source/close.png"
            visible: cancelButton
            width: 80
            height: 80
            anchors.top: parent.top
            anchors.topMargin: -30
            anchors.right: parent.right
            anchors.rightMargin: -30
            MouseArea{
                anchors.fill: parent
//                enabled: cancelButton
                onClicked: {
                    switch(escapeFunction){
                    case 'backToMain' : my_layer.pop(my_layer.find(function(item){if(item.Stack.index===0)return true}));
                        break;
                    case 'backToPrevious' : my_layer.pop();
                        break;
                    case 'forceClose': payment.visible = false;
                        break;
                    default: close('cancel');
                        break;
                    }
                }
            }
        }
        Row{
            id: row_edc
            visible: (useMode=="EDC") ? true : false
            anchors.top: parent.top
            anchors.topMargin: 75
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 25
            AnimatedImage{
                width: 300; height: 200;
                source: "source/insert_card_realistic.jpg"
                fillMode: Image.PreserveAspectFit
            }
            AnimatedImage{
                width: 300; height: 200;
                source: "source/input_card_pin_realistic.jpeg"
                fillMode: Image.PreserveAspectFit
            }
        }
        Row{
            id: row_qprox
            visible: (useMode=="QPROX") ? true : false
            anchors.top: parent.top
            anchors.topMargin: 75
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 25
            AnimatedImage{
                width: 300; height: 200;
                source: "source/cards_.png"
                fillMode: Image.PreserveAspectFit
            }
            AnimatedImage{
                width: 300; height: 200;
                source: "source/tap_card_.png"
                fillMode: Image.PreserveAspectFit
            }
        }
        Text {
            id: payment_text
            height: 120; width: parent.width - 50;
            color: "darkred"
            text: show_text
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            font.italic: (styleText==true) ? false : true
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignHCenter
            font.family:"Ubuntu"
            font.pixelSize: (styleText==true) ? 30 : 21
            font.bold: (styleText==true) ? true : false
        }
    }

    Rectangle{
        id: mei_base_rec
        visible: (useMode=="MEI" && modeLoading==false && modeConfirm==false) ? true : false
        color: "silver"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: 900; height: 650
        Image{
            source: "source/close.png"
            visible: cancelAble
            width: 80
            height: 80
            anchors.top: parent.top
            anchors.topMargin: -30
            anchors.right: parent.right
            anchors.rightMargin: -30
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    switch(escapeFunction){
                    case 'backToMain' : my_layer.pop(my_layer.find(function(item){if(item.Stack.index===0)return true}));
                        break;
                    case 'backToPrevious' : my_layer.pop();
                        break;
                    default: close('cancel');
                        break;
                    }
                }
            }
        }
        Text{
            id: title_main_text
            width: 750
            anchors.top: parent.top
            anchors.topMargin: 35
            font.pixelSize: 25
            text: (meiTextMode=='normal') ? qsTr("Please use exact money, This machine don't provide changes.") :
                                            qsTr("Syncing money, Please wait a moment")
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            font.bold: true
            font.italic: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            height: 60
            color: "darkred"
        }
/*        Row{
            id: row_mei
            anchors.top: parent.top
            anchors.topMargin: 25
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 25
            visible: parent.visible
            AnimatedImage{
                width: 300; height: 200;
                source: "source/prepare_cash_.png"
                fillMode: Image.PreserveAspectFit
            }
            AnimatedImage{
                width: 300; height: 200;
                source: "source/insert_cash_.png"
                fillMode: Image.PreserveAspectFit
            }
        }*/
        Image{
            id: insert_cash_image
            x: 625
            y: 116
            source: "source/insert_cash_rupiah.jpeg"
            width: 200
            height: 300
            fillMode: Image.PreserveAspectFit
        }
        Text{
            id: label_text_amount
            x: 371
            text: qsTr("RECEIVED CASH :")
            anchors.horizontalCenterOffset: -100
            anchors.verticalCenterOffset: -150
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: "Ubuntu"
            font.pixelSize: 20
            font.bold: false
            color: "darkred"
        }
        Text{
            id: text_get_amount
            text: "Rp. " + FUNC.insert_dot(totalGetCount) + ",-"
            anchors.horizontalCenterOffset: -100
            anchors.verticalCenterOffset: -75
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: "Ubuntu"
            font.pixelSize: 60
            font.bold: true
            color: "darkred"
        }
        Text{
            id: label_text_price
            text: qsTr("TOTAL PAID :")
            anchors.left: parent.left
            anchors.leftMargin: 100
            anchors.verticalCenterOffset: 70
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            font.family: "Ubuntu"
            font.pixelSize: 20
            font.bold: false
            color: "darkred"
        }
        Text{
            id: text_price
            text: "Rp. " + FUNC.insert_dot(totalCost) + ",-"
            anchors.left: parent.left
            anchors.leftMargin: 100
            anchors.verticalCenterOffset: 100
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            font.family: "Ubuntu"
            font.pixelSize: 25
            font.bold: true
            color: "darkred"
        }
        Text{
            id: label_text_price_minus
            text: (parseInt(totalGetCount) > parseInt(totalCost)) ? qsTr("PLUS :") : qsTr("MINUS :")
            anchors.right: parent.right
            anchors.rightMargin: 300
            anchors.verticalCenterOffset: 70
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            font.family: "Ubuntu"
            font.pixelSize: 20
            font.bold: false
            color: "darkred"
        }
        Text{
            id: text_price_minus
            y: 366
            text: "Rp. " + FUNC.insert_dot(FUNC.get_diff(totalCost, totalGetCount)) + ",-"
            anchors.right: parent.right
            anchors.rightMargin: 300
            anchors.verticalCenterOffset: 100
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            font.family: "Ubuntu"
            font.pixelSize: 25
            font.bold: true
            color: "darkred"
        }
        Text{
            id: label_notes_usable
            width: 750
            height: 60
            visible: (meiTextMode=="normal") ? true : false
            text: qsTr("Please ensure the cash is in good condition. Kindly insert the cash from the biggest denom.")
            wrapMode: Text.WordWrap
            font.italic: true
            font.bold: true
            font.pixelSize: 20
            font.family: "Ubuntu"
            color: "darkred"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 100
        }
        Text{
            id: label_notes_55
            width: 750
            height: 60
            visible: (meiTextMode=="process55") ? true : false
            text: qsTr("Please wait the first process. You will be able to continue the payment afterward.")
            wrapMode: Text.WordWrap
            font.italic: true
            font.bold: true
            font.pixelSize: 20
            font.family: "Ubuntu"
            color: "darkred"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 100
        }
        Row{
            property int adjust_point: 75
            height: 50;
            anchors.leftMargin: adjust_point
            anchors.left: parent.left;
            anchors.bottom: parent.bottom;
            anchors.bottomMargin: 25
            layoutDirection: Qt.LeftToRight;
            width: parent.width-adjust_point;
            spacing: 30
            visible: (meiTextMode=="normal") ? true : false
            Image{
                id: img_count_100
                width: 100; height: 50;
                rotation: 30
                source: "source/100rb.png"
                fillMode: Image.PreserveAspectFit
            }
            Image{
                id: img_count_50
                width: 100; height: 50;
                rotation: 30
                source: "source/50rb.png"
                fillMode: Image.PreserveAspectFit
            }
            Image{
                id: img_count_20
               width: 100; height: 50;
                rotation: 30
                source: "source/20rb.png"
                fillMode: Image.PreserveAspectFit
            }
            Image{
                id: img_count_10
                width: 100; height: 50;
                rotation: 30
                source: "source/10rb.png"
                fillMode: Image.PreserveAspectFit
            }
            Image{
                id: img_count_5
                width: 100; height: 50;
                rotation: 30
                source: "source/5rb.png"
                fillMode: Image.PreserveAspectFit
            }
            Image{
                id: img_count_2
                width: 100; height: 50;
                rotation: 30
                source: "source/2rb.png"
                fillMode: Image.PreserveAspectFit
            }

        }
        Text{
            id: label_oserror_process
            visible: (meiTextMode=="oserror") ? true : false
            text: qsTr("Something wrong with Bill Acceptor, Please retry payment.")
            wrapMode: Text.WordWrap
            font.bold: true
            font.pixelSize: 25
            font.family: "Ubuntu"
            color: "darkred"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 150
            ConfirmButton{
                id: cancel_button_oserror
                y: 60
                width: 190
                anchors.horizontalCenter: parent.horizontalCenter
                text_: qsTr("OK")
                visible: parent.visible
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        close('cancel');
                    }
                }
            }
        }
        Text{
            id: label_exceeded_process
            visible: (meiTextMode=="exceeded") ? true : false
            text: qsTr("Maximum Cash is exceeded, Please try another payment method.")
            wrapMode: Text.WordWrap
            font.bold: true
            font.pixelSize: 25
            font.family: "Ubuntu"
            color: "darkred"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 150
        }
        Text{
            id: label_continue_process
            visible: (meiTextMode=="continue") ? true : false
            text: qsTr("I am agree to continue this payment process.")
            wrapMode: Text.WordWrap
            font.bold: true
            font.pixelSize: 25
            font.family: "Ubuntu"
            color: "darkred"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 150
        }
        GroupBox{
            id: groupBox1
            flat: true
            x: 200
            y: 472
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            visible: (meiTextMode=="continue" || meiTextMode=="exceeded") ? true : false
            ConfirmButton{
                id: cancel_button
                y: 0
                width: 190
                anchors.left: parent.left
                anchors.leftMargin: 150
                text_: qsTr("Cancel")
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        close('cancel');
                        if (meiTextMode=="exceeded") mode55 = false;
                    }
                }
            }
            ConfirmButton{
                id: ok_button
                y: 0
                width: 190
                anchors.right: parent.right
//                anchors.rightMargin: (mode55==true) ? 330 : 150
                anchors.rightMargin: 150
                text_: qsTr("Proceed")
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        if (press_notif != "0") return;
                        press_notif = "1";
                        console.log("payment_confirmation button is pressed");
                        if (mode55==true){
                            if (secondTry==false){
                                _SLOT.start_store_es_mei();
                                modeLoading = true;
                            }
                        } else {
                            modeConfirm = true;
                            if (useMode=='MEI'){
                                _SLOT.start_mei_create_payment(select_payment.baseFare);
                            } else {
                                _SLOT.start_create_payment(select_payment.baseFare);
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle{
        id: rec_loading_payment
        visible: modeLoading
        color: "white"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: 750; height: 525
        AnimatedImage{
            anchors.verticalCenterOffset: -35
            anchors.horizontalCenterOffset: -5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: "source/simply_loading.gif"

        }
        Text{
            id: loading_text
            text: qsTr("Processing Payment...")
            height: 120; width: parent.width - 50;
            color: "darkred"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            font.italic: true
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignHCenter
            font.family:"Ubuntu"
            font.pixelSize: 25
        }
    }

    Rectangle{
        id: rec_confirm_payment
        visible: modeConfirm
        color: "white"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: 750; height: 525
        AnimatedImage{
            anchors.verticalCenterOffset: -35
            anchors.horizontalCenterOffset: -5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: "source/simply_loading.gif"

        }
        Text{
            id: confirming_text
            text: qsTr("Confirming Payment...")
            height: 120; width: parent.width - 50;
            color: "darkred"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            font.italic: true
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignHCenter
            font.family:"Ubuntu"
            font.pixelSize: 25
        }
    }

    function open(){
        loading_text.text =  qsTr("Processing Payment...");
        modeLoading = false;
        modeConfirm = false;
        meiTextMode = "normal";
        totalGetCount = "0";
        cancelAble = true;
        secondTry = false;
        payment.visible = true;
        press_notif = "0";
    }

    function close(mode){
        if (mode=='cancel'){
            console.log('payment_cancellation by user');
        }
        if (isTest==true) {
            test_payment.releaseButton(useMode);
        } else {
            select_payment.releaseButton(useMode);
        }
        loading_text.text =  qsTr("Closing Payment Session...");
        modeLoading = true;
    }
}
