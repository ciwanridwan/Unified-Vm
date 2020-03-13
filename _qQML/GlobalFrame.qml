import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0

Base{
    id:globalFrame
    isBoxNameActive: false
//        property var globalScreenType: '1'
//        height: (globalScreenType=='2') ? 1024 : 1080
//        width: (globalScreenType=='2') ? 1280 : 1920

    property var textMain: 'Masukkan Kartu Debit dan PIN Anda Pada EDC'
    property var textSlave: 'Posisi Mesin EDC Tepat Di Tengah Bawah Layar'
    property var imageSource: "source/insert_card_dc.png"
    property bool smallerSlaveSize: true
    property bool withTimer: true
    property int textSize: (globalScreenType == '1') ? 40 : 35
    property int timerDuration: 5
    property int showDuration: timerDuration
    property var closeMode: 'closeWindow' // 'closeWindow', 'backToMain', 'backToPrev'
    visible: false
    opacity: visible ? 1.0 : 0.0
    Behavior on opacity {
        NumberAnimation  { duration: 500 ; easing.type: Easing.InOutQuad  }
    }

    Column{
        id: column
        width: parent.width - 100
        height: 500
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: (globalScreenType == '1') ? 30 : 25
        AnimatedImage  {
            id: original_image
            visible:  (imageSource!='source/insert_card_dc.png')
            width: 300
            height: 300
            scale: 0.9
            anchors.horizontalCenter: parent.horizontalCenter
            source: imageSource
            fillMode: Image.PreserveAspectFit
        }
        GroupBox{
            id: multiple_images_edc
            flat: true
            width: parent.width
            height: 300
            anchors.horizontalCenter: parent.horizontalCenter
            visible: (imageSource=='source/insert_card_dc.png')
            Image{
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: (globalScreenType == '1') ? -50 : -200
                scale: (globalScreenType == '1') ? 0.8 : 0.5
                source: "source/insert_card_step01.png"
                fillMode: Image.PreserveAspectFit
            }
//            AnimatedImage{
//                scale: 1
//                source: "source/arrow_down.gif"
//                fillMode: Image.PreserveAspectFit
            //            }
            Image{
                anchors.right: parent.right
                anchors.rightMargin: (globalScreenType == '1') ? -50 : -200
                anchors.verticalCenter: parent.verticalCenter
                scale: (globalScreenType == '1') ? 0.8 : 0.5
                source: "source/insert_pin_step02.png"
                fillMode: Image.PreserveAspectFit
            }
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
//        Text{
//            visible:  (imageSource=='source/insert_money.png')
//            text: 'PENTING : Uang Yang Dapat Diterima'
//            horizontalAlignment: Text.AlignHCenter
//            width: parent.width
//            wrapMode: Text.WordWrap
//            font.pixelSize: textSize
//            anchors.horizontalCenter: parent.horizontalCenter
//            font.bold: false
//            color: 'white'
//            verticalAlignment: Text.AlignVCenter
//            font.family:"Ubuntu"
//        }
        Row{
            id: group_acceptable_money
            anchors.horizontalCenter: parent.horizontalCenter
            visible:  (imageSource=='source/insert_money.png')
            scale: 1
            spacing: 16
            Image{
                id: img_count_100
                scale: 0.9
                source: "source/100rb.png"
                fillMode: Image.PreserveAspectFit
            }
            Image{
                id: img_count_50
                scale: 0.9
                source: "source/50rb.png"
                fillMode: Image.PreserveAspectFit
            }
            Image{
                id: img_count_20
                scale: 0.9
                source: "source/20rb.png"
                fillMode: Image.PreserveAspectFit
            }
            Image{
                id: img_count_10
                scale: 0.9
                source: "source/10rb.png"
                fillMode: Image.PreserveAspectFit
            }

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
