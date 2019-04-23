import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0

Rectangle{
    id:notification_standard
    property var show_img: "aAsset/promo_black.png"
    property var show_text: qsTr("Silakan Pilih Metode Bayar")
    property bool withBackground: true
    property bool modeReverse: true
    property var calledFrom: 'prepaid_topup_denom'
    visible: false
    color: 'transparent'
    width: 1920
    height: 1080
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
        width: 800
        height: 500
        color: (modeReverse) ? "white" : "#9E4305"
        opacity: .97
        radius: 20
        anchors.horizontalCenterOffset: 150
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        Image  {
            id: image
            x: 20
            y: 20
            width: 100
            height: 100
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 10
            scale: 0.8
            source: show_img
            fillMode: Image.PreserveAspectFit
            visible: (modeReverse) ? true : false
        }
        ColorOverlay {
            visible: !image.visible
            anchors.fill: image
            source: image
            scale: 0.8
            color: "#ffffff"
        }

    }

    Text {
        id: main_text
        color: (modeReverse) ? "#9E4305" : "white"
        text: show_text
        font.bold: true
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.top: notif_rec.top
        anchors.topMargin: 50
        anchors.horizontalCenterOffset: 5
        font.family:"Microsoft YaHei"
        anchors.horizontalCenter: notif_rec.horizontalCenter
        font.pixelSize: 30
    }

    Row{
        id: row_button
        anchors.verticalCenterOffset: 50
        anchors.horizontalCenter: notif_rec.horizontalCenter
        spacing: 60
        anchors.verticalCenter: notif_rec.verticalCenter
        visible: !standard_notif_view.visible

        MasterButtonNew {
            width: 180
            height: 250
            anchors.verticalCenter: parent.verticalCenter
            img_: "aAsset/cash black.png"
            text_: qsTr("Tunai")
            text2_: qsTr("Cash")
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
                }
            }
        }

        MasterButtonNew {
            width: 180
            height: 250
            anchors.verticalCenter: parent.verticalCenter
            img_: "aAsset/credit card black.png"
            text_: qsTr("Kartu Debit")
            text2_: qsTr("Debit Card")
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

                }
            }
        }
    }

}
