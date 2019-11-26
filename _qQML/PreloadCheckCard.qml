import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0

Base{
    id:preload_check_card
    isBoxNameActive: false
    property var textMain: 'Letakkan kartu prabayar Anda di alat pembaca kartu yang bertanda '
    property var textSlave: 'Pastikan kartu Anda tetap berada di alat pembaca kartu sampai transaksi selesai'
    property var imageSource: "source/reader_sign.png"
    property bool smallerSlaveSize: true
    property int textSize: 45
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

    Column{
        width: 1500
        height: 500
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
            font.pixelSize: (smallerSlaveSize) ? textSize-5: textSize
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: false
            color: 'white'
            verticalAlignment: Text.AlignVCenter
        }
    }

//    Image{
//        width: 210
//        height: 80
//        anchors.left: parent.left
//        anchors.leftMargin: 565
//        anchors.top: parent.top
//        anchors.topMargin: 280
//        source: "source/emoney_logo.png"
//        fillMode: Image.PreserveAspectFit
//    }

    function open(){
        preload_check_card.visible = true
    }

    function close(){
        preload_check_card.visible = false
    }
}
