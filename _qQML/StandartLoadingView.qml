import QtQuick 2.4
import QtQuick.Controls 1.2

Base{
    id:loading
    visible: false
    mode_: 'loading'
    property var show_text: "Please Wait, Executing Command..."
    property var show_gif: "aAsset/simply_loading.gif"

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            open();
        }
        if(Stack.status==Stack.Deactivating){
            close();
        }
    }

    Component.onCompleted: {
    }

    Component.onDestruction: {
    }


    Rectangle{
        id: base_overlay
        width: parent.width; height: 50
        color: "#472f2f"
        opacity: 0.7
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        Text {
            id: loading_text
            color: "white"
            anchors.fill: parent
            text: show_text
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family:"Ubuntu"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 30
        }
    }

    AnimatedImage{
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: show_gif
    }

    function open(){
        loading.visible = true;
    }
    function close(){
        loading.visible = false;
    }
}
