import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0

Base{
    id:preload_check_card
    isBoxNameActive: false
    property var textMain: 'Letakan kartu                        Anda di alat pembaca kartu yang bertanda '
    property var textSlave: 'Pastikan kartu Anda tetap berada di alat pembaca kartu sampai transaksi selesai'
    property var imageSource: "aAsset/reader_sign.png"
    property bool smallerSlaveSize: true
    property int textSize: 35
    visible: false
//    scale: visible ? 1.0 : 0.1
//    Behavior on scale {
//        NumberAnimation  { duration: 500 ; easing.type: Easing.InOutBounce  }
//    }

//    Rectangle{
//        anchors.fill: parent
//        color: "gray"
//        opacity: 0.5
//    }

    Column{
        width: 1500
        height: 500
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 30
        Text{
            text: textMain
            font.pointSize: textSize
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: false
            color: 'white'
            verticalAlignment: Text.AlignVCenter
        }
        AnimatedImage  {
            width: 300
            height: 300
            anchors.horizontalCenter: parent.horizontalCenter
            source: imageSource
            fillMode: Image.PreserveAspectFit
        }
        Text{
            text: textSlave
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            wrapMode: Text.WordWrap
            font.pointSize: (smallerSlaveSize) ? textSize-5: textSize
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: false
            color: 'white'
            verticalAlignment: Text.AlignVCenter
        }
    }

    Image{
        width: 225
        height: 80
        anchors.left: parent.left
        anchors.leftMargin: 545
        anchors.top: parent.top
        anchors.topMargin: 276
        source: "aAsset/emoney_logo.png"
        fillMode: Image.PreserveAspectFit
    }

    function open(){
        preload_check_card.visible = true
    }

    function close(){
        preload_check_card.visible = false
    }
}
