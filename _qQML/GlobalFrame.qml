import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0

Base{
    id:globalFrame
    isBoxNameActive: false
    property var textMain: 'Silakan Ambil Kartu dan Struk Transaksi Anda'
    property var textSlave: 'Terima Kasih'
    property var imageSource: "aAsset/thumb_ok.png"
    property bool smallerSlaveSize: true
    property int textSize: 30
    property int showDuration: 10
    property var closeMode: 'closeWindow' // 'closeWindow', 'backToMain', 'backToPrev'
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
        width: 900
        height: 500
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 30
        AnimatedImage  {
            width: 300
            height: 300
            scale: 0.9
            anchors.horizontalCenter: parent.horizontalCenter
            source: imageSource
            fillMode: Image.PreserveAspectFit
        }
        Text{
            text: textMain
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            font.pointSize: textSize
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: false
            color: 'white'
            verticalAlignment: Text.AlignVCenter
        }
        Text{
            text: textSlave
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            wrapMode: Text.WordWrap
            font.pointSize: (smallerSlaveSize) ? textSize-10: textSize
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: false
            color: 'white'
            verticalAlignment: Text.AlignVCenter
        }
    }


    Timer {
        id: show_timer
        interval: 1000
        repeat: true
        running: parent.visible
        onTriggered: {
            showDuration -= 1;
            if (showDuration==0) {
                show_timer.stop();
                switch(closeMode){
                case 'backToMain':
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }));
                    break;
                case 'backToPrev':
                    my_layer.pop();
                    break;
                default: close();
                    break;
                }
            }
        }
    }


    function open(){
        globalFrame.visible = true;
        show_timer.start();
    }

    function close(){
        globalFrame.visible = false;
    }
}
