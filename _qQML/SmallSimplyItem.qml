import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: rectangle
    property var sourceImage:"source/qr_gopay.png"
    property bool modeReverse: true
    property var itemName: 'QR Gopay'
    property bool isSelected: false

    width: 359
    height: 183
    color: 'transparent'
    visible: true

    Rectangle {
        visible: !isSelected
        anchors.fill: parent
        color: (modeReverse) ? "white" : "black"
        opacity: .2
    }

    Rectangle {
        visible: isSelected
        anchors.fill: parent
        color: "black"
        opacity: .8
    }

    Image{
        id: raw_image
        sourceSize.height: 90
        sourceSize.width: 90
        anchors.top: parent.top
        anchors.topMargin: 25
        anchors.horizontalCenter: parent.horizontalCenter
        scale: 1
        source: sourceImage
        fillMode: Image.PreserveAspectFit
    }

    ColorOverlay {
        visible: modeReverse
        anchors.fill: raw_image
        source: raw_image
        scale: raw_image.scale
        color: "#ffffff"
    }

    Text{
        color: "white"
        text: itemName
        style: Text.Sunken
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        font.bold: true
        font.pixelSize: 28
        verticalAlignment: Text.AlignBottom
        horizontalAlignment: Text.AlignHCenter
        font.family: "Gotham"
    }

    function set_active(){
        isSelected = true;
    }

    function do_release(){
        isSelected = false;
    }



}

