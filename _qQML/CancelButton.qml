import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    id: rectangle1
    width:90
    height:90
    color:"transparent"
    property var exitText: qsTr("Cancel")
    property var imgSource: "source/close.png"
    Image{
        id: back_arrow
        source: imgSource
        anchors.fill: parent
        anchors.centerIn: parent
        fillMode: Image.Stretch
    }
    Text {
        id: caption_button
        x: 21
        y: 96
        text: exitText
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -30
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: "white"
        font.pixelSize: 18
        font.family: "GothamRounded"
    }

}

