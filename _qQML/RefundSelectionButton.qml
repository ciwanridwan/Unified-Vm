import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0


Rectangle{
    id: main_rec
    property var buttonName: 'MANUAL'
    property var imageSource: "source/find.png"
    property var colorMode: "#3b8f23"
    property bool isSelected: false
    property var channelCode: 'MANUAL'
    property var channelDesc: ''
    property var channelFee: 0
    width:190
    height:100
    color: isSelected ? 'silver' : colorMode
    radius: 20
    Text{
        text: buttonName
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 20
        font.family:"Ubuntu"
        font.bold: true
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: isSelected ? 'white' : 'black'
    }
    Image{
        id: main_image
        width: 80
        height: 80
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        scale: 0.75
        source: imageSource
        fillMode: Image.PreserveAspectFit
//        visible: !isSelected
    }
    ColorOverlay {
        id: reverse_main_image
        anchors.fill: main_image
        source: main_image
        color: 'white'
        scale: main_image.scale
        visible: false
//        visible: isSelected
    }

    function setActive(){
        isSelected = true;
    }

    function release(){
        isSelected = false;
    }


}

