import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0
import "screen.js" as SCREEN

Rectangle{
    id:popup_loading
    visible: false
    color: 'transparent'
    width: parseInt(SCREEN.size.width)
    height: parseInt(SCREEN.size.height)
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
            source: "source/loading.gif"
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
