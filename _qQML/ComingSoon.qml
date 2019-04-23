import QtQuick 2.0
import QtQuick.Controls 1.2

Base {
    id: base1
    mode_: "reverse"
    show_img: "aAsset/logo_white_.png"
    property var img_: "aAsset/img_clock.png"
    property var show_text: "COMING SOON"
    property var secondColor: "#f03838"
    property int timer_value: 60

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            abc.counter = timer_value;
            my_timer.start();
        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
        }
    }

    Rectangle{
        id: rec_timer
        width:10
        height:10
        y:10
        color:"transparent"
        QtObject{
            id:abc
            property int counter
            Component.onCompleted:{
                abc.counter = timer_value
            }
        }

        Timer{
            id:my_timer
            interval:1000
            repeat:true
            running:true
            triggeredOnStart:true
            onTriggered:{
                abc.counter -= 1
                if(abc.counter < 0){
                    my_timer.stop()
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
                }
            }
        }
    }

    Rectangle{
        id: second_base
        x: 0; y: 100;
        height: parent.height-100;
        width: parent.width;
        color: secondColor;
    }

    Image {
        id: img_motif
        source: img_
        x: 0
        y: 100
        anchors.right: parent.right
        anchors.rightMargin: -275
        fillMode: Image.PreserveAspectFit
    }

    Text{
        id: text_notif
        x: 90
        y: 350
        width: 300
        text: show_text
        font.bold: false
        font.italic: true
        style: Text.Sunken
        wrapMode: Text.WordWrap
        font.family: "Verdana"
        font.pixelSize: 100
        color: "white"
        opacity: 0.8
    }

    BackButton{
        id:back_button
        x: 100 ;y: 40;
        MouseArea{
            anchors.fill: parent
            onClicked: {
                my_layer.pop()
            }
        }
    }
}

