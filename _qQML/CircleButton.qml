import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    width:160
    height:160
    color:"transparent"
    property bool modeReverse: false
    property string button_text: 'lanjut'
    property real globalOpacity: .50
    property int fontSize: 40

    Rectangle{
        anchors.fill: parent
        color: 'white'
        opacity: globalOpacity
        radius: width/2
    }

    Text {
        anchors.fill: parent
        color: (modeReverse) ? 'white' : 'black'
        text: button_text.toUpperCase()
        style: Text.Sunken
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"Ubuntu"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: (button_text.length > 5 ) ? 25 : fontSize
        font.bold: true
    }

}


