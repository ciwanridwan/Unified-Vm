import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    id: rectangle1
    width:1000
    height:100
    color:"transparent"
    property string button_text: 'lanjut'
    property int fontSize: 50

    Rectangle{
        color: 'white'
        anchors.fill: parent
        opacity: .2
    }

    Text {
        id: text_denom
        width: 300
        color: 'white'
        text: button_text
        anchors.left: parent.left
        anchors.leftMargin: 50
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.family:"Ubuntu"
        font.pixelSize: fontSize
    }

    Text {
        id: text_choose
        width: 150
        color: 'white'
        text: 'pilih > '
        anchors.right: parent.right
        anchors.rightMargin: 50
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.family:"Ubuntu"
        font.pixelSize: fontSize
    }

}

