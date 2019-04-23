import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0
import "base_function.js" as FUNC


Rectangle{
    id:notification_standard
    property var show_img: "aAsset/promo_black.png"
    property var show_text: qsTr("Silakan Pilih Nominal")
    property bool withBackground: true
    property bool modeReverse: true
    property var bigDenomAmount: 100
    property var smallDenomAmount: 50
    property var tinyDenomAmount: 25
    property var miniDenomAmount: 10
    property var _adminFee: 1500
    property var _provider: undefined

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
        width: (miniDenomAmount > 0) ? 950 : 800
        height: 500
        color: (modeReverse) ? "white" : "#9E4305"
        opacity: .97
        radius: 30
        border.width: 0
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
        spacing: (miniDenomAmount > 0) ? 40 : 60
        anchors.verticalCenter: notif_rec.verticalCenter
        visible: !standard_notif_view.visible

        MasterButtonNew {
            id: big_denom_button
            width: 180
            height: 250
            anchors.verticalCenter: parent.verticalCenter
            img_: "aAsset/cash_money.png"
            text_: 'Rp. ' + FUNC.insert_dot(bigDenomAmount.toString()) + ',-'
            text2_: qsTr("")
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press Denom "'+bigDenomAmount.toString()+'"');
                    if (prepaid_topup_denom.press != '0') return;
                    prepaid_topup_denom.press = '1';
                    var param = JSON.stringify({
                        'provider': _provider,
                        'value': bigDenomAmount.toString(),
                        'admin_fee': _adminFee.toString()
                    })
                    prepaid_topup_denom.topup_denom_signal(param);
                }
            }
        }

        MasterButtonNew {
            id: small_denom_button
            width: 180
            height: 250
            anchors.verticalCenter: parent.verticalCenter
            img_: "aAsset/cash_money.png"
            text_: 'Rp. ' + FUNC.insert_dot(smallDenomAmount.toString()) + ',-'
            text2_: qsTr("")
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press Denom "'+smallDenomAmount.toString()+'"');
                    if (prepaid_topup_denom.press != '0') return;
                    prepaid_topup_denom.press = '1';
                    var param = JSON.stringify({
                        'provider': _provider,
                        'value': smallDenomAmount.toString(),
                        'admin_fee': _adminFee.toString()
                    })
                    prepaid_topup_denom.topup_denom_signal(param);
                }
            }
        }

        MasterButtonNew {
            id: tiny_denom_button
            width: 180
            height: 250
            visible: (tinyDenomAmount==0) ? false : true
            anchors.verticalCenter: parent.verticalCenter
            img_: "aAsset/cash_money.png"
            text_: 'Rp. ' + FUNC.insert_dot(tinyDenomAmount.toString()) + ',-'
            text2_: qsTr("")
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press Denom "'+tinyDenomAmount.toString()+'"');
                    if (prepaid_topup_denom.press != '0') return;
                    prepaid_topup_denom.press = '1';
                    var param = JSON.stringify({
                        'provider': _provider,
                        'value': tinyDenomAmount.toString(),
                        'admin_fee': _adminFee.toString()
                    })
                    prepaid_topup_denom.topup_denom_signal(param);
                }
            }
        }


        MasterButtonNew {
            id: mini_denom_button
            width: 180
            height: 250
            visible: (miniDenomAmount==0) ? false : true
            anchors.verticalCenter: parent.verticalCenter
            img_: "aAsset/cash_money.png"
            text_: 'Rp. ' + FUNC.insert_dot(miniDenomAmount.toString()) + ',-'
            text2_: qsTr("")
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    _SLOT.user_action_log('Press Denom "'+miniDenomAmount.toString()+'"');
                    if (prepaid_topup_denom.press != '0') return;
                    prepaid_topup_denom.press = '1';
                    var param = JSON.stringify({
                        'provider': _provider,
                        'value': miniDenomAmount.toString(),
                        'admin_fee': _adminFee.toString()
                    })
                    prepaid_topup_denom.topup_denom_signal(param);
                }
            }
        }

    }
}
