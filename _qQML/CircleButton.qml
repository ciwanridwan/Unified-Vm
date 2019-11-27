import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    width:120
    height:120
    color:"transparent"
    property bool modeReverse: false
    property string button_text: 'ISI SALDO\nOFFLINE'
    property real globalOpacity: .50
    property int fontSize: 30
    property bool blinkingMode: false
    property var forceColorButton: 'transparent'

    Rectangle{
        anchors.fill: parent
        color: (button_text=='BATAL') ? 'red' : 'white'
        opacity: (button_text=='BATAL') ? 1 : globalOpacity
        radius: width/2
        visible: (!blinkingMode && forceColorButton == 'transparent')
    }

    Rectangle{
        anchors.fill: parent
        color: forceColorButton
        radius: width/2
        visible: (!blinkingMode && forceColorButton != 'transparent')
    }

    Rectangle{
        visible: blinkingMode
        anchors.fill: parent
        color: (modeReverse) ? 'green' : 'white'
        radius: width/2
    }

    Text {
        anchors.fill: parent
        color: (modeReverse) ? 'white' : 'black'
        text: button_text.toUpperCase()
        style: Text.Sunken
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"GothamRounded"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: (button_text.length > 5 ) ? 23 : fontSize
        font.bold: true
    }

    QtObject{
        id:abc
        property int counter: 0
        Component.onCompleted:{
            abc.counter = 1;
        }
    }

    Timer{
        id: button_timer
        interval:1000
        repeat:true
        running:blinkingMode
        triggeredOnStart:blinkingMode
        onTriggered:{
            abc.counter += 1;
            if (abc.counter%2==0) {
                modeReverse = true;
            } else {
                modeReverse = false;
            }
        }
    }

    Component.onCompleted: {
        if (blinkingMode) button_timer.start();
    }

    Component.onDestruction: {
        button_timer.stop();
    }



}


