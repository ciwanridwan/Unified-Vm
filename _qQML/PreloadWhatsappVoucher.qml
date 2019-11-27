import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0

Base{
    id:preload_whatasapp_voucher
    isBoxNameActive: false
    property var textMain: 'Untuk mengaktifkan fitur ini, Silakan lakukan hal berikut :'
    property var textSlave: '1. Pada smartphone Anda, unduh Aplikasi QR Reader/Pembaca QR'
    property var textRebel: '2. Buka Tautan yang terbaca pada Aplikasi tersebut (membuka aplikasi Whatsapp Anda)'
    property var textQuard: '3. Kirim text "START" pada Aplikasi Whatsapp Anda pada nomor tersebut.'
    property var imageSource: "source/qr_transjakarta_register.jpeg"
    property bool smallerSlaveSize: true
    property int textSize: 40
    visible: false
    opacity: visible ? 1.0 : 0.0
    Behavior on opacity {
        NumberAnimation  { duration: 500 ; easing.type: Easing.InOutQuad  }
    }

//    Rectangle{
//        anchors.fill: parent
//        color: "gray"
//        opacity: 0.5
//    }

    MainTitle{
        anchors.top: parent.top
        anchors.topMargin: 180
        anchors.horizontalCenter: parent.horizontalCenter
        show_text: 'Fitur Baru : Kemudahan Transaksi Dari Whatsapp'
        size_: 50
        color_: "yellow"

    }

    Column{
        id: column
        width: parent.width
        height: 500
        anchors.verticalCenterOffset: -20
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20
        AnimatedImage  {
            width: 400
            height: 400
            scale: 1
            anchors.horizontalCenter: parent.horizontalCenter
            source: imageSource
            fillMode: Image.PreserveAspectFit
        }
//        Text{
//            text: textMain
//            font.pixelSize: textSize
//            wrapMode: Text.WordWrap
//            horizontalAlignment: Text.AlignHCenter
//            width: parent.width - 180
//            anchors.horizontalCenter: parent.horizontalCenter
//            font.bold: false
//            color: 'white'
//            verticalAlignment: Text.AlignVCenter
//            font.family: 'Gotham'
//        }
        Text{
            text: textSlave
            horizontalAlignment: Text.AlignLeft
            width: parent.width - 250
            wrapMode: Text.WordWrap
            font.pixelSize: (smallerSlaveSize) ? textSize-5: textSize
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: false
            color: 'white'
            verticalAlignment: Text.AlignVCenter
            font.family: 'Gotham'
        }
        Text{
            text: textRebel
            horizontalAlignment: Text.AlignLeft
            width: parent.width - 250
            wrapMode: Text.WordWrap
            font.pixelSize: (smallerSlaveSize) ? textSize-5: textSize
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: false
            color: 'white'
            verticalAlignment: Text.AlignVCenter
            font.family: 'Gotham'
        }
        Text{
            text: textQuard
            horizontalAlignment: Text.AlignLeft
            width: parent.width - 250
            wrapMode: Text.WordWrap
            font.pixelSize: (smallerSlaveSize) ? textSize-5: textSize
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: false
            color: 'white'
            verticalAlignment: Text.AlignVCenter
            font.family: 'Gotham'
        }

    }

//    Image{
//        width: 210
//        height: 80
//        visible: false
//        anchors.left: parent.left
//        anchors.leftMargin: 565
//        anchors.top: parent.top
//        anchors.topMargin: 280
//        source: "source/emoney_logo.png"
//        fillMode: Image.PreserveAspectFit
//    }

    function open(){
        preload_whatasapp_voucher.visible = true
    }

    function close(){
        preload_whatasapp_voucher.visible = false
    }
}
