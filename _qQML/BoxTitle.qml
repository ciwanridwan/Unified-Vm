import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    width:250
    height:60
    color:"transparent"
    property string title_text: 'LANJUT'
    property bool modeReverse: false
    property int fontSize: 30
    property var boxColor: 'darkred'

    Rectangle{
        anchors.fill: parent
        color:(modeReverse) ? 'white' : boxColor
    }

    Text {
        color: (modeReverse) ? boxColor : 'white'
        anchors.fill: parent
        text: title_text
        scale: 1
        font.bold: false
        style: Text.Sunken
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"Ubuntu"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: fontSize - 3
    }


}

