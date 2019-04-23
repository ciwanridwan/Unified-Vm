import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0

Rectangle{
    id:popup_loading
    visible: false
    color: 'transparent'
    width: 1920
    height: 1080
    scale: visible ? 1.0 : 0.1
    Behavior on scale {
        NumberAnimation  { duration: 500 ; easing.type: Easing.InOutBounce  }
    }

    Rectangle{
        anchors.fill: parent
        color: "gray"
        opacity: 0.6
    }

    Rectangle{
        width: 120
        height: 120
        color: "white"
        opacity: .8
        radius: width/2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        AnimatedImage  {
            id: image
            scale: 1.6
            anchors.fill: parent
            source: "aAsset/loading.gif"
            fillMode: Image.PreserveAspectFit
        }
    }


    function open(){
        popup_loading.visible = true
    }

    function close(){
        popup_loading.visible = false
    }
}
