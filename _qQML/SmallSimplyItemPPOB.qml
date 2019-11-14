import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: rectangle
    property var sourceImage:"source/ppob_category/pulsa.png"
    property bool modeReverse: true
    property var categoryName: 'Pulsa'
    width: 359
    height: 183
    color: 'transparent'
    visible: true

    Rectangle {
        anchors.fill: parent
        color: (modeReverse) ? "white" : "black"
        opacity: .5
    }

    Image{
        anchors.top: parent.top
        anchors.topMargin: 25
        anchors.horizontalCenter: parent.horizontalCenter
        scale: 1.2
        source: sourceImage
        fillMode: Image.PreserveAspectFit
    }

    Text{
        color: "white"
        text: categoryName
        style: Text.Sunken
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        font.bold: true
        font.pixelSize: 28
        verticalAlignment: Text.AlignBottom
        horizontalAlignment: Text.AlignHCenter
        font.family: "Ubuntu"

    }

}

