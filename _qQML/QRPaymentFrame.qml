import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0
import "config.js" as CONF


Base{
    id: qr_payment_frame
    isBoxNameActive: false
    property var modeQR: "linkaja"
    property var textMain: 'Scan QR Berikut Dengan Aplikasi ' + modeQR.toUpperCase()
    property var textSlave: 'Menunggu Pembayaran...'
    property var imageSource: "source/sand-clock-animated-2.gif"
    property bool successPayment: false
    property bool smallerSlaveSize: true
    property bool withTimer: true
    property int textSize: (globalScreenType == '1') ? 40 : 35
    property int timerDuration: 300
    property int waitAfterSuccess: 10
    property int showDuration: timerDuration
    property var closeMode: 'backToMain' // 'closeWindow', 'backToMain', 'backToPrev'
    visible: false
    opacity: visible ? 1.0 : 0.0
    Behavior on opacity {
        NumberAnimation  { duration: 500 ; easing.type: Easing.InOutQuad  }
    }

    Column{
        width: parent.width
        height: 500
        anchors.top: parent.top
        anchors.topMargin: (globalScreenType == '1') ? 200 : 150
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: (globalScreenType == '1') ? 30 : 25
        visible: !successPayment
        AnimatedImage  {
            width: 400
            height: 400
            scale: 1
            anchors.horizontalCenter: parent.horizontalCenter
            source: imageSource
            fillMode: Image.PreserveAspectFit
        }
        Text{
            text: textMain
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            font.pixelSize: textSize
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: false
            color: CONF.text_color
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
            color: CONF.text_color
            verticalAlignment: Text.AlignVCenter
            font.family:"Ubuntu"
        }

    }

    AnimatedImage  {
        width: 200
        height: 200
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        scale: 1
        anchors.horizontalCenter: parent.horizontalCenter
        source: 'source/blue_gradient_circle_loading.gif'
        fillMode: Image.PreserveAspectFit
        visible: !successPayment
        Text{
            anchors.fill: parent
            text: showDuration
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 40
            color: 'yellow'
            verticalAlignment: Text.AlignVCenter
            font.family:"Ubuntu"
        }
    }

    Rectangle{
        id: rec_payment_success
        width: parent.width
        height: 500
        anchors.top: parent.top
        anchors.topMargin: 200
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: CONF.frame_color
        opacity: 1
        visible: successPayment
        AnimatedImage  {
            width: 200
            height: 200
            scale: 0.5
            anchors.fill: parent
            source: 'source/success.png'
            fillMode: Image.PreserveAspectFit
        }
        Text{
            text: 'Pembayaran QR Berhasil'
            anchors.horizontalCenterOffset: 0
            anchors.top: parent.top
            anchors.topMargin: 25
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            font.pixelSize: 50
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: true
            color: 'white'
            verticalAlignment: Text.AlignVCenter
            font.family:"Ubuntu"
        }
        Text{
            text: 'Mohon Tunggu, Memproses Transaksi Anda...'
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            anchors.horizontalCenterOffset: 0
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            font.pixelSize: 50
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: true
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
            if (showDuration < 15){
                textSlave = 'Masih Menunggu Pembayaran dalam...';
            }
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


    function open(msg){
        if (msg!=undefined) textMain = msg;
        qr_payment_frame.visible = true;
        successPayment = false;
        showDuration = timerDuration;
        show_timer.start();
    }

    function close(){
        qr_payment_frame.visible = false;
        successPayment = false;
        show_timer.stop();
    }

    function success(waitTime){
        if (waitTime==undefined) waitTime = waitAfterSuccess;
        successPayment = true;
        delay(waitTime*1000, function(){
            close();
        });
    }

    Timer {
        id: timer_delay
    }

    function delay(duration, callback) {
        timer_delay.interval = duration;
        timer_delay.repeat = false;
        timer_delay.triggered.connect(callback);
        timer_delay.start();
    }
}
