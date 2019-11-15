import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0

Base{
    id:globalFrame
    isBoxNameActive: false
    property var textMain: 'Silakan Ambil Kartu dan Struk Transaksi Anda'
    property var textSlave: 'Terima Kasih'
    property var imageSource: "source/phone_qr.png"
    property bool smallerSlaveSize: true
    property bool withTimer: true
    property int textSize: 40
    property int timerDuration: 5
    property int showDuration: timerDuration
    property var closeMode: 'closeWindow' // 'closeWindow', 'backToMain', 'backToPrev'
    visible: false
    opacity: visible ? 1.0 : 0.0
    Behavior on opacity {
        NumberAnimation  { duration: 500 ; easing.type: Easing.InOutQuad  }
    }

    Column{
        width: 900
        height: 500
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 30
        AnimatedImage  {
            id: original_image
            width: 300
            height: 300
            scale: 0.9
            anchors.horizontalCenter: parent.horizontalCenter
            source: imageSource
            fillMode: Image.PreserveAspectFit
        }
//        ColorOverlay {
//            id: reverse_original_image
//            anchors.fill: original_image
//            source: original_image
//            color: 'white'
//            scale: original_image.scale
//            visible: (imageSource.indexOf('black') > -1)
//        }
        Text{
            text: textMain
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            font.pixelSize: textSize
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: false
            color: 'white'
            verticalAlignment: Text.AlignVCenter
            font.family:"Ubuntu"
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
            font.family:"Ubuntu"
        }
    }


    Timer {
        id: show_timer
        interval: 1000
        repeat: true
        running: parent.visible && withTimer
        onTriggered: {
            showDuration -= 1;
            if (showDuration==0) {
                show_timer.stop();
                switch(closeMode){
                case 'backToMain':
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }));
                    break;
                case 'backToPrev': case 'backToPrevious':
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
        showDuration = timerDuration;
        show_timer.start();
    }

    function close(){
        globalFrame.visible = false;
        show_timer.stop();
    }
}
