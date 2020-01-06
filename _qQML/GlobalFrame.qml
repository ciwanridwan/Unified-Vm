import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0

Base{
    id:globalFrame
    isBoxNameActive: false
    property var textMain: 'Masukkan Kartu Debit dan PIN Anda Pada EDC'
    property var textSlave: 'Posisi Mesin EDC Tepat Di Tengah Bawah Layar'
    property var imageSource: "source/insert_card_new.png"
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
        id: column
        width: 1100
        height: 500
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 30
        AnimatedImage  {
            id: original_image
            visible:  (imageSource!='source/insert_card_new.png')
            width: 300
            height: 300
            scale: 0.9
            anchors.horizontalCenter: parent.horizontalCenter
            source: imageSource
            fillMode: Image.PreserveAspectFit
        }
        Row{
            id: multiple_images_edc
            scale: 1
            width: parent.width
            height: 300
            layoutDirection: Qt.LeftToRight
            visible: (imageSource=='source/insert_card_new.png')
            spacing: 200
            Image{
                scale: 1.5
                source: "source/insert_card_realistic.jpg"
                fillMode: Image.PreserveAspectFit
            }
            AnimatedImage{
                scale: 1
                source: "source/arrow_down.gif"
                fillMode: Image.PreserveAspectFit
            }
            Image{
                scale: 1.5
                source: "source/input_card_pin_realistic.jpeg"
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
            scale: 1
            visible:  (imageSource=='source/insert_money.png')
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
