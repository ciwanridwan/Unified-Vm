import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0
import "screen.js" as SCREEN


Rectangle{
    id:select_payment_popup
    property var show_text: qsTr("Silakan Pilih Metode Bayar")
    property bool withBackground: true
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
    width: parseInt(SCREEN.size.width)
    height: parseInt(SCREEN.size.height)
    scale: visible ? 1.0 : 0.1
    Behavior on scale {
        NumberAnimation  { duration: 500 ; easing.type: Easing.InOutBounce  }
    }

    Rectangle{
        id: base_overlay
        visible: withBackground
        anchors.fill: parent
        color: "black"
        opacity: 0.6
    }

    Rectangle{
        id: notif_rec
        width: parent.width
        height: 500
        color: (modeReverse) ? "black" : "white"
        opacity: .8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        id: main_text
        color: (modeReverse) ? "white" : "black"
        text: show_text
        font.bold: true
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.top: notif_rec.top
        anchors.topMargin: 50
        anchors.horizontalCenterOffset: 5
        font.family:"Ubuntu"
        anchors.horizontalCenter: notif_rec.horizontalCenter
        font.pixelSize: 30
    }

    Row{
        id: row_button
        anchors.verticalCenterOffset: 50
        anchors.horizontalCenter: notif_rec.horizontalCenter
        spacing: 60
        anchors.verticalCenter: notif_rec.verticalCenter

        MasterButtonNew {
            width: 200
            height: 270
            anchors.verticalCenter: parent.verticalCenter
            img_: "source/cash black.png"
            text_: qsTr("Tunai")
            text2_: qsTr("Cash")
            visible: _cashEnable
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    var payment = 'cash';
                    if (calledFrom=='prepaid_topup_denom'){
                        if (prepaid_topup_denom.press != '0') return;
                        prepaid_topup_denom.press = '1';
                        prepaid_topup_denom.select_payment_signal(payment);
                    }
                    if (calledFrom=='shop_prepaid_card'){
                        if (shop_prepaid_card.press != '0') return;
                        shop_prepaid_card.press = '1';
                        shop_prepaid_card.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='global_input_number'){
                        if (global_input_number.press != '0') return;
                        global_input_number.press = '1';
                        global_input_number.get_payment_method_signal(payment);
                    }
                }
            }
        }

        MasterButtonNew {
            width: 200
            height: 270
            anchors.verticalCenter: parent.verticalCenter
            img_: "source/credit card black.png"
            text_: qsTr("Kartu Debit")
            text2_: qsTr("Debit Card")
            visible: _cardEnable
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    var payment = 'debit';
                    if (calledFrom=='prepaid_topup_denom'){
                        if (prepaid_topup_denom.press != '0') return;
                        prepaid_topup_denom.press = '1';
                        prepaid_topup_denom.select_payment_signal(payment);
                    }
                    if (calledFrom=='shop_prepaid_card'){
                        if (shop_prepaid_card.press != '0') return;
                        shop_prepaid_card.press = '1';
                        shop_prepaid_card.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='global_input_number'){
                        if (global_input_number.press != '0') return;
                        global_input_number.press = '1';
                        global_input_number.get_payment_method_signal(payment);
                    }

                }
            }
        }

        MasterButtonNew {
            width: 200
            height: 270
            anchors.verticalCenter: parent.verticalCenter
            img_: "source/qr_ovo.png"
            text_: qsTr("QR OVO")
            text2_: qsTr("QR OVO")
            visible: _qrOvoEnable
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    var payment = 'ovo';
                    if (calledFrom=='prepaid_topup_denom'){
                        if (prepaid_topup_denom.press != '0') return;
                        prepaid_topup_denom.press = '1';
                        prepaid_topup_denom.select_payment_signal(payment);
                    }
                    if (calledFrom=='shop_prepaid_card'){
                        if (shop_prepaid_card.press != '0') return;
                        shop_prepaid_card.press = '1';
                        shop_prepaid_card.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='global_input_number'){
                        if (global_input_number.press != '0') return;
                        global_input_number.press = '1';
                        global_input_number.get_payment_method_signal(payment);
                    }

                }
            }
        }

        MasterButtonNew {
            width: 200
            height: 270
            anchors.verticalCenter: parent.verticalCenter
            img_: "source/qr_linkaja.png"
            text_: qsTr("QR LinkAja")
            text2_: qsTr("QR LinkAja")
            visible: _qrLinkAjaEnable
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    var payment = 'linkaja';
                    if (calledFrom=='prepaid_topup_denom'){
                        if (prepaid_topup_denom.press != '0') return;
                        prepaid_topup_denom.press = '1';
                        prepaid_topup_denom.select_payment_signal(payment);
                    }
                    if (calledFrom=='shop_prepaid_card'){
                        if (shop_prepaid_card.press != '0') return;
                        shop_prepaid_card.press = '1';
                        shop_prepaid_card.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='global_input_number'){
                        if (global_input_number.press != '0') return;
                        global_input_number.press = '1';
                        global_input_number.get_payment_method_signal(payment);
                    }

                }
            }
        }

        MasterButtonNew {
            width: 200
            height: 270
            anchors.verticalCenter: parent.verticalCenter
            img_: "source/qr_gopay.png"
            text_: qsTr("QR Gopay")
            text2_: qsTr("QR Gopay")
            visible: _qrGopayEnable
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    var payment = 'gopay';
                    if (calledFrom=='prepaid_topup_denom'){
                        if (prepaid_topup_denom.press != '0') return;
                        prepaid_topup_denom.press = '1';
                        prepaid_topup_denom.select_payment_signal(payment);
                    }
                    if (calledFrom=='shop_prepaid_card'){
                        if (shop_prepaid_card.press != '0') return;
                        shop_prepaid_card.press = '1';
                        shop_prepaid_card.get_payment_method_signal(payment);
                    }
                    if (calledFrom=='global_input_number'){
                        if (global_input_number.press != '0') return;
                        global_input_number.press = '1';
                        global_input_number.get_payment_method_signal(payment);
                    }

                }
            }
        }

        MasterButtonNew {
            width: 200
            height: 270
            anchors.verticalCenter: parent.verticalCenter
            img_: "source/qr_dana.png"
            text_: qsTr("QR Dana")
            text2_: qsTr("QR Dana")
            visible: _qrDanaEnable
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    var payment = 'dana';
                    if (calledFrom=='prepaid_topup_denom'){
                        if (prepaid_topup_denom.press != '0') return;
                        prepaid_topup_denom.press = '1';
                        prepaid_topup_denom.select_payment_signal(payment);
                    }
                    if (calledFrom=='shop_prepaid_card'){
                        if (shop_prepaid_card.press != '0') return;
                        shop_prepaid_card.press = '1';
                        shop_prepaid_card.get_payment_method_signal(payment);
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

}
