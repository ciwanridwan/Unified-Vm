import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0

Base{
    id:popup_loading
    isBoxNameActive: false
    property var textMain: 'Silakan Menunggu'
    property var textSlave: ''
    property var imageSource: "source/sand-clock-animated-2.gif"
    property bool smallerSlaveSize: false
    property int textSize: 45
    visible: false
    opacity: visible ? 1.0 : 0.0
    Behavior on opacity {
        NumberAnimation  { duration: 500 ; easing.type: Easing.InOutQuad  }
    }

//    Rectangle{
//        anchors.fill: parent
//        color: "gray"
//        opacity: 0.5
//    }
    property int forceCloseLoading: 0

    Column{
        width: 600
        height: 500
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 30
        AnimatedImage  {
            width: 300
            height: 300
            anchors.horizontalCenter: parent.horizontalCenter
            source: imageSource
            fillMode: Image.PreserveAspectFit
            MouseArea{
                onClicked: {
                    forceCloseLoading += 1;
                    if (forceCloseLoading==10){
                        close();
                        forceCloseLoading = 0;
                    }
                }
            }
        }
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
            font.family:"Gotham"

        }
        Text{
            text: textSlave
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: (smallerSlaveSize) ? textSize-5: textSize
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: false
            color: 'white'
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family:"Gotham"

        }
    }


    function open(msg){
        if (msg!=undefined) textMain = msg;
        popup_loading.visible = true
        forceCloseLoading = 0;
    }

    function close(){
        popup_loading.visible = false
    }
}
