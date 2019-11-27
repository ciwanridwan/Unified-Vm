import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0

Base{
    id:preload_shop_card
    isBoxNameActive: false
    property var textMain: 'Kartu Mandiri e-Money yang dijual pada mesin ini memiliki keterangan sebagai berikut :'
    property var textSlave: '1. Saldo awal kartu = Rp. 30.000 per kartu'
    property var textRebel: '2. Biaya pembelian kartu perdana = Rp. 20.000 per kartu'
    property var textQuard: 'sehingga, dana yang perlu dibayarkan oleh pembeli = Rp. 50.000 per kartu'
    property var imageSource: "source/reader_sign.png"
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
        anchors.topMargin: 300
        anchors.horizontalCenter: parent.horizontalCenter
        show_text: 'Penting : Informasi Pembelian Kartu'
        size_: 50
        color_: "yellow"

    }

    Column{
        width: 1600
        height: 500
        anchors.verticalCenterOffset: 125
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 30
        Text{
            text: textMain
            font.pixelSize: textSize
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: false
            color: 'white'
            verticalAlignment: Text.AlignVCenter
            font.family: "Ubuntu"
        }
        Text{
            text: textSlave
            horizontalAlignment: Text.AlignLeft
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: (smallerSlaveSize) ? textSize-5: textSize
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: false
            color: 'white'
            verticalAlignment: Text.AlignVCenter
            font.family: "Ubuntu"
        }
        Text{
            text: textRebel
            horizontalAlignment: Text.AlignLeft
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: (smallerSlaveSize) ? textSize-5: textSize
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: false
            color: 'white'
            verticalAlignment: Text.AlignVCenter
            font.family: "Ubuntu"
        }
        Text{
            text: textQuard
            horizontalAlignment: Text.AlignLeft
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: (smallerSlaveSize) ? textSize-5: textSize
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: false
            color: 'white'
            verticalAlignment: Text.AlignVCenter
            font.family: "Ubuntu"
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
        preload_shop_card.visible = true
    }

    function close(){
        preload_shop_card.visible = false
    }
}
