import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0
import "screen.js" as SCREEN
import "config.js" as CONF


Rectangle{
    id:select_payment_popup
    property var title_text: "Pilih Metode Pembayaran"
    property bool modeReverse: true
    property var calledFrom: 'prepaid_topup_denom'
    property bool _cashEnable: false
    property bool _cardEnable: false
    property bool _qrOvoEnable: false
    property bool _qrDanaEnable: false
    property bool _qrGopayEnable: false
    property bool _qrLinkAjaEnable: false
    property var totalEnable: 6
    visible: false
    color: 'transparent'
    height: 350
    width: parseInt(SCREEN.size.width)
    scale: visible ? 1.0 : 0.1
    Behavior on scale {
        NumberAnimation  { duration: 500 ; easing.type: Easing.InOutBounce  }
    }

    MainTitle{
        id: main_text
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        show_text: title_text
        size_: 50
        color_: CONF.text_color
    }

    Row{
        id: row_button
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: 300
        anchors.verticalCenterOffset: 50
        spacing: 50

        SmallSimplyItem {
            id: button_cash
            width: 359
            height: 183
            anchors.verticalCenter: parent.verticalCenter
            sourceImage: "source/cash black.png"
            itemName: "Tunai"
            modeReverse: true
            visible: _cashEnable
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('choose "CASH" Payment Method');
                    var payment = 'cash';
                    do_release_all_set_active(button_cash);
                    if (calledFrom=='prepaid_topup_denom'){
                        if (prepaid_topup_denom.press != '0') return;
                        prepaid_topup_denom.press = '1';
                        prepaid_topup_denom.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='mandiri_shop_card'){
                        if (mandiri_shop_card.press != '0') return;
                        mandiri_shop_card.press = '1';
                        mandiri_shop_card.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='global_input_number'){
                        if (global_input_number.press != '0') return;
                        global_input_number.press = '1';
                        global_input_number.get_payment_method_signal(payment);
                    }

                }
            }
        }

        SmallSimplyItem {
            id: button_debit
            width: 359
            height: 183
            anchors.verticalCenter: parent.verticalCenter
            sourceImage: "source/credit card black.png"
            itemName: "Kartu Debit"
            modeReverse: true
            visible: _cardEnable
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('choose "DEBIT/CREDIT" Payment Method');
                    var payment = 'debit';
                    do_release_all_set_active(button_debit);
                    if (calledFrom=='prepaid_topup_denom'){
                        if (prepaid_topup_denom.press != '0') return;
                        prepaid_topup_denom.press = '1';
                        prepaid_topup_denom.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='mandiri_shop_card'){
                        if (mandiri_shop_card.press != '0') return;
                        mandiri_shop_card.press = '1';
                        mandiri_shop_card.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='global_input_number'){
                        if (global_input_number.press != '0') return;
                        global_input_number.press = '1';
                        global_input_number.get_payment_method_signal(payment);
                    }


                }
            }
        }

        SmallSimplyItem {
            id: button_ovo
            width: 359
            height: 183
            anchors.verticalCenter: parent.verticalCenter
            sourceImage: "source/qr_ovo.png"
            itemName: "QR OVO"
            modeReverse: true
            visible: _qrOvoEnable
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('choose "OVO" Payment Method');
                    var payment = 'ovo';
                    do_release_all_set_active(button_ovo);
                    if (calledFrom=='prepaid_topup_denom'){
                        if (prepaid_topup_denom.press != '0') return;
                        prepaid_topup_denom.press = '1';
                        prepaid_topup_denom.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='mandiri_shop_card'){
                        if (mandiri_shop_card.press != '0') return;
                        mandiri_shop_card.press = '1';
                        mandiri_shop_card.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='global_input_number'){
                        if (global_input_number.press != '0') return;
                        global_input_number.press = '1';
                        global_input_number.get_payment_method_signal(payment);
                    }

                }
            }
        }

        SmallSimplyItem {
            id: button_linkaja
            width: 359
            height: 183
            anchors.verticalCenter: parent.verticalCenter
            sourceImage: "source/qr_linkaja.png"
            itemName: "QR LinkAja"
            modeReverse: true
            visible: _qrLinkAjaEnable
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('choose "LINKAJA" Payment Method');
                    var payment = 'linkaja';
                    do_release_all_set_active(button_linkaja);
                    if (calledFrom=='prepaid_topup_denom'){
                        if (prepaid_topup_denom.press != '0') return;
                        prepaid_topup_denom.press = '1';
                        prepaid_topup_denom.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='mandiri_shop_card'){
                        if (mandiri_shop_card.press != '0') return;
                        mandiri_shop_card.press = '1';
                        mandiri_shop_card.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='global_input_number'){
                        if (global_input_number.press != '0') return;
                        global_input_number.press = '1';
                        global_input_number.get_payment_method_signal(payment);
                    }

                }
            }
        }

        SmallSimplyItem {
            id: button_gopay
            width: 359
            height: 183
            anchors.verticalCenter: parent.verticalCenter
            sourceImage: "source/qr_gopay.png"
            itemName: "QR Gopay"
            modeReverse: true
            visible: _qrGopayEnable
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('choose "GOPAY" Payment Method');
                    var payment = 'gopay';
                    do_release_all_set_active(button_gopay);
                    if (calledFrom=='prepaid_topup_denom'){
                        if (prepaid_topup_denom.press != '0') return;
                        prepaid_topup_denom.press = '1';
                        prepaid_topup_denom.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='mandiri_shop_card'){
                        if (mandiri_shop_card.press != '0') return;
                        mandiri_shop_card.press = '1';
                        mandiri_shop_card.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='global_input_number'){
                        if (global_input_number.press != '0') return;
                        global_input_number.press = '1';
                        global_input_number.get_payment_method_signal(payment);
                    }

                }
            }
        }

        SmallSimplyItem {
            id: button_dana
            width: 359
            height: 183
            anchors.verticalCenter: parent.verticalCenter
            sourceImage: "source/qr_dana.png"
            itemName: "QR Dana"
            modeReverse: true
            visible: _qrDanaEnable
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('choose "DANA" Payment Method');
                    var payment = 'dana';
                    do_release_all_set_active(button_dana);
                    if (calledFrom=='prepaid_topup_denom'){
                        if (prepaid_topup_denom.press != '0') return;
                        prepaid_topup_denom.press = '1';
                        prepaid_topup_denom.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='mandiri_shop_card'){
                        if (mandiri_shop_card.press != '0') return;
                        mandiri_shop_card.press = '1';
                        mandiri_shop_card.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='global_input_number'){
                        if (global_input_number.press != '0') return;
                        global_input_number.press = '1';
                        global_input_number.get_payment_method_signal(payment);
                    }

                }
            }
        }

    }


    function do_release_all_set_active(id){
        button_cash.do_release();
        button_debit.do_release();
        button_ovo.do_release();
        button_linkaja.do_release();
        button_gopay.do_release();
        button_dana.do_release();
        id.set_active();
    }


//    Flickable{
//        id: flick_button
//        width: parent.width
//        height: 200
//        anchors.bottom: parent.bottom
//        anchors.bottomMargin: 25
//        anchors.horizontalCenter: notif_rec.horizontalCenter
//        contentHeight: row_button.height
//        contentWidth: row_button.width
//    }


//    CircleButton{
//        id:back_button
//        anchors.left: parent.left
//        anchors.leftMargin: 100
//        anchors.bottom: parent.bottom
//        anchors.bottomMargin: 50
//        button_text: 'BATAL'
//        modeReverse: true
//        MouseArea{
//            anchors.fill: parent
//            onClicked: {
//                _SLOT.user_action_log('press "BATAL" In Select Payment Frame');
//                my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }));
//            }
//        }
//    }


}
